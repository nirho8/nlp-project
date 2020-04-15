import numpy as np
from python.src.data_utils import load_tweets_grouped_by_user
from python.src.user_utils import convert_user_to_vector


class UserDataPreparation:

    def __init__(self):
        tweets = load_tweets_grouped_by_user()
        users_tweets = [tweet[0].user for tweet in tweets]
        self.user2vec_dict = {user.name: [np.asarray(convert_user_to_vector(user))] for user in
                              users_tweets}  # Make a dic generator for user and its vector
        self.avg_user_vec = {}
        self.__make_avg_user_vector()
        self.__label_users()
        print("---User vectoring and labeling complete---")

    def __make_avg_user_vector(self):
        """""
            looking for the average of number of followers and number of friends
            located in list: #8 followers
                             #9 friends
        """""
        vectors_list = [user_vec[0] for user_vec in self.user2vec_dict.values()]
        sum_of_vectors = np.sum(vectors_list, axis=0) / len(vectors_list)
        self.avg_user_vec["followers"] = sum_of_vectors[8]
        self.avg_user_vec["friends"] = sum_of_vectors[9]

    def __label_users(self):
        """""
            Making a dictionary of user to its label according to the sum of the average user parameters
        """""
        for user, user_vec in self.user2vec_dict.items():
            followers, friends = user_vec[0][8], user_vec[0][9]
            if (followers + friends) > (self.avg_user_vec["followers"] + self.avg_user_vec["friends"]):
                self.user2vec_dict[user].append(1)
            else:
                self.user2vec_dict[user].append(0)

    def get_vec_len(self):
        return len(list(self.user2vec_dict.values())[0][0])

