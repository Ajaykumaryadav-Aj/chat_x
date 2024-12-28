import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF553370),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "ChatUp",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xffc199cd)),
                  ),
                  Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: const Color(0xFF3a2144),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Icon(
                        Icons.search,
                        color: Color(0xffc199cd),
                      ))
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.134,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(89, 255, 255, 255),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  ListTile(
                    titleAlignment: ListTileTitleAlignment.top,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        "assets/profile.jpeg",
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      "Ajay Kumar",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                    subtitle: Text(
                      "Hello, what are you doing?",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                          fontSize: 16),
                    ),
                    trailing: Text(
                      "4:30 pm",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                          fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    titleAlignment: ListTileTitleAlignment.top,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        "assets/aj2.jpg",
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      "AK Yadav",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                    subtitle: Text(
                      "Hello, what are you doing?",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                          fontSize: 16),
                    ),
                    trailing: Text(
                      "4:00 pm",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
