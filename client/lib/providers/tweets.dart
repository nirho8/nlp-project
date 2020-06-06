import 'package:final_project/widgets/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import './tweet.dart';

class Tweets with ChangeNotifier {
  List<Tweet> _tweets = [];
  final token;
  final userId;

  Tweets(this.token, this.userId, this._tweets);

  List<Tweet> get tweets {
    return [..._tweets];
  }

  Future<void> fetchAndSetTweets() async {
    final url =
        'https://flutter-app-bcd43.firebaseio.com/tweets.json?auth=$token&orderBy="creator"&equalTo="$userId"';
    try {
      final response = await http.get(url);
      final extracteData = json.decode(response.body) as Map<String, dynamic>;
      final List<Tweet> loadedTweets = [];
      extracteData.forEach((tweetId, value) {
        loadedTweets.add(Tweet(
          id: tweetId,
          description: value["description"],
          date: value["date"],
          likes: value["like"],
        ));
      });
      _tweets = loadedTweets;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<String> addTweet(Tweet tweet, String userName, bool toPredict) async {
    print(userName);
    var likes;
    if (toPredict) {
      final serverUrl = 'http://localhost:5000/tweet_prediction';
      final serverAnswer = await http.post(serverUrl,
          body: json.encode({
            "tweet": tweet.description,
            "time": DateFormat.jm().format(DateTime.now()),
            "user": userName,
          }),
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          });
      likes = json.decode(serverAnswer.body)["like"];
    }

    final noneUser = token != null ? '?auth=$token' : '';
    final url = 'https://flutter-app-bcd43.firebaseio.com/tweets.json$noneUser';
    return http
        .post(url,
            body: json.encode({
              "description": tweet.description,
              "like": likes,
              "date": tweet.date,
              "creator": userId,
            }))
        .then((response) {
      final newTweet = Tweet(
        id: json.decode(response.body)['name'],
        description: tweet.description,
        likes: tweet.likes,
        date: tweet.date,
        creator: userId,
      );

      _tweets.add(newTweet);
      notifyListeners();
      return likes;
    });
  }

  Tweet deleteTweet(String id) {
    final url =
        'https://flutter-app-bcd43.firebaseio.com/tweets/$id.json?auth=$token';
    final tweetIndex = _tweets.indexWhere((element) => element.id == id);
    var tweet = _tweets[tweetIndex];
    _tweets.removeAt(tweetIndex);
    notifyListeners();
    http
        .delete(url)
        .then((response) => {
              if (response.statusCode >= 400)
                {throw HttpException("Could not delete this tweet!")}
            })
        .catchError((_) {
      _tweets.insert(tweetIndex, tweet);
      notifyListeners();
    });
    return tweet;
  }
}
