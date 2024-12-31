import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF553370),
        body: Container(
          margin: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Color(0xffc199cd),
                  ),
                  SizedBox(width: 100),
                  Text(
                    "Ajay Kumar",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xffc199cd),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.13,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 2),
                      alignment: Alignment.bottomRight,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 194, 197, 204),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        "How are you?????????????????",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width / 2),
                      alignment: Alignment.bottomLeft,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 183, 194, 228),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        "I am Fine bro.",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Spacer(),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.only(left: 10.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Type a message"),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    color: Color(0xFFf3f3f3),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Icon(Icons.send))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
