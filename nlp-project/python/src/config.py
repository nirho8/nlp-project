import os

FLASK_TEMPLATE_FOLDER = ""  # TODO
PRINT_AT_INDEX = 100  # After how many iteration should we print the loss?
TRAIN_WORKING_DIR = ""  # TODO: Where to save training ouputs (e.g model)
TRAINED_MODEL_PATH = "../../../model.pth"
TRAIN_DATA_DIR = ""  # TODO: Where the tweets are saved
TRAIN_MAX_USERS = 1_000_000
TRAIN_MAX_TWEETS_PER_USER = 1000
TRAIN_MAX_TWEETS = 30_000
TRAIN_LSTM_DROPOUT = 0.5
TEXT_HIDDEN_SIZE = 500
TEXT_OUT_SIZE = 200
TEXT_EMBEDDING_PATH = "glove.twitter.27B.200d.txt"  # TODO: Use glove.twitter.27B.200d.txt from https://nlp.stanford.edu/projects/glove/
TEXT_EMBEDDING_SIZE = int(os.path.basename(TEXT_EMBEDDING_PATH).split(".")[-2].replace("d", ""))  # Should be the same as TEXT_EMBEDDING_PATH (200)
TEXT_VOCAB_PATH = os.path.join(TRAIN_WORKING_DIR, "vocab.pickle")
CUDA = False
USER_VECTOR_SIZE = 22
USER_HIDDEN_SIZE = 100
USER_OUT_SIZE = 200
USER_CLASS_OUT_SIZE = 2
FINAL_LINEAR_SIZE = 50
# USER_VECTOR_FEATURE =

# data = load_tweets_grouped_by_user()
# v = convert_user_to_vector(data[0][0].user)
# USER_VECTOR_SIZE = len(v)