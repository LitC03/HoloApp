import pickle
import numpy as np
import matplotlib.pyplot  as plt
import os
import re
import cv2
import tifffile
# open a file, where you stored the pickled data

# file = open('store.pckl', 'rb')

# # dump information to that file
# data = pickle.load(file)

# # close the file
# file.close()

# # print(len(data))

# ordered = np.reshape(data,[24,26])

# imgplot = plt.imshow(ordered)
# plt.show()
# plt.imsave('map.bmp', ordered, cmap='gray')

# get experiment name
exp_name = "exp_test_8"
# Get the directories with the images
exp_dir = "..//..//img//fibre_imgs//" + exp_name
# calculate the size of the map we are building
folder_names = os.listdir(exp_dir)
print(folder_names)
dim_matches_min = re.findall(r'-?\d+', folder_names[0])
dim_matches_max = re.findall(r'-?\d+', folder_names[-1])

x = np.zeros((2,), dtype=float)
y = np.zeros((2,), dtype=float)
y[0] = dim_matches_min[0]
x[0] = dim_matches_min[1]
y[1] = dim_matches_max[0]
x[1] = dim_matches_max[1]
# x[0] = -960
# x[1] = 790
# y[0] = -790
# y[1] = 960

# x[0] = -960
# x[1] = -60
# y[0] = 60
# y[1] = 960

# y[0] = 60
# y[1] = 960
# x[0] = 0
# x[1] = 900

# y[0] = -900
# y[1] = 0
# x[0] = 0
# x[1] = 900

y[0] = -900
y[1] = 0
x[0] = -960
x[1] = -60

# x[0] = 60

# x[0] = -900

# y[0] = 0
# y[1] = -900
# x[0] = 60
# x[1] = 960

step = float(dim_matches_max[2])

# print(type(x[0]), type(x[1]), type(step))
x_len = int(abs((x[1]- x[0])) // step + 1)
y_len = int(abs((y[1] - (y[0]))) // step + 1)

print(str(x)+'\n'+str(y))

folder_length = len(folder_names)
max_vals = np.zeros((x_len,y_len),dtype=float)

m=0
# for each folder
for i in range(folder_length):
    row, col = divmod(i, y_len)
    folder = "phase_"+str(int((row*step)+x[0]))+"_"+str(int((col*step)+y[0]))+"_step_"+str(int(step))
    file_names = os.listdir(os.path.join(exp_dir, folder))
    len_imgs = len(file_names)
    mean_array = np.zeros(len_imgs)
    

# Convert linear index to row and column indices
    

    #for every image 
    n = 0
    for img in file_names:
        imag_path = os.path.join(exp_dir, folder,img)
        image = cv2.imread(imag_path, cv2.IMREAD_GRAYSCALE)
        image_array = np.array(image)
        mean_array[n] = np.mean(image_array)
        n+=1
        # get the mean value of the image and store it in a numy array frot that folder
    
    max_vals[row,col] = np.max(mean_array)
    #get the max value of the mean ones and store it in the numpy array of the map
    m+=1

pckl_name = exp_name+".pkl"
with open(pckl_name, "wb") as file:
    pickle.dump(max_vals, file)
#plot map
#pray it works


tifffile.imwrite(exp_name+'.tiff', max_vals)

plt.imshow(max_vals)
plt.show()

