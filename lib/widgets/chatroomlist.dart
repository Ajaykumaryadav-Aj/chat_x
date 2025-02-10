
import 'package:chat_x/screens/chat_page.dart';
import 'package:chat_x/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time;
  const ChatRoomListTile(
      {super.key,
      required this.lastMessage,
      required this.chatRoomId,
      required this.myUsername,
      required this.time});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "", id = "";

  getthisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUsername, "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    name = "${querySnapshot.docs[0]["Name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["Photo"]}";
    id = "${querySnapshot.docs[0]["Id"]}";
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getthisUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                    name: name, profileurl: profilePicUrl, username: username),
              ));
        },
        titleAlignment: ListTileTitleAlignment.top,
        leading: SizedBox(
          width: 60,
          child: profilePicUrl == ""
              ? const Icon(
                  Icons.person,
                  size: 40,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    profilePicUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        title: Text(
          name,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15),
        ),
        subtitle: Text(
          overflow: TextOverflow.ellipsis,
          widget.lastMessage,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black45, fontSize: 16),
        ),
        trailing: Text(
          widget.time,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black45, fontSize: 13),
        ),
      ),
    );
  }
}
