import 'package:final_project/providers/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserNameBar extends StatelessWidget {
  final String text;
  final String route;
  final IconData icon;

  UserNameBar(
    this.text,
    this.route,
    this.icon,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: () {
          text != "Logout"
              ? Navigator.of(context).pushNamed(route)
              : Provider.of<Users>(context).logout();
          //Navigator.of(context).pushNamed('/');
        },
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              child: Icon(icon),
            ),
            Text(text),
          ],
        ),
      ),
    );
  }
}
