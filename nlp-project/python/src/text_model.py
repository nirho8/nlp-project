# TODO: Use glove.twitter.27B.200d.txt from https://nlp.stanford.edu/projects/glove/

from typing import List, Dict
import pickle

import numpy as np
import torch
from sklearn.model_selection import train_test_split
from nltk.tokenize import TweetTokenizer

from src.config import CUDA, TRAIN_LSTM_DROPOUT, TEXT_EMBEDDING_SIZE, TEXT_HIDDEN_SIZE, TEXT_OUT_SIZE, \
    TEXT_EMBEDDING_PATH, TEXT_VOCAB_PATH
from src.data_utils import load_tweets_grouped_by_user

tokenizer = TweetTokenizer()
UNKNOWN = 0
URL = 1


class Vocab:
    def __init__(self):
        self.word2index = {}
        self._extra_words = 2  # UNKNOWN and URL

    def index_sentence(self, sentence, write=True) -> List[int]:
        return [self._index_word(word, write) for word in tokenizer.tokenize(sentence)]

    def get_num_words(self) -> int:
        return self._extra_words + len(self.word2index)

    def _index_word(self, word, write=True) -> int:
        word = word.lower()
        if word in self.word2index:
            return self.word2index[word]
        if word.startswith("http://") or word.startswith("https://"):
            return URL
        if write:
            self.word2index[word] = self.get_num_words()
            return self.word2index[word]
        return UNKNOWN

    def get_embeddings(self) -> List[List[float]]:
        print("loading glove embeddings")
        glove_word2emb = Vocab._load_glove_as_word_to_embedding()
        print("done loading glove embeddings")
        index2embedding = [Vocab._generate_random_embedding() for _ in range(self.get_num_words())]
        print("generating embedding")
        for word, index in self.word2index.items():
            if word in glove_word2emb:
                index2embedding[index] = glove_word2emb[word]
        print("done generating embeddings")
        return index2embedding

    @staticmethod
    def _load_glove_as_word_to_embedding(embedding_path: str = TEXT_EMBEDDING_PATH) -> Dict[str, List[float]]:
        word2embedding = {}
        with open(embedding_path, 'r') as f:
            for l in f:
                line = l.split()
                word2embedding[line[0]] = [float(i) for i in line[1:]]
        return word2embedding

    @staticmethod
    def _generate_random_embedding(embedding_size: str = TEXT_EMBEDDING_SIZE) -> List[float]:
        return list(np.random.normal(scale=0.6, size=(embedding_size,)))

    @staticmethod
    def create_new(tweets: List[str]) -> "Vocab":
        vocab = Vocab()
        print("indexing words")
        for tweet in tweets:
            vocab.index_sentence(tweet)
        print("done creating Vocab")
        return vocab

    def save_to_file(self, path: str = TEXT_VOCAB_PATH):
        with open(path, "wb") as f:
            pickle.dump(self.word2index, f)

    @staticmethod
    def load_from_file(path: str = TEXT_VOCAB_PATH) -> "Vocab":
        vocab = Vocab()
        with open(path, "rb") as f:
            vocab.word2index = pickle.load(f)
        return vocab


def sentence2tensor(vocab: Vocab, sentence: str):
    tensor = torch.tensor(vocab.index_sentence(sentence, write=False))
    if CUDA:
        return tensor.cuda()
    return tensor


class Attn(torch.nn.Module):
    def __init__(self, hidden_size):
        super(Attn, self).__init__()

        self.hidden_size = hidden_size
        self.lin = torch.nn.Linear(self.hidden_size * 2, hidden_size * 2)
        weights = torch.randn(1, hidden_size * 2)  # torch.FloatTensor(1, hidden_size*2)
        self.weight_vec = torch.nn.Parameter(weights)

    def forward(self, outputs):
        seq_len = len(outputs)

        attn_energies = torch.zeros(seq_len)  # B x 1 x S
        if CUDA:
            attn_energies = attn_energies.cuda()

        for i in range(seq_len):
            current_score = self.score(outputs[i])  # We get nan
            attn_energies[i] = current_score

        # Normalize energies to weights in range 0 to 1, resize to 1 x 1 x seq_len
        return torch.nn.functional.softmax(attn_energies).unsqueeze(0).unsqueeze(0)

    def score(self, output):
        energy = self.lin(output)  # no nan in output
        var1 = self.weight_vec.view(-1)
        var2 = energy.view(-1)
        energy = torch.dot(var1, var2)  # nan in output
        return energy


