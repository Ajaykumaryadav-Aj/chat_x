
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static String userIdKey = "USERKEY";
  static String usernameKey = "USERNAMEKEY";
  static String userEmailKey = "USERMAILKEY";
  static String userPickey = "USERPICKEY";
  static String displaynameKey = "USERDISPLAYNAME";

  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(usernameKey, getUserName);
  }

  Future<bool> saveUserPic(String getUserPic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userPickey, getUserPic);
  }

  Future<bool> saveUserDisplayName(String getUserDisplayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(displaynameKey, getUserDisplayName);
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserPic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPickey);
  }

  Future<String?> getUserDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(displaynameKey);
  }
}











































































// import 'package:shared_preferences/shared_preferences.dart';

// class SharedPrefHelper {
//   static String userIdKey = "USERKEY";
//   static String usernameKey = "USERNAMEKEY";
//   static String userEmailKey = "USERMAILKEY";
//   static String userPickey = "USERPICKEY";
//   static String displaynameKey = "USERDISPLAYNAME";

//   Future<bool> saveUserId(String getUserId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.setString(userIdKey, getUserId);
//   }

//   Future<bool> saveUserEmail(String getUserEmail) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.setString(userEmailKey, getUserEmail);
//   }

//   Future<bool> saveUserName(String getUserName) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.setString(usernameKey, getUserName);
//   }

//   Future<bool> saveUserPic(String getUserPic) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.setString(userPickey, getUserPic);
//   }

//   Future<bool> saveUserDisplayName(String getUserDisplayName) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.setString(displaynameKey, getUserDisplayName);
//   }

//   Future<String?> getUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(userIdKey);
//   }

//   Future<String?> getUserName() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(usernameKey);
//   }

//   Future<String?> getUserEmail() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(userEmailKey);
//   }

//   Future<String?> getUserPic() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(userPickey);
//   }

//   Future<String?> getUserDisplayName() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(displaynameKey);
//   }
// }
