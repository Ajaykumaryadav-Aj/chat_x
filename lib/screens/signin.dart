import 'package:chat_x/screens/forgot_password.dart';
import 'package:chat_x/screens/home.dart';
import 'package:chat_x/screens/sign_up.dart';
import 'package:chat_x/service/database.dart';
import 'package:chat_x/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  String email = "", password = "", name = "", pic = "", username = "", id = "";
  TextEditingController usermailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      QuerySnapshot querySnapshot =
          await DatabaseMethods().getUserbyemail(email);

      name = "${querySnapshot.docs[0]['Name']}";
      username = "${querySnapshot.docs[0]['username']}";
      pic = "${querySnapshot.docs[0]['Photo']}";
      id = querySnapshot.docs[0].id;
      await SharedPrefHelper().saveUserDisplayName(name);
      await SharedPrefHelper().saveUserName(username);
      await SharedPrefHelper().saveUserId(id);

      await SharedPrefHelper().saveUserPic(pic);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 18, color: Colors.black),
            )));
      } else if (e.code == "wrong-password") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong Password Provide by User",
              style: TextStyle(fontSize: 18, color: Colors.black),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3.5,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7f30fe), Color(0xFF6380fb)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(105, 75.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      "SignIn",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Login to your account",
                      style: TextStyle(
                          color: Color(0xFFbbb0ff),
                          fontWeight: FontWeight.w500,
                          fontSize: 17),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.04,
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.02),
                          margin: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.03),
                          height: MediaQuery.of(context).size.height / 2,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Email",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: usermailController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please Enter Your Email";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Color(0xFF7f30fe),
                                      )),
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Password",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    TextFormField(
                                      controller: userPasswordController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter Your Password";
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          prefixIcon: Icon(
                                            Icons.password,
                                            color: Color(0xFF7f30fe),
                                          )),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgotPassword(),
                                        ));
                                  },
                                  child: Container(
                                    alignment: Alignment.bottomRight,
                                    child: const Text(
                                      "Forget Password?",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                GestureDetector(
                                  onTap: () {
                                    if (_formkey.currentState!.validate()) {
                                      setState(() {
                                        email = usermailController.text;
                                        password = userPasswordController.text;
                                      });
                                    }
                                    userLogin();
                                  },
                                  child: Center(
                                    child: Material(
                                      elevation: 5,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        width: 128,
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF6380fb),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Text(
                                          "SignIn",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ));
                        },
                        child: const Text(
                          "Sign Up Now",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(
                                0xFF7f30fe,
                              ),
                              fontSize: 15),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
