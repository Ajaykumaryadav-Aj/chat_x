import 'package:chat_x/screens/home.dart';
import 'package:chat_x/service/database.dart';
import 'package:chat_x/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  String name, profileurl, username;
  ChatPage(
      {super.key,
      required this.name,
      required this.profileurl,
      required this.username});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  String? myUserName, myProfilePic, myName, myEmail, messageId, chatRoomId;
  Stream? messageStream;

  getthesharedpref() async {
    myUserName = await SharedPrefHelper().getUserName();
    myProfilePic = await SharedPrefHelper().getUserPic();
    myName = await SharedPrefHelper().getUserDisplayName();
    myEmail = await SharedPrefHelper().getUserEmail();

    chatRoomId = getChatRoomIdbyUsername(widget.username, myUserName!);
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    await getAndSetMessage();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(0),
                  bottomRight: sendByMe
                      ? const Radius.circular(0)
                      : const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: sendByMe
                      ? const Radius.circular(24)
                      : const Radius.circular(0),
                ),
                color: sendByMe
                    ? const Color.fromARGB(255, 194, 197, 204)
                    : const Color.fromARGB(255, 183, 194, 228),
              ),
              child: Text(
                message,
                style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              )),
        )
      ],
    );
  }

  Widget chatMessage() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: const EdgeInsets.only(bottom: 90.0, top: 130),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatMessageTile(
                      ds["message"], myUserName == ds["sendBy"]);
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  addMessage(bool sendClicked) {
    if (messageController.text != "") {
      String message = messageController.text;
      messageController.text = "";

      DateTime now = DateTime.now();
      String formattedDate = DateFormat("h:mma").format(now);

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myProfilePic,
      };
      messageId ??= randomAlphaNumeric(10);

      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": myUserName,
        };
        DatabaseMethods()
            .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if (sendClicked) {
          messageId = null;
        }
      });
    }
  }




// addMessage(bool sendClicked) async {
//   if (messageController.text != "") {
//     String message = messageController.text;
//     messageController.text = "";

//     DateTime now = DateTime.now();
//     String formattedDate = DateFormat("h:mma").format(now);

//     // Message information to store
//     Map<String, dynamic> messageInfoMap = {
//       "message": message,
//       "sendBy": myUserName,
//       "ts": formattedDate,
//       "time": FieldValue.serverTimestamp(),
//       "imgUrl": myProfilePic,
//     };

//     messageId ??= randomAlphaNumeric(10);

//     // Add message to the chatroom collection
//     DatabaseMethods()
//         .addMessage(chatRoomId!, messageId!, messageInfoMap)
//         .then((value) {
//           Map<String, dynamic> lastMessageInfoMap = {
//             "lastMessage": message,
//             "lastMessageSendTs": formattedDate,
//             "time": FieldValue.serverTimestamp(),
//             "lastMessageSendBy": myUserName,
//           };
          
//           // Update the last message information in the chatroom for both users
//           DatabaseMethods()
//               .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);

//           // After message is sent, update the chatroom list for both users
//           String otherUser = widget.username;

//           DatabaseMethods().updateChatListForUser(myUserName!, chatRoomId!, lastMessageInfoMap);
//           DatabaseMethods().updateChatListForUser(otherUser, chatRoomId!, lastMessageInfoMap);

//           if (sendClicked) {
//             messageId = null;
//           }
//       });
//   }
// }




  getAndSetMessage() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF553370),
        body: Container(
          padding: const EdgeInsets.only(top: 50),
          child: Stack(children: [
            Container(
                margin: const EdgeInsets.only(top: 50),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height /1.12,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                        topLeft: Radius.circular(0),
                        bottomLeft: Radius.circular(30))),
                child: chatMessage()),
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ));
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Color(0xffc199cd),
                    ),
                  ),
                  const SizedBox(width: 100),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xffc199cd),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              alignment: Alignment.bottomCenter,
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message",
                        suffixIcon: IconButton(
                            onPressed: () {
                              addMessage(true);
                            },
                            icon: Icon(Icons.send))),
                  ),
                ),
              ),
            ),
          ]),
        ));
  }
}
