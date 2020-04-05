import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:final_project/providers/tweet.dart';
import 'package:final_project/providers/tweets.dart';
import 'package:final_project/providers/users.dart';
import 'package:final_project/screens/edit_profile_screen.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:final_project/screens/signup_screen.dart';
import 'package:final_project/widgets/drawer.dart';
import 'package:final_project/widgets/user_name_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TweetScreen extends StatefulWidget {
  static const routeName = "/tweet-screen";
  @override
  _TweetScreenState createState() => _TweetScreenState();
}

class _TweetScreenState extends State<TweetScreen> {
  final _form = GlobalKey<FormState>();
  bool isLike = true;
  var isLoading = false;
  var saveTheForm = false;

  var _tweet = Tweet(
    id: null,
    description: '',
    likes: 0,
    date: DateFormat.yMMMd().format(new DateTime.now()),
  );

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() => isLoading = true);
    Provider.of<Tweets>(context, listen: false).addTweet(_tweet).then((_) {
      setState(() => isLoading = false);
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final isAuth = Provider.of<Users>(context).isAuth;
    final userProvider = Provider.of<Users>(context, listen: false);
    final loggedInUser = userProvider.loggedUser;
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("twitter-moments.jpg"),
        fit: BoxFit.fill,
      )),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Virality',
            style: TextStyle(
                height: 500, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: loggedInUser != null
              ? <Widget>[
                  UserNameBar(
                    "Hello ${loggedInUser.firstName}",
                    EditProfileScreen.routeName,
                    Icons.edit,
                  ),
                  UserNameBar("Logout", TweetScreen.routeName, EvaIcons.logOut),
                ]
              : <Widget>[
                  UserNameBar(
                    "Hello Guest",
                    LoginScreen.routeName,
                    Icons.person,
                  ),
                  UserNameBar(
                    "Log-In",
                    LoginScreen.routeName,
                    Icons.person_add,
                  ),
                ],
        ),
        backgroundColor: Colors.transparent,
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _form,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: height,
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Tweet',
                              labelStyle: TextStyle(
                                  fontSize: 30, color: Colors.black87),
                              border: OutlineInputBorder()),
                          maxLines: null,
                          enabled: isAuth ? true : false,
                          keyboardType: TextInputType.multiline,
                          onSaved: (value) {
                            _tweet = Tweet(
                              id: _tweet.id,
                              description: value,
                              likes: _tweet.likes,
                              date:
                                  DateFormat.yMMMd().format(new DateTime.now()),
                            );
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please enter a tweet!";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              onPressed: _saveForm,
                              child: Text(
                                'Tweet it',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Colors.lightBlue,
                            )),
                      ],
                    ),
                    isLike
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 8,
                              height: MediaQuery.of(context).size.height / 6,
                              color: Colors.lightBlue[600],
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 50.0, right: 20.0, left: 20.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 6.0, bottom: 6.0),
                                        child: Text(
                                          "You're expected like is",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
        drawer: AppDrawer(),
      ),
    );
  }
}
