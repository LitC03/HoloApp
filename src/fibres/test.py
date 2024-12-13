
import cv2,numpy as np,os,pickle

# Function to calculate mean intensity of each frame in a video
def calculate_mean_intensity(video_path):
    # Open the video file
    cap = cv2.VideoCapture(video_path)
    
    # Check if video opened successfully
    if not cap.isOpened():
        print("Error: Could not open video.")
        return
    
    frame_mean_intensities = []
    
    while True:
        # Read a frame from the video
        ret, frame = cap.read()
        
        # If the frame was not read successfully, break the loop
        if not ret:
            break
        
        # Convert the frame to grayscale
        gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Calculate the mean intensity of the grayscale frame
        mean_intensity = gray_frame.mean()
        
        # Append the mean intensity to the list
        frame_mean_intensities.append(mean_intensity)
    
    # Release the video capture object
    cap.release()
    
    return frame_mean_intensities

# Example usage
directory_path = "C:\\Users\\LITO\\Videos\\fibers\\20241211\\new"
# Desired extension
extension = ".avi"

# List all files with the given extension
files_with_extension = [file for file in os.listdir(directory_path) if file.endswith(extension)]
all_max_intesities = np.zeros(len(files_with_extension))
count = 0
for vid in files_with_extension:
    print(count)
    video_path = os.path.join(directory_path,vid)
    mean_intensities = calculate_mean_intensity(video_path)
    all_max_intesities[count] = max(mean_intensities)
    count += 1
    

# # Print the mean intensities of each frame
# for i, intensity in enumerate(mean_intensities):
#     print(f"Frame {i+1}: Mean Intensity = {intensity}")


f = open('store.pckl', 'wb')
pickle.dump(all_max_intesities, f)
f.close()