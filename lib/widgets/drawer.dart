import 'package:final_project/providers/users.dart';
import 'package:final_project/screens/admin_screen.dart';
import 'package:final_project/widgets/custom_listtile.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../screens/signup_screen.dart';
import '../screens/edit_profile_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: <Color>[
              Colors.lightBlue,
              Colors.lightBlueAccent,
            ]),
          ),
          child: Container(
            child: Column(
              children: <Widget>[
                Material(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.all(3.0),
                    child: ClipOval(
                      child: Image.asset(
                        'twitter-logo.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "Virality",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 35),
                  ),
                ),
              ],
            ),
          ),
        ),
        CustomListTile(
            Icons.home, "Home", () => {Navigator.of(context).pushNamed('/')}),
        CustomListTile(
            Icons.person,
            "Profile",
            () =>
                {Navigator.of(context).pushNamed(EditProfileScreen.routeName)}),
        CustomListTile(EvaIcons.twitter, "Tweets",
            () => {Navigator.of(context).pushReplacementNamed('/user-tweets')}),
        CustomListTile(
            Icons.person_add,
            "Register",
            () => {
                  Navigator.of(context)
                      .pushReplacementNamed(SignUpScreen.routeName)
                }),
        CustomListTile(EvaIcons.people, "Users", () => {
          Provider.of<Users>(context).fetchAndSetUsers(),
          Navigator.of(context).pushNamed(AdminScreen.routeName),
        }),
        CustomListTile(
            Icons.lock,
            "Log Out",
            () => {
                  Provider.of<Users>(context, listen: false).logout(),
                  Navigator.of(context).pop(),
                }),
      ],
    ));
  }
}
