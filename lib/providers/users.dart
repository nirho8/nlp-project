import 'dart:async';
import 'dart:convert';
import 'package:final_project/widgets/http_exception.dart';
import 'package:flutter/material.dart';
import './user.dart';
import 'package:http/http.dart' as http;

class Users with ChangeNotifier {
  String _token;
  DateTime _expireDate;
  String _userId;
  Timer _authTimer;
  User loggedUser;

  List<User> _users = [];

  List<User> get users {
    return [..._users];
  }

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expireDate != null &&
        _expireDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<User> findUserById(String id) async {
    final url =
        'https://flutter-app-bcd43.firebaseio.com/users/$id.json?auth=$token';
    final response = await http.get(url);
    final responseData = json.decode(response.body);
    loggedUser = User(
      id: responseData['id'],
      firstName: responseData['firstname'],
      lastName: responseData['lastname'],
      email: responseData['email'],
      password: '',
      avgLikes: responseData['avgLikes'],
      followers: responseData['followers'],
      userName: responseData['username'],
      gender: responseData['gender'],
    );
    notifyListeners();
    return loggedUser;
  }

  User findById(String id) {
    return _users.firstWhere((element) => element.id == id, orElse: null);
  }

  Future<void> fetchAndSetUsers() async {
    final url =
        'https://flutter-app-bcd43.firebaseio.com/users.json?auth=$token';
    try {
      final response = await http.get(url);
      final extracteData = json.decode(response.body) as Map<String, dynamic>;
      final List<User> loadedUsers = [];
      extracteData.forEach((userId, value) {
        loadedUsers.add(User(
          id: userId,
          firstName: value["firstname"],
          lastName: value["lastname"],
          email: value["email"],
          gender: value['gender'],
          followers: value['followers'],
          avgLikes: value['avgLikes'],
          password: value["password"],
          userName: value["username"],
          tweets: value['tweets'],
        ));
      });
      _users = loadedUsers;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  void _addUser(User user) async {
    final url =
        'https://flutter-app-bcd43.firebaseio.com/users/$_userId.json?auth=$token';
    await http.put(url,
        body: json.encode({
          'id': _userId,
          'email': user.email,
          'firstname': user.firstName,
          'lastname': user.lastName,
          'gender': user.gender,
          'followers': user.followers,
          'avgLikes': user.avgLikes,
          'username': user.userName,
          'tweets': user.tweets,
        }));
    notifyListeners();
    loggedUser = user;
    _users.add(user);
  }

  Future<void> _authenticate(User user, String key) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$key?key=AIzaSyCm28TPiDRKe0yBrT0PT4Y77q80NyamiDI';
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': user.email,
            'password': user.password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final newUser = User(
        id: _userId,
        firstName: user.userName,
        lastName: user.lastName,
        email: user.email,
        password: user.password,
        avgLikes: user.avgLikes,
        followers: user.followers,
        userName: user.userName,
        gender: user.gender,
      );
      _autoLogout();
      if (key.contains('signUp') && user.email != null) {
        _addUser(newUser);
      }
      if (key.contains("signIn")) {
        await findUserById(_userId);
      }
      if(key.contains('signUp') && user.email == null) {
        notifyListeners();
      }
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(User user) {
    return _authenticate(user, "signInWithPassword");
  }

  Future<void> loginAnonymous() {
    final user = User(
        id: null,
        firstName: null,
        lastName: null,
        email: null,
        password: null,
        avgLikes: null,
        followers: null,
        userName: null,
        gender: null);
    return _authenticate(user, "signUp");
  }

  Future<void> signup(User user) async {
    return _authenticate(user, "signUp");
  }

  void logout() {
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    loggedUser = null;
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpire = _expireDate.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpire), logout);
  }
}
