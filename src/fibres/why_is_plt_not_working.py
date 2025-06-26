import matplotlib.pyplot as plt
import pickle

with open("five_7.pkl", "rb") as file:
    max_vals = pickle.load(file)

plt.imshow(max_vals)
plt.show()