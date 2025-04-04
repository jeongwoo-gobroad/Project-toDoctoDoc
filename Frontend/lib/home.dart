import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:to_doc/screens/aboutpage.dart';
import 'package:to_doc/controllers/careplus/chat_controller.dart';
import 'package:to_doc/controllers/query_controller.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/navigator/side_menu.dart';
import 'package:to_doc/screens/airesult.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //final AboutpageProvider aboutpage = Get.put(AboutpageProvider());
  final TextEditingController queryController = TextEditingController();
  final UserinfoController userController = Get.find<UserinfoController>();
  //추후 수정
  Color _green = Color.fromARGB(255, 225, 234, 205);

  final QueryController query = Get.put(QueryController());
  String? id;
  String? usernick;
  String? email;
  int randIndex = 0;
  int randIndex2 = 0;
  int randIndex3 = 0;
  bool isLoading = true;
  final FocusNode _focusNode = FocusNode();

  bool _isKeyboardVisible = false;

  Future<void> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id');
      usernick = prefs.getString('usernick');
      email = prefs.getString('email');
      isLoading = false;
    });
  }

  @override
  void initState() {
    final random = Random();

    randIndex = random.nextInt(welcomeMessages.length);
    randIndex2 = random.nextInt(mindfulnessQuotes.length);
    randIndex3 = random.nextInt(queryQuotes.length);
    // TODO: implement initState
    super.initState();
    _getUserInfo();
    query.queryLimit();
    //query.chatLimit();

    _focusNode.addListener(() {
      setState(() {
        _isKeyboardVisible = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    queryController.dispose();
    super.dispose();
  }

  // 환영 문구 리스트
  final List<String> welcomeMessages = [
    '반가워요!',
    '어서오세요!',
    '어서와요!',
    '환영합니다!',
    '안녕하세요!',
    '환영해요!',
    '잘 오셨습니다!'
  ];

  final List<String> mindfulnessQuotes = [
    '마음이 평온해야 모든 것이 평온해진다.',
    '행복은 내면에서 찾는 것이며, 평온함은 그 길을 밝히는 등불이다.',
    '지금 이 순간에 집중하라. 그것이 유일한 삶의 순간이다.',
    "고요한 마음은 삶의 아름다움을 보는 가장 맑은 창이다.",
    "평화는 밖에서 오는 것이 아니라, 내 안에서 스스로 발견하는 것이다.",
    "내 마음이 잔잔한 호수와 같다면, 어떤 바람도 흔들지 못한다.",
    "모든 순간은 배움의 기회이며, 마음을 가다듬는 연습이다.",
    "평온은 내 안의 정원에서 피어나는 꽃과 같다. 잘 돌볼수록 더 아름답게 핀다.",
    '비 온 뒤에 땅이 굳어지듯, 어려움 뒤에 마음이 강해진다.',
    '내면의 고요함이야말로 진정한 힘이다.',
    '행복은 조건이 아니라 선택이다.',
    '마음의 짐을 내려놓는 것이 자유로 가는 길이다.',
    '너무 앞서가지 마라. 오늘을 살라.',
    '삶은 단순하다. 우리가 복잡하게 만드는 것이다.',
    '침묵 속에서 진정한 나를 만난다.',
    "순간의 호흡 속에서 마음의 평화를 발견할 수 있다.",
  ];

  final List<String> queryQuotes = [
    '무엇이 당신을 힘들게 하나요?',
    '당신의 걱정거리는 무엇인가요?',
    '마음속의 부정적인 감정을 털어놓으세요.',
  ];

  ChatController chatController = Get.put(ChatController());

  Widget _buildQueryUsageDisplay() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '일일 제한 횟수: ${query.userTotal.value}/${query.query.value}',
            style: TextStyle(
              fontSize: 14,
              color: query.userTotal.value >= query.query.value
                  ? Colors.red
                  : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ));
  }

  @override
  Widget build(context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _isKeyboardVisible = false;
        });
      },
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          if (_isKeyboardVisible) {
            FocusScope.of(context).unfocus();
            setState(() {
              _isKeyboardVisible = false;
            });
          }
        },
        child: Scaffold(
          //floating 아이콘
          /*
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              //chatController.getChatList();
              //chatController.getChatContent('67800d68d77a92c816209bf6');
              Get.to(()=>DMList());
            },
            child: const Icon(Icons.chat_bubble_outline_rounded),
          ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      */

          //appBar
          drawer: Obx(() => SideMenu(
              userController.usernick.value, userController.email.value)),
          onDrawerChanged: (isOpened) {
            if (isOpened) {
              FocusScope.of(context).requestFocus(FocusNode());
              setState(() {
                _isKeyboardVisible = false;
              });
            }
          },
          appBar: AppBar(
            centerTitle: true,
            title: InkWell(
              onTap: () {
                Get.to(() => Aboutpage());
              },
              child: Text('토닥toDoc',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ),
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator()) //아직 갱신안됐으면 로딩창띄움
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Obx(
                          () => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 50),

                                // Icon(
                                //   Icons.circle_outlined,
                                //   size: 100,
                                // ),
                                Image.asset('asset/images/intro.png',
                                  width: 200,
                                  height: 200,
                                ),
          
                                SizedBox(height: 50),

                                Text(
                                  '${welcomeMessages[randIndex]} ${userController.usernick.value ?? '로그인이 필요합니다.'}님',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                //if (isKeyboardVisible) _buildQueryUsageDisplay(),
                                SizedBox(height: 20),

                                Container(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Text("\“",
                                            style: TextStyle(
                                                fontSize: 100, color: _green)),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                150,
                                        child: Text(
                                          '${mindfulnessQuotes[randIndex2]}',
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text("\”",
                                            style: TextStyle(
                                                fontSize: 100, color: _green)),
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_isKeyboardVisible)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _buildQueryUsageDisplay(),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              color: _green,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: TextField(
                              focusNode: _focusNode,
                              controller: queryController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 20),
                                hintText: '${queryQuotes[randIndex3]}',
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                prefixIcon: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.mic),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    if (queryController.text.isNotEmpty) {
                                      query.queryLimit();
                                      query.sendQuery(queryController.text);
                                      Get.to(() => Airesult(title : queryController.text));
                                    }
                                  },
                                  icon: Icon(Icons.arrow_circle_right_outlined,
                                      size: 45),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
