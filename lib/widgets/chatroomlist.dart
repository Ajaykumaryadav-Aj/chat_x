import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui';
import 'dart:ui';
import 'dart:ui';
import 'dart:ui';

import 'package:chat_x/screens/chat_page.dart';
import 'package:chat_x/screens/home.dart';
import 'package:chat_x/screens/sign_up.dart';
import 'package:chat_x/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        await DatabaseMethods().getUserInfo(username.toUpperCase());
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
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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
              ? const Icon(
                  Icons.person,
                  size: 40,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    profilePicUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        title: Text(
          name,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15),
        ),
        subtitle: Text(
          overflow: TextOverflow.ellipsis,
          widget.lastMessage,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black45, fontSize: 16),
        ),
        trailing: Text(
          widget.time,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black45, fontSize: 13),
        ),
      ),
    );
  }
}




















// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:image/image.dart' as img;

// class UploadImageScreen extends StatefulWidget {
//   @override
//   _UploadImageScreenState createState() => _UploadImageScreenState();
// }

// class _UploadImageScreenState extends State<UploadImageScreen> {
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//   bool _isUploading = false;
//   String? _downloadUrl;

//   // Function to pick an image from the gallery
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   // Function to resize the image before uploading (optional step)
//   Future<File> _resizeImage(File imageFile) async {
//     // Read image as bytes
//     final bytes = await imageFile.readAsBytes();
//     // Decode the image using the image package
//     final img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
    
//     if (image == null) {
//       throw Exception("Failed to decode image.");
//     }

//     // Resize the image to a new width (height will scale accordingly)
//     final img.Image resizedImage = img.copyResize(image, width: 800); // Resize to 800px wide
    
//     // Get temporary directory to store resized image
//     final tempDir = await getTemporaryDirectory();
//     final resizedFile = File('${tempDir.path}/resized_image.jpg')
//       ..writeAsBytesSync(img.encodeJpg(resizedImage)); // Save the resized image

//     return resizedFile;
//   }

//   // Function to upload the image to Firebase Storage
//   Future<void> _uploadImage() async {
//     if (_image == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please pick an image first")),
//       );
//       return;
//     }

//     setState(() {
//       _isUploading = true;
//     });

//     try {
//       // Optional: Resize the image before uploading
//       File imageToUpload = await _resizeImage(_image!);

//       // Create a reference to Firebase Storage
//       String fileName = 'profilePics/${DateTime.now().millisecondsSinceEpoch}.jpg';
//       Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

//       // Upload the image to Firebase Storage
//       UploadTask uploadTask = storageRef.putFile(imageToUpload);

//       // Wait for the upload to complete and get the download URL
//       TaskSnapshot taskSnapshot = await uploadTask;

//       // Once uploaded, get the download URL
//       String downloadUrl = await taskSnapshot.ref.getDownloadURL();

//       setState(() {
//         _isUploading = false;
//         _downloadUrl = downloadUrl;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Image uploaded successfully")),
//       );
//       print("Download URL: $downloadUrl");

//       // Pass the download URL to the next screen or use it in your app
//       // You can use the downloadUrl in your registration process, like saving it to Firestore or Shared Preferences

//     } catch (e) {
//       setState(() {
//         _isUploading = false;
//       });
//       print("Error uploading image: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to upload image: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Upload Profile Picture")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Display the selected image or a placeholder
//             _image != null
//                 ? Image.file(
//                     _image!,
//                     height: 200,
//                     width: 200,
//                   )
//                 : Container(
//                     height: 200,
//                     width: 200,
//                     color: Colors.grey[300],
//                     child: Icon(
//                       Icons.image,
//                       color: Colors.white,
//                     ),
//                   ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickImage,
//               child: Text("Pick Image from Gallery"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _uploadImage,
//               child: _isUploading
//                   ? CircularProgressIndicator(color: Colors.white)
//                   : Text("Upload Image"),
//             ),
//             if (_downloadUrl != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text("Image URL: $_downloadUrl"),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