class TextModel(torch.nn.Module):
    def __init__(self, input_size: int, pre_trained_embedding: List[List[float]], hidden_size=TEXT_HIDDEN_SIZE,
                 out_size=TEXT_OUT_SIZE, n_layers=2, dropout=TRAIN_LSTM_DROPOUT):
        super(TextModel, self).__init__()

        self.hidden_size = hidden_size
        self.embedding_size = len(pre_trained_embedding[0])
        self.input_size = input_size
        self.n_layers = n_layers

        self.embedding = torch.nn.Embedding.from_pretrained(torch.FloatTensor(pre_trained_embedding), freeze=False)
        # self.embedding = torch.nn.Embedding(input_size, embedding_size)
        self.lstm = torch.nn.LSTM(self.embedding_size, hidden_size, n_layers, dropout=dropout, bidirectional=True)
        self.out_layer = torch.nn.Linear(hidden_size * 2, out_size)
        self.attn = Attn(hidden_size)

    def forward(self, tweet_one_hot):
        seq_len = len(tweet_one_hot)
        embedded = self.embedding(tweet_one_hot).view(seq_len, 1, -1)

        rnn_outputs, (hidden, _) = self.lstm(embedded, self.init_hidden())  # output: up. hidden: right.

        attn_weights = self.attn(rnn_outputs)
        attn_weights = attn_weights.squeeze(1).view(seq_len, 1)
        rnn_outputs = rnn_outputs.squeeze(1)
        attn_weights = attn_weights.expand(seq_len, self.hidden_size * 2)
        weighted_outputs = torch.mul(rnn_outputs, attn_weights)
        output = torch.sum(weighted_outputs, -2)

        return self.out_layer(output)

    def init_hidden(self):
        if CUDA:
            return (torch.zeros(self.n_layers * 2, 1, self.hidden_size).cuda(),
                    torch.zeros(self.n_layers * 2, 1, self.hidden_size).cuda())
        return (torch.zeros(self.n_layers * 2, 1, self.hidden_size),
                torch.zeros(self.n_layers * 2, 1, self.hidden_size))


# ONLY FOR EXAMPLE
def _calc_test_loss(X_test, y_test, criterion, model):
    loss_sum = 0
    model = model.eval()
    success_count = 0
    for i, x in enumerate(X_test):
        y = y_test[i]
        output = model(x).view(1, -1)
        if output[0][y[0]] > output[0][1 - y[0]]:
            success_count += 1
        loss = criterion(output, y)
        loss_sum += loss.item()
    print("test data loss:", loss_sum / len(X_test))
    print("test data accuracy:", success_count / len(X_test))
    model.train()


# ONLY FOR EXAMPLE
def _train(model: TextModel, X_train, X_test, y_train, y_test, epochs=15):
    criterion = torch.nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.0001, weight_decay=0.001)

    temp = 0
    loss_sum = 0

    for epoch in range(epochs):
        print("EPOCH:", epoch)
        _calc_test_loss(X_test, y_test, criterion, model)
        for i, x in enumerate(X_train):
            optimizer.zero_grad()
            y = y_train[i]
            output = model(x).view(1, -1)
            loss = criterion(output, y)
            loss.backward()
            # torch.nn.utils.clip_grad_norm_(model.parameters(), 5)
            optimizer.step()

            loss_sum += loss.item()
            temp += 1
            if temp == 1000:
                print(loss_sum / 1000)
                temp = 0
                loss_sum = 0


# ONLY FOR EXAMPLE - train to always return `1`
def _main():
    tweets_objects = sum(load_tweets_grouped_by_user(), [])
    tweets_text = [t.full_text for t in tweets_objects]
    vocab = Vocab.create_new(tweets_text)
    vocab.save_to_file()
    X = []
    y = []
    for tweet_text in tweets_text:
        y.append(torch.tensor([1]))
        X.append(sentence2tensor(vocab, tweet_text))
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
    print("X:", X_train[:3])
    print("y:", y_train[:3])

    model = TextModel(vocab.get_num_words(), vocab.get_embeddings())
    if CUDA:
        model = model.cuda()
    _train(model, X_train, X_test, y_train, y_test)
