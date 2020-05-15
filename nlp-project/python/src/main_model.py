import os
import pickle
from typing import List, Any, Tuple

import torch
from sklearn.model_selection import train_test_split
from tweepy import User

from src.config import TEXT_HIDDEN_SIZE, TEXT_OUT_SIZE, TRAIN_LSTM_DROPOUT, USER_HIDDEN_SIZE, USER_OUT_SIZE, \
    USER_CLASS_OUT_SIZE, USER_VECTOR_SIZE, FINAL_LINEAR_SIZE, CUDA, TRAINED_MODEL_PATH, TRAIN_WORKING_DIR, \
    PRINT_AT_INDEX
from src.data_utils import load_tweets_grouped_by_user
from src.text_model import TextModel, Vocab, sentence2tensor
from src.userModule.user_model import UserInfoNet
from src.user_utils import convert_user_to_vector, convert_user_to_model_input


class PredictLikesModel(torch.nn.Module):
    def __init__(self, text_input_size: int, pre_trained_embedding: List[List[float]],
                 text_hidden_size=TEXT_HIDDEN_SIZE,
                 text_out_size=TEXT_OUT_SIZE, n_layers=2, dropout=TRAIN_LSTM_DROPOUT, user_vector_size=USER_VECTOR_SIZE,
                 user_hidden_size=USER_HIDDEN_SIZE, user_out_size=USER_OUT_SIZE,
                 user_class_out_size=USER_CLASS_OUT_SIZE,
                 final_linear_size=FINAL_LINEAR_SIZE):
        super(PredictLikesModel, self).__init__()
        self.text_input_size = text_input_size
        self.user_vector_size = user_vector_size
        self.user_model = UserInfoNet(user_vector_size, user_hidden_size, user_out_size, user_class_out_size)
        self.text_model = TextModel(text_input_size, pre_trained_embedding, text_hidden_size, text_out_size, n_layers,
                                    dropout)
        self.linear0 = torch.nn.Linear(text_out_size + user_out_size, final_linear_size)
        self.final_linear = torch.nn.Linear(final_linear_size, 1)

    def forward(self, user_and_text_vector: List[torch.Tensor]):
        """
        :param user_and_text_vector: [user_vector, text_vector]
        """
        user_vector = user_and_text_vector[0]
        text_vector = user_and_text_vector[1]

        _, user_out = self.user_model(user_vector)
        text_out = self.text_model(text_vector)

        linear0_input = torch.cat((user_out, text_out))
        linear0_out = torch.nn.functional.relu(self.linear0(linear0_input))
        return self.final_linear(linear0_out)


# ONLY FOR EXAMPLE
def _calc_test_loss(X_test, y_test, criterion, model):
    loss_sum = 0
    model = model.eval()
    success_count = 0
    for i, x in enumerate(X_test):
        y = y_test[i]
        output = model(x)
        output = output
        if 90 < output[0] < 110:
            success_count += 1
        loss = criterion(output, y)
        loss_sum += loss.item()
    print("test data loss:", loss_sum / len(X_test))
    print("test data accuracy:", success_count / len(X_test))
    model.train()


# ONLY FOR EXAMPLE
def _train(model: torch.nn.Module, X_train, X_test, y_train, y_test, epochs=2000):
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)  #, weight_decay=0.001)

    temp = 0
    loss_sum = 0
    print_at_index = 100
    outputs = []

    for epoch in range(epochs):
        print("EPOCH:", epoch)
        for i, x in enumerate(X_train):
            optimizer.zero_grad()
            y = y_train[i]
            output = model(x)
            loss = criterion(output, y)
            loss.backward()
            # torch.nn.utils.clip_grad_norm_(model.parameters(), 5)
            optimizer.step()
            loss_sum += loss.item()
            temp += 1
            outputs.append(output.tolist()[0])
            if temp == print_at_index:
                print(loss_sum / print_at_index)
                temp = 0
                loss_sum = 0
                print("output:", sum(outputs) / len(outputs))
                outputs = []
                _calc_test_loss(X_test, y_test, criterion, model)


