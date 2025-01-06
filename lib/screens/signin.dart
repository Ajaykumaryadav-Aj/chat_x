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
            padding: const EdgeInsets.only(top: 85.0),
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
                  margin: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 20.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.only(top: 30),
                      margin: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 15.0),
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
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(width: 1),
                              ),
                              child: TextFormField(
                                controller: usermailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please Enter Your Email";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: Color(0xFF7f30fe),
                                    )),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Password",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(width: 1),
                                  ),
                                  child: TextFormField(
                                    controller: userPasswordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please Enter Your Password";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        prefixIcon: Icon(
                                          Icons.password,
                                          color: Color(0xFF7f30fe),
                                        )),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForgotPassword(),
                                    ));
                              },
                              child: Container(
                                alignment: Alignment.bottomRight,
                                child: const Text(
                                  "Forget Password?",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
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
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
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
                              builder: (context) => SignUpScreen(),
                            ));
                      },
                      child: Text(
                        "Sign Up Now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(
                              0xFF7f30fe,
                            ),
                            fontSize: 17),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}











// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:chat_x/service/database.dart';
// import 'package:chat_x/service/shared_pref.dart';
// import 'package:chat_x/screens/home.dart';

// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});

//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   bool isLoading = false;

//   // Sign in method
//   signIn() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         isLoading = true;
//       });

//       try {
//         // Firebase Authentication
//         UserCredential userCredential = await FirebaseAuth.instance
//             .signInWithEmailAndPassword(
//                 email: emailController.text, password: passwordController.text);

//         // Query Firestore to get user data
//         QuerySnapshot userSnapshot =
//             await DatabaseMethods().getUserbyemail(emailController.text);

//         if (userSnapshot.docs.isNotEmpty) {
//           // User data found
//           Map<String, dynamic> userData = userSnapshot.docs[0].data() as Map<String, dynamic>;

//           // Save user data in shared preferences
//           await SharedPrefHelper().saveUserId(userData["Id"]);
//           await SharedPrefHelper().saveUserDisplayName(userData["Name"]);
//           await SharedPrefHelper().saveUserEmail(userData["Email"]);
//           await SharedPrefHelper().saveUserPic(userData["Photo"]);
//           await SharedPrefHelper().saveUserName(userData["username"]);

//           // Navigate to HomeScreen
//           Navigator.pushReplacement(
//               context, MaterialPageRoute(builder: (context) => HomeScreen()));
//         } else {
//           // No user data found
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text(
//               "No user data found for the provided email",
//               style: TextStyle(fontSize: 18),
//             ),
//             backgroundColor: Colors.red,
//           ));
//         }
//       } on FirebaseAuthException catch (e) {
//         // Handle Firebase Auth exceptions
//         if (e.code == 'user-not-found') {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text(
//               "No user found for the provided email",
//               style: TextStyle(fontSize: 18),
//             ),
//             backgroundColor: Colors.red,
//           ));
//         } else if (e.code == 'wrong-password') {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text(
//               "Incorrect password",
//               style: TextStyle(fontSize: 18),
//             ),
//             backgroundColor: Colors.orange,
//           ));
//         }
//       } catch (e) {
//         // Handle general exceptions
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(
//             "An error occurred: ${e.toString()}",
//             style: const TextStyle(fontSize: 18),
//           ),
//           backgroundColor: Colors.red,
//         ));
//       } finally {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 100),
//                     const Center(
//                       child: Text(
//                         "Sign In",
//                         style: TextStyle(
//                             fontSize: 30, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           TextFormField(
//                             controller: emailController,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return "Please enter your email";
//                               }
//                               if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
//                                   .hasMatch(value)) {
//                                 return "Please enter a valid email";
//                               }
//                               return null;
//                             },
//                             decoration: const InputDecoration(
//                                 labelText: "Email",
//                                 prefixIcon: Icon(Icons.email)),
//                           ),
//                           const SizedBox(height: 20),
//                           TextFormField(
//                             controller: passwordController,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return "Please enter your password";
//                               }
//                               return null;
//                             },
//                             obscureText: true,
//                             decoration: const InputDecoration(
//                                 labelText: "Password",
//                                 prefixIcon: Icon(Icons.lock)),
//                           ),
//                           const SizedBox(height: 40),
//                           GestureDetector(
//                             onTap: signIn,
//                             child: Container(
//                               padding: const EdgeInsets.all(15),
//                               alignment: Alignment.center,
//                               width: MediaQuery.of(context).size.width,
//                               decoration: BoxDecoration(
//                                 color: Colors.blue,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: const Text(
//                                 "Sign In",
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 18),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }









