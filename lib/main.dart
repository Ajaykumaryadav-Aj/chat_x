import 'package:chat_x/screens/home.dart';
import 'package:chat_x/screens/signin.dart';
import 'package:chat_x/service/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_x/service/database.dart';
import 'package:chat_x/service/shared_pref.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String? userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUser();
  }

  _loadUser() async {
    userId = await SharedPrefHelper().getUserId();
    if (userId != null) {
      DatabaseMethods().updateUserStatus(userId!, true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (userId != null) {
      if (state == AppLifecycleState.resumed) {
        DatabaseMethods().updateUserStatus(userId!, true);
      } else {
        DatabaseMethods().updateUserStatus(userId!, false);
      }
    }
  }

  @override
  void dispose() {
    if (userId != null) {
      DatabaseMethods().updateUserStatus(userId!, false);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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





































































// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       // home:  SigninScreen(),
//       home: FutureBuilder(
//         future: AuthMethods().getcurrentUser(),
//         builder: (context, AsyncSnapshot<dynamic> snapshot) {
//           if (snapshot.hasData) {
//             return const HomeScreen();
//           } else {
//             return const SigninScreen();
//           }
//         },
//       ),
//     );
//   }
// }