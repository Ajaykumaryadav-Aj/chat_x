import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfo, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfo);
  }

  Future<QuerySnapshot> getUserbyemai(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("E-mail,", isEqualTo: email)
        .get();
  }
}
