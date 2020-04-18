import torch
from torch import nn
import torch.utils.data

from python.userModule.user_avg_label import UserDataPreparation
from python.userModule.user_model import UserInfoNet


def train_embeddings_network(model, users, epochs, batch_size):
    """
      model - the embedding_net object
      data - the dataset (i.e., embedding_data from above)
      epochs - number of epochs to train the network
      batch_size - the batch size
    """

    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters())

    # train loop

    for epoch in range(epochs):
        running_loss = 0.0
        for i, data in enumerate(users, 0):

            u_vector, labels = data
            u_vector = u_vector.float()
            labels = labels

            # zero the parameter gradients
            optimizer.zero_grad()

            # forward + backward + optimize
            outputs, hidden_layer_output = model(u_vector)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            # print statistics
            running_loss += loss.item()
            if (i + 1) % 1000 == 0:
                print('[%d, %5d] loss: %.3f' %
                      (epoch + 1, i + 1, running_loss / 1000))
                running_loss = 0.0


if __name__ == '__main__':
    user_prepared_data = UserDataPreparation()
    user_model = UserInfoNet(user_prepared_data.get_vec_len(), 100, 200, 2)

    vec_train_data = [[vec[0], vec[1]] for vec in user_prepared_data.user2vec_dict.values()]
    trainloader = torch.utils.data.DataLoader(vec_train_data, batch_size=3, shuffle=True)

    train_embeddings_network(user_model, trainloader, 10, 3)
    print("done")
