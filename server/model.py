
class Model:

    def __init__(self, name_of_model):
        self.name = name_of_model

    def prediction(self, name_account, tweet, time_of_tweet):
        return f"name of model: {self.name}, account name: {name_account}, tweet: {tweet}, post time: {time_of_tweet}"