# ONLY FOR EXAMPLE - train to always return `100`
def _main():
    tweets_objects = sum(load_tweets_grouped_by_user(), [])
    vocab = Vocab.create_new([t.full_text for t in tweets_objects])
    vocab.save_to_file()
    X = []
    y = []
    for tweet in tweets_objects:
        y.append(torch.tensor([100]).float())
        user_vector = convert_user_to_model_input(tweet.user)
        text_vector = sentence2tensor(vocab, tweet.full_text)
        X.append([user_vector, text_vector])
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
    print("X:", X_train[:3])
    print("y:", y_train[:3])

    model = PredictLikesModel(vocab.get_num_words(), vocab.get_embeddings())
    if CUDA:
        model = model.cuda()
    _train(model, X_train, X_test, y_train, y_test)
    torch.save(model.state_dict(), TRAINED_MODEL_PATH)


def load_model(model: PredictLikesModel) -> PredictLikesModel:
    path = os.path.join(TRAIN_WORKING_DIR, "model")
    model.load_state_dict(torch.load(path, map_location=torch.device("cpu")))
    return model


def save_model(model: PredictLikesModel):
    path = os.path.join(TRAIN_WORKING_DIR, "model")
    torch.save(model.state_dict(), path)


def save_optimizer(optimizer) -> None:
    path = os.path.join(TRAIN_WORKING_DIR, "optimizer")
    torch.save(optimizer.state_dict(), path)


def load_optimizer(optimizer):
    path = os.path.join(TRAIN_WORKING_DIR, "optimizer")
    if not CUDA:
        optimizer.load_state_dict(torch.load(path, map_location=torch.device("cpu")))
    if CUDA:
        optimizer.load_state_dict(torch.load(path, map_location=torch.device("cuda:0")))
    return optimizer


def save_test_losses(test_losses: List[float]) -> None:
    _save_pickle(test_losses, "test_losses.pickle")


def load_test_losses() -> List[float]:
    if os.path.exists(os.path.join(TRAIN_WORKING_DIR, "test_losses.pickle")):
        return _load_pickle("test_losses.pickle")
    return []


def save_train_losses(train_losses: List[float]) -> None:
    _save_pickle(train_losses, "train_losses.pickle")


def load_train_losses() -> List[float]:
    if os.path.exists(os.path.join(TRAIN_WORKING_DIR, "train_losses.pickle")):
        return _load_pickle("train_losses.pickle")
    return []


def save_epoch(epoch: int) -> None:
    _save_pickle(epoch, "epoch.pickle")


def load_epoch() -> int:
    return _load_pickle("epoch.pickle")


def save_train_test_data(X_train: torch.Tensor, X_test: torch.tensor, y_train: torch.Tensor,
                         y_test: torch.Tensor) -> None:
    path = os.path.join(TRAIN_WORKING_DIR, "train_test.pickle")
    torch.save((X_train, X_test, y_train, y_test), path)


def load_train_test_data() -> Tuple[torch.Tensor, torch.Tensor, torch.Tensor, torch.Tensor]:
    path = os.path.join(TRAIN_WORKING_DIR, "train_test.pickle")
    if CUDA:
        return torch.load(path, map_location=torch.device("cuda:0"))
    return torch.load(path, map_location=torch.device("cpu"))


def save_embeddings(embeddings: List[List[float]]) -> None:
    _save_pickle(embeddings, "embeddings.pickle")


def save_num_words(num_words: int):
    _save_pickle(num_words, "num_words.pickle")


def load_num_words() -> int:
    return _load_pickle("num_words.pickle")


def load_embeddings() -> List[List[float]]:
    return _load_pickle("embeddings.pickle")


def _load_pickle(file_name: str) -> Any:
    path = os.path.join(TRAIN_WORKING_DIR, file_name)
    with open(path, "rb") as f:
        return pickle.load(f)


def _save_pickle(data: Any, file_name: str) -> None:
    path = os.path.join(TRAIN_WORKING_DIR, file_name)
    with open(path, "wb") as f:
        pickle.dump(data, f)