// import 'package:chat_x/screens/home.dart';
// import 'package:chat_x/service/database.dart';
// import 'package:chat_x/service/shared_pref.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class SigninScreen extends StatefulWidget {
//   const SigninScreen({super.key});

//   @override
//   State<SigninScreen> createState() => _SigninScreenState();
// }

// class _SigninScreenState extends State<SigninScreen> {
//   String email = "", password = "";
//   TextEditingController usermailController = TextEditingController();
//   TextEditingController userPasswordController = TextEditingController();

//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;

//   Future<void> userLogin() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Firebase Authentication
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: email, password: password);

//       // Fetch user details from Firestore
//       QuerySnapshot querySnapshot =
//           await DatabaseMethods().getUserbyemail(email);

//       if (querySnapshot.docs.isEmpty) {
//         throw Exception("No user data found for the provided email.");
//       }

//       final userDoc = querySnapshot.docs[0];
//       String name = userDoc['Name'] ?? 'Unknown';
//       String username = userDoc['username'] ?? 'Unknown';
//       String pic = userDoc['Photo'] ?? '';
//       String id = userDoc.id;

//       // Save data locally
//       await SharedPrefHelper().saveUserDisplayName(name);
//       await SharedPrefHelper().saveUserName(username);
//       await SharedPrefHelper().saveUserId(id);
//       await SharedPrefHelper().saveUserPic(pic);

//       // Navigate to Home Screen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const HomeScreen(),
//         ),
//       );
//     } on FirebaseAuthException catch (e) {
//       // Handle Firebase-specific exceptions
//       String message = e.code == "user-not-found"
//           ? "No User Found for that Email"
//           : e.code == "wrong-password"
//               ? "Wrong Password provided"
//               : "An error occurred: ${e.message}";

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         backgroundColor: Colors.orangeAccent,
//         content: Text(
//           message,
//           style: const TextStyle(fontSize: 18, color: Colors.black),
//         ),
//       ));
//     } catch (e) {
//       // Handle other exceptions
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         backgroundColor: Colors.redAccent,
//         content: Text(
//           "An unexpected error occurred: $e",
//           style: const TextStyle(fontSize: 18, color: Colors.white),
//         ),
//       ));
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Header Gradient
//             Container(
//               height: MediaQuery.of(context).size.height / 3.5,
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF7f30fe), Color(0xFF6380fb)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.vertical(
//                   bottom: Radius.elliptical(105, 75.0),
//                 ),
//               ),
//               child: const Center(
//                 child: Text(
//                   "Sign In",
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Login Form
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Material(
//                 elevation: 5.0,
//                 borderRadius: BorderRadius.circular(10),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 20.0, horizontal: 15.0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Email",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8.0),
//                         TextFormField(
//                           controller: usermailController,
//                           decoration: const InputDecoration(
//                             border: OutlineInputBorder(),
//                             prefixIcon: Icon(Icons.email, color: Color(0xFF7f30fe)),
//                             hintText: "Enter your email",
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return "Please enter your email";
//                             }
//                             if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
//                                 .hasMatch(value)) {
//                               return "Please enter a valid email";
//                             }
//                             return null;
//                           },
//                           onChanged: (value) => email = value.trim(),
//                         ),
//                         const SizedBox(height: 20),
//                         const Text(
//                           "Password",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8.0),
//                         TextFormField(
//                           controller: userPasswordController,
//                           obscureText: true,
//                           decoration: const InputDecoration(
//                             border: OutlineInputBorder(),
//                             prefixIcon:
//                                 Icon(Icons.lock, color: Color(0xFF7f30fe)),
//                             hintText: "Enter your password",
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return "Please enter your password";
//                             }
//                             if (value.length < 6) {
//                               return "Password must be at least 6 characters long";
//                             }
//                             return null;
//                           },
//                           onChanged: (value) => password = value.trim(),
//                         ),
//                         const SizedBox(height: 20),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton(
//                             onPressed: () {
//                               // Handle "Forget Password" logic
//                             },
//                             child: const Text(
//                               "Forget Password?",
//                               style: TextStyle(fontWeight: FontWeight.w500),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                         isLoading
//                             ? const Center(child: CircularProgressIndicator())
//                             : GestureDetector(
//                                 onTap: userLogin,
//                                 child: Container(
//                                   width: double.infinity,
//                                   padding: const EdgeInsets.all(15),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF6380fb),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: const Text(
//                                     "Sign In",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 20),
//                                   ),
//                                 ),
//                               ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 15),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Don't have an account? ",
//                   style: TextStyle(fontSize: 15),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     // Navigate to Sign Up Screen
//                   },
//                   child: const Text(
//                     "Sign Up Now",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF7f30fe),
//                         fontSize: 17),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
