import torch.utils.data
import torch.nn.functional as F
import torch.nn as nn

from python.userModule.user_avg_label import UserDataPreparation


class UserInfoNet(torch.nn.Module):

    def __init__(self, user_vector_size, hidden_size, user_vector_out, output_size):
        """
          players_n - the size of the one hot vectors representing a single player
          hidden_size - the output size of Linear of winner, Linear of loser and Linear 1 from the diagram (200 for now)
          Note - Linear 2's output size should be 2
        """
        super(UserInfoNet, self).__init__()

        self.players_n = user_vector_size
        self.hidden_size = hidden_size

        self.linear_user = nn.Linear(user_vector_size, hidden_size)
        self.out_vector = nn.Linear(hidden_size, user_vector_out)
        self.linear_output = nn.Linear(user_vector_out, output_size)

    def forward(self, user_batch):
        """
          user_batch - Bx(user) tensor - a batch of users vectors
        """

        output_vector = self.out_vector(F.relu(self.linear_user(user_batch)))
        output_user = self.linear_output(torch.relu(output_vector))
        return output_user, output_vector  # Two values return - First value is classification of 0,1
        # Second value is the hidden size vector
