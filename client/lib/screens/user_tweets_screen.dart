import 'package:final_project/screens/tweet_screen.dart';
import 'package:final_project/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tweets.dart';
import '../widgets/user_tweet_item.dart';

class UserTweetsScreen extends StatefulWidget {
  static const routeName = "/user-tweets";

  @override
  _UserTweetsScreenState createState() => _UserTweetsScreenState();
}

class _UserTweetsScreenState extends State<UserTweetsScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  initState() {}

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Tweets>(context).fetchAndSetTweets().then((_) => {
            setState(() => {_isLoading = false})
          });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final tweetData = Provider.of<Tweets>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: () => {Navigator.of(context).pushReplacementNamed('/')},
          child: Text(
            'You\'r Tweets',
            style: TextStyle(
                height: 500,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(TweetScreen.routeName);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: tweetData.tweets.length,
                itemBuilder: (_, i) => Column(
                  children: <Widget>[
                    UserTweetItem(
                      tweetData.tweets[i].id,
                      tweetData.tweets[i].date,
                      tweetData.tweets[i].description,
                      tweetData.tweets[i].likes,
                    ),
                    Divider(),
                  ],
                ),
              ),
            ),
            drawer: AppDrawer(),
    );
  }
}
