


import 'package:chat_x/screens/home.dart';
import 'package:chat_x/service/database.dart';
import 'package:chat_x/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  final String name, profileurl, username, chatRoomId;
  const ChatPage({
    super.key,
    required this.name,
    required this.profileurl,
    required this.username,
    required this.chatRoomId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  String? myUserName, myProfilePic, myName, myEmail, messageId;
  Stream? messageStream;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // Load shared preferences
  loadUserData() async {
    myUserName = await SharedPrefHelper().getUserName();
    myProfilePic = await SharedPrefHelper().getUserPic();
    myName = await SharedPrefHelper().getUserDisplayName();
    myEmail = await SharedPrefHelper().getUserEmail();

    await getAndSetMessage();

    // Update online status
    if (myUserName != null && myUserName!.isNotEmpty) {
      DatabaseMethods().updateUserStatus(myUserName!, true);
    }

    setState(() {});
  }

  @override
  void dispose() {
    // Update offline on exit
    if (myUserName != null && myUserName!.isNotEmpty) {
      DatabaseMethods().updateUserStatus(myUserName!, false);
    }
    super.dispose();
  }

  // Tick icons
  Widget tickIcon(String status) {
    if (status == "sent") return const Icon(Icons.check, size: 16, color: Colors.grey);
    if (status == "delivered") return const Icon(Icons.done_all, size: 16, color: Colors.grey);
    if (status == "seen") return const Icon(Icons.done_all, size: 16, color: Colors.blue);
    return const SizedBox.shrink();
  }

  Widget chatMessageTile(String message, bool sendByMe, String status) {
    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                bottomRight: sendByMe ? const Radius.circular(0) : const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: sendByMe ? const Radius.circular(18) : const Radius.circular(0),
              ),
              color: sendByMe ? const Color.fromARGB(255, 194, 197, 204) : const Color.fromARGB(255, 183, 194, 228),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                ),
                if (sendByMe) ...[const SizedBox(width: 5), tickIcon(status)],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget chatMessageList() {
    if (messageStream == null) return const Center(child: CircularProgressIndicator());

    return StreamBuilder(
      stream: messageStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return const Center(child: Text("No messages yet"));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 90, top: 10),
          reverse: true,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];

            // mark delivered
            if (ds["sendBy"] != myUserName && ds["status"] == "sent") {
              FirebaseFirestore.instance
                  .collection("chatrooms")
                  .doc(widget.chatRoomId)
                  .collection("chats")
                  .doc(ds.id)
                  .update({"status": "delivered"});
            }

            // mark seen
            if (ds["sendBy"] != myUserName && ds["status"] != "seen") {
              FirebaseFirestore.instance
                  .collection("chatrooms")
                  .doc(widget.chatRoomId)
                  .collection("chats")
                  .doc(ds.id)
                  .update({"status": "seen"});
            }

            return chatMessageTile(ds["message"], myUserName == ds["sendBy"], ds["status"]);
          },
        );
      },
    );
  }

  addMessage() {
    if (messageController.text.trim().isEmpty) return;
    if (widget.chatRoomId.isEmpty) return;

    String message = messageController.text.trim();
    messageController.clear();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat("h:mma").format(now);

    Map<String, dynamic> messageInfoMap = {
      "message": message,
      "sendBy": myUserName,
      "ts": formattedDate,
      "time": FieldValue.serverTimestamp(),
      "imgUrl": myProfilePic,
      "status": "sent",
    };

    messageId ??= randomAlphaNumeric(10);

    DatabaseMethods().addMessage(widget.chatRoomId, messageId!, messageInfoMap).then((_) {
      Map<String, dynamic> lastMessageInfoMap = {
        "lastMessage": message,
        "lastMessageSendTs": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "lastMessageSendBy": myUserName,
      };
      DatabaseMethods().updateLastMessageSend(widget.chatRoomId, lastMessageInfoMap);
      messageId = null;
    });
  }

  getAndSetMessage() async {
    if (widget.chatRoomId.isEmpty) return;
    messageStream = await DatabaseMethods().getChatRoomMessages(widget.chatRoomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF553370),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        centerTitle: true,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection("users").doc(widget.username).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Row(
                children: [
                  const Icon(Icons.circle, color: Colors.grey, size: 10),
                  const SizedBox(width: 6),
                  Text(widget.name, style: const TextStyle(color: Colors.amber)),
                ],
              );
            }

            var userData = snapshot.data!;
            bool isOnline = userData["isOnline"] ?? false;
            Timestamp? lastSeenTimestamp = userData["lastSeen"];

            String lastSeenText = "Last seen just now";
            if (!isOnline && lastSeenTimestamp != null) {
              DateTime lastSeen = lastSeenTimestamp.toDate();
              lastSeenText = "Last seen: ${DateFormat('hh:mm a').format(lastSeen)}";
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, color: isOnline ? Colors.green : Colors.grey, size: 10),
                    const SizedBox(width: 6),
                    Text(widget.name, style: const TextStyle(color: Colors.amber)),
                  ],
                ),
                Text(
                  isOnline ? "Online" : lastSeenText,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: chatMessageList(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: const Color(0xFF553370),
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      onTap: addMessage,
                      borderRadius: BorderRadius.circular(50),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
















































































































































// import 'package:chat_x/screens/home.dart';
// import 'package:chat_x/service/database.dart';
// import 'package:chat_x/service/shared_pref.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:random_string/random_string.dart';

// class ChatPage extends StatefulWidget {
//   String name, profileurl, username;
//   ChatPage(
//       {super.key,
//       required this.name,
//       required this.profileurl,
//       required this.username});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   TextEditingController messageController = TextEditingController();
//   String? myUserName, myProfilePic, myName, myEmail, messageId, chatRoomId;
//   Stream? messageStream;

//   getthesharedpref() async {
//     myUserName = await SharedPrefHelper().getUserName();
//     myProfilePic = await SharedPrefHelper().getUserPic();
//     myName = await SharedPrefHelper().getUserDisplayName();
//     myEmail = await SharedPrefHelper().getUserEmail();

//     chatRoomId = getChatRoomIdbyUsername(widget.username, myUserName!);
//     setState(() {});
//   }

//   ontheload() async {
//     await getthesharedpref();
//     await getAndSetMessage();
//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();
//     ontheload();
//   }

//   getChatRoomIdbyUsername(String a, String b) {
//     if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
//       return "$b\_$a";
//     } else {
//       return "$a\_$b";
//     }
//   }

//   Widget chatMessageTile(String message, bool sendByMe) {
//     return Row(
//       mainAxisAlignment:
//           sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//       children: [
//         Flexible(
//           child: Container(
//               padding: EdgeInsets.all(16),
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(18),
//                   bottomRight: sendByMe
//                       ? const Radius.circular(0)
//                       : const Radius.circular(18),
//                   topRight: const Radius.circular(18),
//                   bottomLeft: sendByMe
//                       ? const Radius.circular(18)
//                       : const Radius.circular(0),
//                 ),
//                 color: sendByMe
//                     ? const Color.fromARGB(255, 194, 197, 204)
//                     : const Color.fromARGB(255, 183, 194, 228),
//               ),
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                     fontSize: 15.0,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black),
//               )),
//         )
//       ],
//     );
//   }

//   Widget chatMessage() {
//     return StreamBuilder(
//       stream: messageStream,
//       builder: (context, AsyncSnapshot snapshot) {
//         return snapshot.hasData
//             ? ListView.builder(
//                 padding: const EdgeInsets.only(bottom: 90.0, top: 130),
//                 itemCount: snapshot.data.docs.length,
//                 reverse: true,
//                 itemBuilder: (context, index) {
//                   DocumentSnapshot ds = snapshot.data.docs[index];
//                   return chatMessageTile(
//                       ds["message"], myUserName == ds["sendBy"]);
//                 },
//               )
//             : const Center(
//                 child: CircularProgressIndicator(),
//               );
//       },
//     );
//   }

//   addMessage(bool sendClicked) {
//     if (messageController.text != "") {
//       String message = messageController.text;
//       messageController.text = "";

//       DateTime now = DateTime.now();
//       String formattedDate = DateFormat("h:mma").format(now);

//       Map<String, dynamic> messageInfoMap = {
//         "message": message,
//         "sendBy": myUserName,
//         "ts": formattedDate,
//         "time": FieldValue.serverTimestamp(),
//         "imgUrl": myProfilePic,
//       };
//       messageId ??= randomAlphaNumeric(10);

//       DatabaseMethods()
//           .addMessage(chatRoomId!, messageId!, messageInfoMap)
//           .then((value) {
//         Map<String, dynamic> lastMessageInfoMap = {
//           "lastMessage": message,
//           "lastMessageSendTs": formattedDate,
//           "time": FieldValue.serverTimestamp(),
//           "lastMessageSendBy": myUserName,
//         };
//         DatabaseMethods()
//             .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
//         if (sendClicked) {
//           messageId = null;
//         }
//       });
//     }
//   }

//   getAndSetMessage() async {
//     messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color(0xFF553370),
//           leading: IconButton(
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => HomeScreen(),
//                   ));
//             },
//           ),
//           centerTitle: true,
//           title: Text(
//             widget.name,
//             style: TextStyle(color: Colors.amber),
//           ),
//         ),
//         body: Container(
//           padding: const EdgeInsets.only(top: 0),
//           child: Stack(children: [
//             Container(
//                 margin: const EdgeInsets.only(top: 0),
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height / 1.12,
//                 decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(10),
//                         topLeft: Radius.circular(0),
//                         bottomLeft: Radius.circular(30))),
//                 child: chatMessage()),
           
//             const SizedBox(height: 20),
//             Container(
//               margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
//               alignment: Alignment.bottomCenter,
//               child: Material(
//                 elevation: 5,
//                 borderRadius: BorderRadius.circular(10),
//                 child: Container(
//                   padding: const EdgeInsets.only(left: 10.0),
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10)),
//                   child: TextField(
//                     controller: messageController,
//                     decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hintText: "Type a message",
//                         suffixIcon: IconButton(
//                             onPressed: () {
//                               addMessage(true);
//                             },
//                             icon: Icon(Icons.send))),
//                   ),
//                 ),
//               ),
//             ),
//           ]),
//         ));
//   }
// }
