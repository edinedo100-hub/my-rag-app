import torch
import torch.nn as nn

# Tensors = NumPy arrays with GPU support
x = torch.randn(32, 784)  # batch of 32

# Autograd = automatic differentiation
w = torch.randn(784, 10, requires_grad=True)
y = x @ w
loss = y.sum()
loss.backward()  # gradients computed!
print(w.grad.shape)