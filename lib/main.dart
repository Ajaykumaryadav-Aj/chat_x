import 'package:chat_x/screens/home.dart';
import 'package:chat_x/screens/sign_up.dart';
import 'package:chat_x/screens/signin.dart';
import 'package:chat_x/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}


class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  
  Stream<QuerySnapshot>? chatRoomsStream;
  String? myUserName;

  @override
  void initState() {
    super.initState();
    getChatRooms();
  }

  /// ✅ Fetch chat rooms and update state
  void getChatRooms() async {
    myUserName = await SharedPrefHelper().getUserName();  // Get username from shared preferences
    if (myUserName == null) {
      print("⚠️ Error: Username is null.");
      return;
    }

    print("📡 Fetching chat rooms for: $myUserName");

    setState(() {
      chatRoomsStream = FirebaseFirestore.instance
          .collection("chatrooms")
          .where("users", arrayContains: myUserName!)
          .orderBy("lastMessageSendTs", descending: true) // ✅ Correct field for ordering
          .snapshots();
    });
  }

  /// ✅ Chat Room List Widget
  Widget ChatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("⚠️ No chat rooms found.");
          return Center(
            child: Text(
              "No chats available",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          );
        }

        print("📝 Total chat rooms: ${snapshot.data!.docs.length}");
        for (var doc in snapshot.data!.docs) {
          print("💬 Chat Room ID: ${doc.id}, Last Msg: ${doc['lastMessage']}");
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.docs.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];

            return ChatRoomListTile(
              lastMessage: ds["lastMessage"],
              chatRoomId: ds.id,
              myUsername: myUserName!,
              time: ds["lastMessageSendTs"],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat List")),
      body: ChatRoomList(),
    );
  }
}


