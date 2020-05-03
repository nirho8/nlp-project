from typing import List

import torch
from sklearn.model_selection import train_test_split

from src.config import TEXT_HIDDEN_SIZE, TEXT_OUT_SIZE, TRAIN_LSTM_DROPOUT, USER_HIDDEN_SIZE, USER_OUT_SIZE, \
    USER_CLASS_OUT_SIZE, USER_VECTOR_SIZE, FINAL_LINEAR_SIZE, CUDA, TRAINED_MODEL_PATH
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