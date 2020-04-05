# Download the data

from typing import List
import os
import pickle
import time

import tweepy
import pandas as pd


ACCOUNTS_FILE_PATH = r"C:\Users\USER\Documents\college\semester 4\NLP\HW\project\gender-classifier-DFE-791531.csv"
DEST_DIR = r"C:\Users\USER\Documents\college\semester 5\final_project\my\code\data"
MAX_TWEETS_PER_USER = 200
consumer_key = ""
consumer_secret = ""
access_key = ""
access_secret = ""


def get_account_tweets(screen_name: str) -> list:
    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_key, access_secret)
    api = tweepy.API(auth)
    tweets = api.user_timeline(screen_name=screen_name, count=MAX_TWEETS_PER_USER, tweet_mode="extended",
                               exclude_replies=True)
    tweets = [t for t in tweets if not is_retweet(t)]
    return tweets
    # user = api.get_user(screen_name)


def load_accounts(src_file=ACCOUNTS_FILE_PATH) -> List[str]:
    accounts = []
    df = pd.read_csv(src_file, encoding='latin1')
    for _, line in df.iterrows():
        accounts.append(line["name"])
    return accounts


def download_all_tweets(src_file=ACCOUNTS_FILE_PATH, dst_dir=DEST_DIR):
    accounts = load_accounts(src_file)
    downloaded = {f.replace("_tweets.pickle", "") for f in os.listdir(dst_dir)}
    for i, account in enumerate(accounts):
        if account not in downloaded:
            print("Working on:", account)
            try:
                tweets = get_account_tweets(account)
            except Exception as e:
                print("Got exception ", end="")
                if "page does not exist" not in e.reason:
                    print("sleeping...", end="")
                    time.sleep(4)
                print("")
                continue
            if tweets:
                with open(os.path.join(dst_dir, f'{account}_tweets.pickle'), 'wb') as f:
                    pickle.dump(tweets, f)
        else:
            print("Passed:", account)
        if i % 10 == 0:
            print(f"done {i}/{len(accounts)}")


def is_retweet(tweet) -> bool:
    return tweet.retweeted or 'RT @' in tweet.full_text


if __name__ == '__main__':
    download_all_tweets()
