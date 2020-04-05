import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import './tweet.dart';

class User with ChangeNotifier{
  String id;
  String firstName;
  String lastName;
  String followers;
  String email;
  String userName;
  List<Tweet> tweets;
  String avgLikes;
  String password;
  String gender;

  User({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.password,
    @required this.avgLikes,
    @required this.followers,
    @required this.userName,
    @required this.gender,
    this.tweets,
  });
}