def is_first_run() -> bool:
    return not os.path.exists(os.path.join(TRAIN_WORKING_DIR, "epoch.pickle"))


def calc_test_loss(X_test, y_test, criterion, model) -> float:
    loss_sum = 0
    model = model.eval()
    for i, x in enumerate(X_test):
        y = y_test[i]
        output = model(x)
        output = output
        loss = criterion(output, y)
        loss_sum += loss.item()
    model.train()
    test_loss = loss_sum / len(X_test)
    print("test data loss:", test_loss)
    return test_loss


def train(model: torch.nn.Module, X_train, X_test, y_train, y_test, epochs=2000):
    start_epoch = 0 if is_first_run() else load_epoch() + 1
    criterion = torch.nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)  # , weight_decay=0.001)
    if not is_first_run():
        optimizer = load_optimizer(optimizer)

    print_counter = 0
    loss_sum = 0
    print_at_index = PRINT_AT_INDEX

    for epoch in range(start_epoch, epochs):
        train_losses_avg = []
        test_losses_avg = []
        print("EPOCH:", epoch)
        for i, x in enumerate(X_train):
            optimizer.zero_grad()
            y = y_train[i]
            output = model(x)
            loss = criterion(output, y)
            loss.backward()
            # torch.nn.utils.clip_grad_norm_(model.parameters(), 5)
            optimizer.step()
            loss_sum += loss.item()

            print_counter += 1
            if print_counter == print_at_index:
                avg_loss = loss_sum / print_at_index
                train_losses_avg.append(avg_loss)
                print(avg_loss)
                test_losses_avg.append(calc_test_loss(X_test, y_test, criterion, model))
                print_counter = 0
                loss_sum = 0

        save_epoch(epoch)
        save_model(model)
        save_optimizer(optimizer)
        save_test_losses(load_test_losses() + test_losses_avg)
        save_train_losses(load_train_losses() + train_losses_avg)


def main():
    if is_first_run():
        print("No existing model, creating new")
        print("Loading tweets")
        tweets_objects = sum(load_tweets_grouped_by_user(), [])
        print("Done loading tweets")
        print("Creating new vocab")
        vocab = Vocab.create_new([t.full_text for t in tweets_objects])
        print("Saving vocab")
        vocab.save_to_file()
        print("Vocab saved")

        num_words = vocab.get_num_words()
        embeddings = vocab.get_embeddings()
        save_num_words(num_words)
        save_embeddings(embeddings)

        X = []
        y = []
        for tweet in tweets_objects:
            y0 = torch.tensor([tweet.favorite_count]).float()
            if CUDA:
                y0 = y0.cuda()
            y.append(y0)
            user_vector = convert_user_to_model_input(tweet.user)
            text_vector = sentence2tensor(vocab, tweet.full_text)
            X.append([user_vector, text_vector])
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
        save_train_test_data(X_train, X_test, y_train, y_test)
    else:
        print("Loading existing model")
        X_train, X_test, y_train, y_test = load_train_test_data()
        embeddings = load_embeddings()
        num_words = load_num_words()

    model = PredictLikesModel(num_words, embeddings)
    if not is_first_run():
        model = load_model(model)
    if CUDA:
        model = model.cuda()

    train(model, X_train, X_test, y_train, y_test)


def predict_load_model() -> PredictLikesModel:
    print("Loading model")
    model = PredictLikesModel(load_num_words(), load_embeddings())
    model = load_model(model).eval()
    print("Done loading model")
    return model


def predict_load_vocab() -> Vocab:
    print("Loading vocab")
    vocab = Vocab.load_from_file()
    print("Done loading vocab")
    return vocab


def predict(model: PredictLikesModel, vocab: Vocab, text: str, user: User) -> int:
    user_vector = convert_user_to_model_input(user)
    text_vector = sentence2tensor(vocab, text)
    x = [user_vector, text_vector]
    output = model(x)
    return max(int(output.tolist()[0]), 0)
