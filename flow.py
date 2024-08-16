import torch
import torch.nn as nn
import torch.optim as optim

class Flownet_corr(nn.Module):
    expansion = 1
    def __init__(self, batch_norm=True):
        super(Flownet_corr, self).__init__()
        self.batch_norm = batch_norm
        #contracting part(two seperate streams)
        self.conv1 = self.conv(1, 64, kernel_size=7, stride=2)
        self.conv2 = self.conv(64, 128, kernel_size=5, stride=2)
        self.conv3 = self.conv(128, 256, kernel_size=5, stride=2)
        self.conv_redir = self.conv(256, 256, kernel_size=3, stride=1)
        



        
