import pickle,numpy as np,matplotlib.pyplot  as plt
# open a file, where you stored the pickled data
file = open('store.pckl', 'rb')

# dump information to that file
data = pickle.load(file)

# close the file
file.close()

# print(len(data))

ordered = np.reshape(data,[24,26])

imgplot = plt.imshow(ordered)
plt.show()
# plt.imsave('map.bmp', ordered, cmap='gray')
