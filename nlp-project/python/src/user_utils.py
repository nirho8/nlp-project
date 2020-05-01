from typing import List, Optional
from datetime import datetime

import torch
import tweepy
from tweepy import User

from src.config import CUDA

consumer_key = ""
consumer_secret = ""
access_key = ""
access_secret = ""


def get_user(screen_name: str):
    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_key, access_secret)
    api = tweepy.API(auth)
    return api.get_user(screen_name)


def bool_to_vector(val: bool) -> List[int]:
    return [1, 0] if val else [0, 1]


def datetime_to_vector(val: datetime) -> List[int]:
    return [int(val.timestamp())]


def str_to_vector(val: Optional[str]) -> List[int]:
    return bool_to_vector(bool(val))


def get_int(user: User, key: str) -> List[int]:
    return [int(getattr(user, key, 0))]


def get_str(user: User, key: str) -> List[int]:
    return str_to_vector(getattr(user, key, None))


def get_bool(user: User, key: str) -> List[int]:
    return bool_to_vector(getattr(user, key, False))


def convert_user_to_vector(user: User) -> List[int]:
    return datetime_to_vector(getattr(user, "created_at", datetime.fromtimestamp(0))) + \
           get_bool(user, "default_profile") + \
           get_bool(user, "default_profile_image") + \
           get_str(user, "description") + \
           get_int(user, "favourites_count") + \
           get_int(user, "followers_count") + \
           get_int(user, "friends_count") + \
           get_int(user, "listed_count") + \
           get_str(user, "location") + \
           get_bool(user, "protected") + \
           get_int(user, "statuses_count") + \
           get_str(user, "url") + \
           get_bool(user, "verified") + \
           get_str(user, "profile_banner_url")


def convert_user_to_model_input(user: User) -> torch.Tensor:
    user_vector = torch.tensor(convert_user_to_vector(user)).float()
    if CUDA:
        user_vector = user_vector.cuda()
    return user_vector


def screen_name_to_vector(screen_name: str) -> torch.Tensor:
    user = get_user(screen_name)
    vector = convert_user_to_model_input(user)
    return vector
