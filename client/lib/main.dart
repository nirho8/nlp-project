import 'package:final_project/providers/auth.dart';
import 'package:final_project/providers/tweets.dart';
import 'package:final_project/providers/users.dart';
import 'package:final_project/screens/admin_screen.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:final_project/screens/tweet_screen.dart';
import 'package:final_project/screens/un_login_home.dart';
import 'package:final_project/screens/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/user_tweets_screen.dart';
import './screens/edit_profile_screen.dart';
import './screens/tweet_screen.dart';
import './screens/signup_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider.value(
        //   value: Auth(),
        // ),
        ChangeNotifierProvider.value(
          value: Users(),
        ),
        ChangeNotifierProxyProvider<Users, Tweets>(
          builder: (ctx, auth, previousTweet) => Tweets(
            auth.token,
            auth.userId,
            previousTweet == null ? [] : previousTweet.tweets,
          ),
        ),
      ],
      child: Consumer<Users>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Welcome to Flutter',
          theme: ThemeData(
            primaryColor: Colors.lightBlue,
            primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),
          ),
          home: auth.isAuth ? TweetScreen() : UnLoginHomePage(),
          routes: {
            UserTweetsScreen.routeName: (ctx) => UserTweetsScreen(),
            EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
            TweetScreen.routeName: (ctx) => TweetScreen(),
            LoginScreen.routeName: (ctx) => LoginScreen(),
            SignUpScreen.routeName: (ctx) => SignUpScreen(),
            UnLoginHomePage.routeName: (ctx) => UnLoginHomePage(),
            AdminScreen.routeName: (ctx) => AdminScreen(),
            UserDetailsScreen.routeName: (ctx) => UserDetailsScreen()
          },
        ),
      ),
    );
  }
}
