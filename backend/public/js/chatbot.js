console.log("Hello, world!");
let chattingPrompt = [];

// 채팅 메시지를 표시할 DOM
const chatMessages = document.querySelector('#chat-messages');
// 사용자 입력 필드
const userInput = document.querySelector('#user-input input');
// 전송 버튼
const sendButton = document.querySelector('#user-input button');

const storeUserInput = (input) => {
    chattingPrompt.push({role: 'user', content: input});

    if (chattingPrompt.length >= 80) {
        chattingPrompt.shift();
    }
};

const storeGPTResponse = (output) => {
    chattingPrompt.push({role: 'assistant', content: output});

    if (chattingPrompt.length >= 80) {
        chattingPrompt.shift();
    }
};

function addMessage(sender, message) {
    // 새로운 div 생성
    const messageElement = document.createElement('div');
    // 생성된 요소에 클래스 추가
    messageElement.className = 'message';
     // 채팅 메시지 목록에 새로운 메시지 추가
    messageElement.textContent = `${sender}: ${message}`;
    chatMessages.prepend(messageElement);
}

const prevChatList = document.getElementById('prevChatData');

if (prevChatList) {
    const value = prevChatList.value;
    const parsedPrevChatList = JSON.parse(value);

    // console.log(parsedPrevChatList);

    if (parsedPrevChatList.length > 0) {
        // console.log(parsedPrevChatList);

        chattingPrompt = chattingPrompt.concat(parsedPrevChatList);

        // console.log(chattingPrompt);

        for (const chat of chattingPrompt) {
            if (chat['role'] === 'user') {
                // console.log(chat['content']);
                addMessage('나', chat['content']);
            } else if (chat['role'] == 'assistant') {
                // console.log(chat['content']);
                addMessage('챗봇', chat['content']);
            }
        }
    }
}

async function fetchAIResponse(prompt) {
    storeUserInput(prompt);

    try {
        const response = await fetch('/chatbot/chatting', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                chattingPrompt
            })
        });

        const res = await response.json();

        if (typeof res.isLimitExceeded !== 'undefined') {
            location.replace("/freeAccountError");
        }

        storeGPTResponse(res.chat);

        return res.chat;
    } catch (error) {
		console.error(error);
        return '오류 발생';
    }
}
// 전송 버튼 클릭 이벤트 처리
sendButton.addEventListener('click', async () => {
    // 사용자가 입력한 메시지
    const message = userInput.value.trim();

    // console.log(message);

    // 메시지가 비어있으면 리턴
    if (message.length === 0) return;
    // 사용자 메시지 화면에 추가
    addMessage('나', message);
    userInput.value = '';
    
    const aiResponse = await fetchAIResponse(message);
    addMessage('챗봇', aiResponse);

    document.getElementById('chatData').value = JSON.stringify(chattingPrompt);
});
// 사용자 입력 필드에서 Enter 키 이벤트를 처리
userInput.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') {
        sendButton.click();
    }
});