import 'package:final_project/providers/users.dart';
import 'package:final_project/screens/tweet_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';

class HomePageCard extends StatelessWidget {
  final isGuest;
  final isUser;

  HomePageCard({
    this.isGuest = false,
    this.isUser = false,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120.0,
        margin: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 24.0,
        ),
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                isUser ? Navigator.of(context).pushNamed(LoginScreen.routeName) :
                Provider.of<Users>(context, listen: false).loginAnonymous().then((_) => {
                  Navigator.of(context).pushNamed(TweetScreen.routeName)
                });
              },
              child: Container(
                height: 124.0,
                width: 500,
                margin: EdgeInsets.only(left: 46.0),
                child: isGuest
                    ? Center(
                        child: Text(
                          "Continue as guest",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Log-In",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Text(
                            "Users get more accurate predictions",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                decoration: BoxDecoration(
                  color: Color(0xFF333366),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0),
              alignment: FractionalOffset.centerLeft,
              child: ClipOval(
                child: Image(
                  image: AssetImage("assets/twitter-logo.jpg"),
                  height: 92.0,
                  width: 92.0,
                ),
              ),
            ),
          ],
        ));
  }
}
