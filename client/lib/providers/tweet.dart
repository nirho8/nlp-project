import 'package:flutter/material.dart';

class Tweet with ChangeNotifier{
  final String id;
  final String description;
  final int likes;
  final String date;
  final String creator;

  Tweet({
    @required this.id,
    @required this.description,
    @required this.likes,
    @required this.date,
    this.creator,
  });
}
