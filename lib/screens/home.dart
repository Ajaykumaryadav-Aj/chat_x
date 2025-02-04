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
                itemCount: snapshot.data!.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data!.docs[index];
                  return ChatRoomListTile(
                      chatRoomId: ds.id,
                      lastMessage: ds["lastMessage"],
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
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          primary: false,
                          shrinkWrap: true,
                          children: tempSearchStore.map((element) {
                            return buildResultCard(element);
                          }).toList(),
                        )
                      : ChatRoomList())
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
                    name: name, profileurl: profilePicUrl, username: username),
              ));
        },
        titleAlignment: ListTileTitleAlignment.top,
        leading: SizedBox(
          width: 60,
          child: profilePicUrl == ""
              ? Icon(
                  Icons.person,
                  size: 40,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    profilePicUrl,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        title: Text(
          username,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15),
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









// import 'package:chat_x/screens/home.dart';
// import 'package:chat_x/screens/signin.dart';
// import 'package:chat_x/service/database.dart';
// import 'package:chat_x/service/shared_pref.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:random_string/random_string.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   String email = "", password = "", name = "", confirmPassword = "";
//   final _formkey = GlobalKey<FormState>();

//   TextEditingController mailcontroller = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController confirmController = TextEditingController();

//   registration() async {
//     if (password != null && password == confirmPassword) {
//       try {
//         UserCredential userCredential = await FirebaseAuth.instance
//             .createUserWithEmailAndPassword(email: email, password: password);
//         String Id = randomAlphaNumeric(10);
//         String user = mailcontroller.text.replaceAll("@gmail.com", "");
//         String updateusername =
//             user.replaceFirst(user[0], user[0].toUpperCase());
//         String firstletter = user.substring(0, 1).toUpperCase();
//         Map<String, dynamic> userInfoMap = {
//           "Name": nameController.text,
//           "Email": mailcontroller.text,
//           "username": updateusername.toUpperCase(),
//           "SearchKey": firstletter,
//           "Photo":
//               "https://cdn2.psychologytoday.com/assets/styles/manual_crop_1_1_1200x1200/public/field_blog_entry_images/2018-09/shutterstock_648907024.jpg?itok=1-9sfjwH",
//           "Id": Id,
//         };

//         await DatabaseMethods().addUserDetails(userInfoMap, Id);
//         await SharedPrefHelper().saveUserId(Id);
//         await SharedPrefHelper().saveUserDisplayName(nameController.text);
//         await SharedPrefHelper().saveUserEmail(mailcontroller.text);
//         await SharedPrefHelper().saveUserPic(
//             "https://cdn2.psychologytoday.com/assets/styles/manual_crop_1_1_1200x1200/public/field_blog_entry_images/2018-09/shutterstock_648907024.jpg?itok=1-9sfjwH");
//         await SharedPrefHelper().saveUserName(
//             mailcontroller.text.replaceAll("@gmail.com", "").toUpperCase());

//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text(
//           "Registered Successfully",
//           style: TextStyle(fontSize: 20),
//         )));
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HomeScreen(),
//             ));
//       } on FirebaseAuthException catch (e) {
//         if (e.code == 'weak-password') {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//               content: Text(
//             "Password provided is too weak",
//             style: TextStyle(fontSize: 18),
//           )));
//         } else if (e.code == 'email-already-in-use') {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//               backgroundColor: Colors.orangeAccent,
//               content: Text(
//                 "Account Already exists",
//                 style: TextStyle(fontSize: 18.0),
//               )));
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Container(
//       height: MediaQuery.of(context).size.height, // Use full height of screen
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               children: [
//                 Container(
//                   height: MediaQuery.of(context).size.height /
//                       3.5, // Adjust based on screen height
//                   width: MediaQuery.of(context).size.width,
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Color(0xFF7f30fe), Color(0xFF6380fb)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.vertical(
//                       bottom: Radius.elliptical(105, 75.0),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(
//                       top: MediaQuery.of(context).size.height *
//                           0.1), // Adjust top padding dynamically
//                   child: Column(
//                     children: [
//                       const Center(
//                         child: Text(
//                           "SignUp",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20),
//                         ),
//                       ),
//                       const Center(
//                         child: Text(
//                           "Create a new account",
//                           style: TextStyle(
//                               color: Color(0xFFbbb0ff),
//                               fontWeight: FontWeight.w500,
//                               fontSize: 17),
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.symmetric(
//                             vertical: MediaQuery.of(context).size.height *
//                                 0.02, // Adjust vertical margin dynamically
//                             horizontal: MediaQuery.of(context).size.width *
//                                 0.05), // Adjust horizontal margin dynamically
//                         child: Material(
//                           elevation: 5.0,
//                           borderRadius: BorderRadius.circular(10),
//                           child: SingleChildScrollView(
//                             child: Container(
//                               padding: EdgeInsets.only(
//                                   top: MediaQuery.of(context).size.height *
//                                       0.03), // Adjust top padding dynamically
//                               margin: EdgeInsets.symmetric(
//                                   vertical: MediaQuery.of(context).size.height *
//                                       0.02, // Adjust vertical margin dynamically
//                                   horizontal: MediaQuery.of(context)
//                                           .size
//                                           .width *
//                                       0.04), // Adjust horizontal margin dynamically
//                               height: MediaQuery.of(context).size.height /
//                                   1.5, // Adjust height dynamically
//                               width: MediaQuery.of(context).size.width,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Form(
//                                 key: _formkey,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       "Name",
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8.0),
//                                     Container(
//                                       padding: const EdgeInsets.only(left: 10),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(10),
//                                         border: Border.all(width: 1),
//                                       ),
//                                       child: TextFormField(
//                                         controller: nameController,
//                                         validator: (value) {
//                                           if (value == null || value.isEmpty) {
//                                             return "Please enter your name";
//                                           }
//                                           return null;
//                                         },
//                                         decoration: InputDecoration(
//                                             border: InputBorder.none,
//                                             prefixIcon: Icon(
//                                               Icons.person,
//                                               color: Color(0xFF7f30fe),
//                                             )),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     const Text(
//                                       "Email",
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8.0),
//                                     Container(
//                                       padding: const EdgeInsets.only(left: 10),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(10),
//                                         border: Border.all(width: 1),
//                                       ),
//                                       child: TextFormField(
//                                         controller: mailcontroller,
//                                         validator: (value) {
//                                           if (value == null || value.isEmpty) {
//                                             return "Please enter your Email";
//                                           }
//                                           return null;
//                                         },
//                                         decoration: const InputDecoration(
//                                             border: InputBorder.none,
//                                             prefixIcon: Icon(
//                                               Icons.email,
//                                               color: Color(0xFF7f30fe),
//                                             )),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 20),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const Text(
//                                           "Password",
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8.0),
//                                         Container(
//                                           padding:
//                                               const EdgeInsets.only(left: 10),
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             border: Border.all(width: 1),
//                                           ),
//                                           child: TextFormField(
//                                             controller: passwordController,
//                                             validator: (value) {
//                                               if (value == null ||
//                                                   value.isEmpty) {
//                                                 return "Please enter your Passwor";
//                                               }
//                                               return null;
//                                             },
//                                             decoration: InputDecoration(
//                                                 border: InputBorder.none,
//                                                 prefixIcon: Icon(
//                                                   Icons.password,
//                                                   color: Color(0xFF7f30fe),
//                                                 )),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 10),
//                                         const Text(
//                                           "Confirm Password",
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8.0),
//                                         Container(
//                                           padding:
//                                               const EdgeInsets.only(left: 10),
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             border: Border.all(width: 1),
//                                           ),
//                                           child: TextFormField(
//                                             controller: confirmController,
//                                             validator: (value) {
//                                               if (value == null ||
//                                                   value.isEmpty) {
//                                                 return "Please enter your confirm password";
//                                               }
//                                               return null;
//                                             },
//                                             decoration: InputDecoration(
//                                                 border: InputBorder.none,
//                                                 prefixIcon: Icon(
//                                                   Icons.password_rounded,
//                                                   color: Color(0xFF7f30fe),
//                                                 )),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 35),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Text(
//                                               "Don't have an account? ",
//                                               style: TextStyle(
//                                                 fontSize: 15,
//                                               ),
//                                             ),
//                                             GestureDetector(
//                                               onTap: () {
//                                                 Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           SigninScreen(),
//                                                     ));
//                                               },
//                                               child: const Text(
//                                                 "Sign In Now",
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Color(
//                                                       0xFF7f30fe,
//                                                     ),
//                                                     fontSize: 17),
//                                               ),
//                                             )
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 30),
//             GestureDetector(
//               onTap: () {
//                 if (_formkey.currentState!.validate()) {
//                   setState(() {
//                     email = mailcontroller.text;
//                     name = nameController.text;
//                     password = passwordController.text;
//                     confirmPassword = confirmController.text;
//                   });
//                 }
//                 registration();
//               },
//               child: Center(
//                 child: Material(
//                   elevation: 5,
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     margin: const EdgeInsets.symmetric(horizontal: 20),
//                     width: MediaQuery.of(context).size.width,
//                     decoration: BoxDecoration(
//                         color: const Color(0xFF6380fb),
//                         borderRadius: BorderRadius.circular(10)),
//                     child: const Text(
//                       "SignUp",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
// }
