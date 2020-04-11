import 'package:final_project/widgets/home_page_card.dart';
import 'package:flutter/material.dart';

class UnLoginHomePage extends StatelessWidget {
  static const routeName = '/un-login';

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Container(
          width: width / 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Virality",
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 50,
                height: 50,
              ),
              Text(
                "Come and find how viral you can be!",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 30.0,
                height: 30.0,
              ),
              HomePageCard(
                isUser: true,
              ),
              HomePageCard(
                isGuest: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
