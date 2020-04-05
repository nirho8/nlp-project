// import 'package:final_project/widgets/http_exception.dart';
// import 'package:flutter/widgets.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class Auth extends ChangeNotifier {
//   String _token;
//   DateTime _expireDate;
//   String _userId;

//   bool get isAuth {
//     return token != null;
//   }

//   String get token {
//     if (_expireDate != null &&
//         _expireDate.isAfter(DateTime.now()) &&
//         _token != null) {
//       return _token;
//     }
//     return null;
//   }

//   Future<void> _authenticate(String email, String password, String key) async {
//     final url =
//         'https://identitytoolkit.googleapis.com/v1/accounts:$key?key=AIzaSyCm28TPiDRKe0yBrT0PT4Y77q80NyamiDI';
//     try {
//       final response = await http.post(url,
//           body: json.encode({
//             'email': email,
//             'password': password,
//             'returnSecureToken': true,
//           }));
//       final responseData = json.decode(response.body);
//       _token = responseData['idToken'];
//       _userId = responseData['localId'];
//       _expireDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
//       notifyListeners();
//       if (responseData['error'] != null) {
//         throw HttpException(responseData['error']['message']);
//       }
//     } catch (error) {
//       throw error;
//     }
//   }

//   Future<void> login(String email, String password) {
//     return _authenticate(email, password, "signInWithPassword");
//   }

//   Future<void> signup(String email, String password) async {
//     return _authenticate(email, password, "signUp");
//   }
// }
