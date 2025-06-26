import os
import sys

# SCRIPT_DIR = os.path.dirname(os.path.abspath("C://Users//LITO\Downloads//HoloApp-main (16)//HoloApp-main//src//camera_code//python_code//idk"))
# sys.path.append(os.path.dirname(SCRIPT_DIR))

sys.path.insert(1,'/idk/')
# sys.path.append('/imports/')
# sys.path.append('.')
from idk.connect_to_cam import connect_to_cam
# import imports.connect_to_cam

def main(time,save_dir,exp_time):
    # create folder in directory
    # get images from camera for specified time
    # time = sys.argv[1]
    # out_dir = sys.argv[2]
    connect_to_cam(time_on =time, out_dir=save_dir, set_exp_time_arg= exp_time)
    
    # save them in the right folder
    return 0

# a = 2
# save_dir = ''
# exp_time = 20000.0
main(a,save_dir,exp_time)