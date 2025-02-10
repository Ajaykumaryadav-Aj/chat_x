import 'package:chat_x/screens/home.dart';
import 'package:chat_x/screens/sign_up.dart';
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
      // home:  ProfilePicScreen(),
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




// Import Signup Screen

// class ProfilePicScreen extends StatefulWidget {
//   @override
//   _ProfilePicScreenState createState() => _ProfilePicScreenState();
// }

// class _ProfilePicScreenState extends State<ProfilePicScreen> {
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//   bool _isUploading = false;
//   String? _imageUrl;

//   // Pick image from gallery
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   // Upload image to Firebase Storage
//   Future<void> _uploadImage() async {
//     if (_image == null) return;

//     setState(() {
//       _isUploading = true;
//     });

//     try {
//       String fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";
//       Reference ref = FirebaseStorage.instance.ref().child("profile_pics/$fileName");

//       UploadTask uploadTask = ref.putFile(_image!);
//       TaskSnapshot snapshot = await uploadTask;
//       String downloadUrl = await snapshot.ref.getDownloadURL();

//       setState(() {
//         _imageUrl = downloadUrl;
//         _isUploading = false;
//       });

//       // Navigate to SignUpScreen with the uploaded image URL
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SignUpScreen(profileImageUrl: _imageUrl),
//         ),
//       );
//     } catch (e) {
//       print("Error uploading image: $e");
//       setState(() {
//         _isUploading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Select Profile Picture")),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           GestureDetector(
//             onTap: _pickImage,
//             child: CircleAvatar(
//               radius: 60,
//               backgroundImage: _image != null
//                   ? FileImage(_image!)
//                   : const NetworkImage("https://cdn-icons-png.flaticon.com/512/149/149071.png") as ImageProvider,
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text("Tap to select profile picture"),
//           const SizedBox(height: 20),
//           _isUploading
//               ? const CircularProgressIndicator()
//               : ElevatedButton(
//                   onPressed: _uploadImage,
//                   child: const Text("Upload & Continue"),
//                 ),
//         ],
//       ),
//     );
//   }
// }
