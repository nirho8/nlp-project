import os
from glob import glob
import pickle
from typing import List

from tweepy import Status

from src.config import TRAIN_DATA_DIR, TRAIN_MAX_USERS, TRAIN_MAX_TWEETS_PER_USER, TRAIN_MAX_TWEETS


def load_tweets_grouped_by_user(dir_path: str = TRAIN_DATA_DIR, max_users: int = TRAIN_MAX_USERS,
                                max_tweets_per_user: int = TRAIN_MAX_TWEETS_PER_USER,
                                max_tweets: int = TRAIN_MAX_TWEETS) -> List[List[Status]]:
    tweets = []
    for user_file_path in glob(os.path.join(dir_path, "*.pickle"))[:max_users]:
        with open(user_file_path, "rb") as f:
            tweets.append(pickle.load(f)[:max_tweets_per_user])
        if sum([len(t) for t in tweets]) >= max_tweets:
            return tweets
    return tweets
