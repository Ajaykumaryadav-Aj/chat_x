import 'package:chat_x/screens/home.dart';
import 'package:chat_x/screens/signin.dart';
import 'package:chat_x/service/auth.dart';
import 'package:chat_x/widgets/chatroomlist.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
 const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home:  UploadImageScreen(),
      home: FutureBuilder(
        future: AuthMethods().getcurrentUser(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const SigninScreen();
          }
        },
      ),
    );
  }
}
