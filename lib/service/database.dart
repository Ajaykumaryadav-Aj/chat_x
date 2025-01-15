import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfo, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfo);
  }

  Future<QuerySnapshot> getUserbyemail(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("Email", isEqualTo: email)
        .get();
  }

  Future<QuerySnapshot> Search(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("SearchKey", isEqualTo: username.substring(0, 1).toUpperCase())
        .get();
  }

  // createChatRoom(
  //     String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection("chatrooms")
  //       .doc(chatRoomId)
  //       .get();
  //   if (snapshot.exists) {
  //     return true;
  //   } else {
  //     return FirebaseFirestore.instance
  //         .collection("chatrooms")
  //         .doc(chatRoomId)
  //         .set(chatRoomInfoMap);
  //   }
  // }

 Future<bool> createChatRoom(
    String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
  try {
    print("Checking chat room with ID: $chatRoomId");
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapshot.exists) {
      print("Chat room already exists");
      return true;
    } else {
      print("Creating new chat room with data: $chatRoomInfoMap");
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
      print("Chat room created successfully");
      return true;
    }
  } catch (e) {
    print("Error creating chat room: $e");
    return false;
  }
}

}
