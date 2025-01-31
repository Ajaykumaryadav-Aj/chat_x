import 'package:chat_x/screens/chat_page.dart';
import 'package:chat_x/service/database.dart';
import 'package:chat_x/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool search = false;
  String? myName, myProfilePic, myUserName, myEmail;
  Stream? chatRoomsStream;

  getthesharedpref() async {
    myName = await SharedPrefHelper().getUserDisplayName();
    myProfilePic = await SharedPrefHelper().getUserPic();
    myUserName = await SharedPrefHelper().getUserName();
    myEmail = await SharedPrefHelper().getUserEmail();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  Widget ChatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(
                      lastMessage: ds["lastMessage"],
                      chatRoomId: ds.id,
                      myUsername: myUserName!,
                      time: ds["lastMessageSendTs"]);
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              );
      },
    );
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

  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      search = true;
    });
    var captilizeValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().Search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element["username"].startsWith(captilizeValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF553370),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 50, left: 20, right: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    search
                        ? Expanded(
                            child: TextField(
                            onChanged: (value) {
                              initiateSearch(value.toUpperCase());
                            },
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search User",
                                hintStyle: TextStyle(
                                    fontSize: 20, color: Colors.black)),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18),
                          ))
                        : const Text(
                            "ChatUp",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xffc199cd)),
                          ),
                    GestureDetector(
                      onTap: () {
                        search = true;
                        setState(() {});
                      },
                      child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: const Color(0xFF3a2144),
                              borderRadius: BorderRadius.circular(20)),
                          child: search
                              ? GestureDetector(
                                  onTap: () {
                                    search = false;
                                    setState(() {});
                                  },
                                  child: const Icon(
                                    Icons.cancel,
                                    color: Color(0xffc199cd),
                                  ),
                                )
                              : Icon(Icons.search)),
                    )
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                width: MediaQuery.of(context).size.width,
                height: search
                    ? MediaQuery.of(context).size.height / 1.134
                    : MediaQuery.of(context).size.height / 1.134,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(89, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20)),
                child: search
                    ? ListView(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10,
                        ),
                        primary: false,
                        shrinkWrap: true,
                        children: tempSearchStore.map((element) {
                          return buildResultCard(element);
                        }).toList(),
                      )
                    : ChatRoomList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        if (myUserName == null || data["username"] == null) {
          print("Error: myUserName or username in data is null");
          return;
        }

        search = false;
        setState(() {});
        var chatRoomId = getChatRoomIdbyUsername(myUserName!, data["username"]);

        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, data["username"]],
          "createdAt": FieldValue.serverTimestamp(),
        };

        try {
          await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                name: data["Name"],
                profileurl: data["Photo"],
                username: data["username"],
              ),
            ),
          );
        } catch (e) {
          print("Error creating chat room: $e");
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["Name"] ?? "Unknown Name",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data["username"] ?? "Unknown Username",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black45,
                        fontSize: 16),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      data["Photo"] ?? "https://via.placeholder.com/60",
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

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
        await DatabaseMethods().getUserInfo(username.toLowerCase());
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
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                    name: name, profileurl: "Photo", username: username),
              ));
        },
        titleAlignment: ListTileTitleAlignment.top,
        leading: profilePicUrl == ""
            ? Icon(Icons.person)
            : ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  profilePicUrl,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
        title: Text(
          username,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black, fontSize: 20),
        ),
        subtitle: Text(
          widget.lastMessage,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black45, fontSize: 16),
        ),
        trailing: Text(
          widget.time,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black45, fontSize: 16),
        ),
      ),
    );
  }
}
