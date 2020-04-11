import 'package:final_project/widgets/user_grid.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  static final routeName = '/admin-screen';
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: () => {Navigator.of(context).pushReplacementNamed('/')},
          child: Text(
            'Virality',
            style: TextStyle(
                height: 500,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      ),
      body: UserGrid(),
    );
  }
}
