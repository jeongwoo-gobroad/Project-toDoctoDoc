const Curate = require("../../../../models/Curate");
const UserSchema = require("../../../../models/User");
const mongoose = require('mongoose');
const User = mongoose.model('User', UserSchema);
const OpenAI = require("openai");

const returnNewCurate = async (userid) => {
    try {
        const curate = new Curate;

        const data = await User.findById(userid).populate('posts ai_chats');

        curate.user = req.userid;

        data.posts.sort((a, b) => {
            return b.editedAt - a.editedAt;
        });
        data.ai_chats.sort((a, b) => {
            return b.chatEditedAt - a.chatEditedAt;
        });

        if (data.posts.length >= 40) {
            curate.posts = data.posts.slice(0, 40);
        } else {
            curate.posts = data.posts;
        }
        if (data.ai_chats.length >= 20) {
            curate.ai_chats = data.ai_chats.slice(0, 20);
        } else {    
            curate.ai_chats = data.ai_chats;
        }

        let messages = [];
        messages.push({
            "role": "developer",
            "content": "너는 전문 심리 상담사고, 내가 제시한, 환자가 품고 있는 걱정 및 대화 내용을 기반으로 이 환자가 어떠한 것 때문에 마음이 아픈지 주치의에게 설명해줘"
        });
        for (const post of curate.posts) {
            messages.push({
                "role": "user",
                "content": post.title
            });
        }
        for (const ai_chat of curate.ai_chats) {
            messages.concat(ai_chat.response);
        }

        const target = new OpenAI({
            apiKey: process.env.OPENAI_KEY
        });

        const completion = await target.chat.completions.create({
            "model": "gpt-4o",
            "store": false,
            "messages": messages
        });

        const message = completion.choices[0].message.content;

        curate.deepCurate = message;

        await curate.save();

        return curate;
    } catch (error) {
        console.error(error, "errorAtReturnNewCurate");

        throw new Error(error);
    }
};

module.exports = returnNewCurate;