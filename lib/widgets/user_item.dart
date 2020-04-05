import 'package:final_project/providers/user.dart';
import 'package:final_project/screens/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(UserDetailsScreen.routeName, arguments: user.id);
      },
      child: GridTile(
        child: Image.asset(
          "twitter-custom-logo.png",
          fit: BoxFit.cover,
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          title: Text(
            user.firstName,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}