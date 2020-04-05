import 'package:final_project/providers/tweets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserTweetItem extends StatelessWidget {
  final String date;
  final String description;
  final int likes;
  final String id;

  UserTweetItem(this.id, this.date, this.description, this.likes);

  @override
  Widget build(BuildContext context) {
    final tweetProvider = Provider.of<Tweets>(context, listen: false);
    return Container(
      width: MediaQuery.of(context).size.height * 1.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ListTile(
            title: Text(description),
            leading: CircleAvatar(
              child: ClipOval(child: Image.asset('assets/twitter-logo.jpg')),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Likes: ${likes.toString()}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(date),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () {
                    var deletedTweet = tweetProvider.deleteTweet(id);
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Tweet deleted'),
                      action: SnackBarAction(label: 'Undo', onPressed: () {
                        tweetProvider.addTweet(deletedTweet);
                      }),
                    ));
                  },
                  color: Theme.of(context).errorColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
