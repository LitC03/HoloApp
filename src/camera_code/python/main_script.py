import os
import sys
sys.path.insert(1,'/imports/')
from imports.connect_to_cam import connect_to_cam

def main(time,save_dir):
    # create folder in directory
    # get images from camera for specified time
    # time = sys.argv[1]
    # out_dir = sys.argv[2]
    connect_to_cam(time_on =time,out_dir=save_dir)
    
    # save them in the right folder
    return 0

main(a,save_dir)