
from ids_peak import ids_peak
from ids_peak_ipl import ids_peak_ipl
from ids_peak import ids_peak_ipl_extension
# from PySide6.QtCore import QTimer

import numpy as np
from PIL import Image as im
import sys 
import time
import os

FPS_LIMIT = 30

class connect_to_cam():
    def __init__(self, time_on = 1/30, out_dir = os.path.join(os.getcwd(),'data'),set_exp_time_arg = 14000.0):
        self.__device = None
        self.__nodemap_remote_device = None
        self.__datastream = None
        self.__time_on = time_on
        self.__out_dir = out_dir

        self.__frame_counter = 0
        self.__error_counter = 0
        self.__acquisition_running = False

        self._exp_time = set_exp_time_arg

        ids_peak.Library.Initialize()
        # self.__destroy_all()
        # sys.exit(0)

        if self.__open_device():
            
            try:
                if not self.__start_acquisition():
                    print("Unable to start acquisition!")
            except Exception as e:
                
                print("Exception in INIT", str(e))

        else:
            self.destroy_all()
            sys.exit(0)

    def __del__(self):
        # self.destroy_all()
        # device_manager = ids_peak.DeviceManager.Instance()
        self.__stop_acquisition()
        # self.__device = device_manager.Devices()[0].OpenDevice(ids_peak.DeviceAccessType_Control)
        self.__device =   None
        # self.__close_device()
        ids_peak.Library.Close()

    def destroy_all(self):
        # Stop acquisition
        self.__stop_acquisition()

        # Close device and peak library
        # self.__close_device()
        self.__device =   None
        ids_peak.Library.Close()

    def __open_device(self):
        try:
            # Create instance of the device manager
            device_manager = ids_peak.DeviceManager.Instance()

            # Update the device manager
            device_manager.Update()

            # Return if no device was found
            if device_manager.Devices().empty():
                print("Error: ", "No device found!")
                return False

            # Open the first openable device in the managers device list
            for device in device_manager.Devices():
                if device.IsOpenable():
                    self.__device = device.OpenDevice(ids_peak.DeviceAccessType_Control)
                    break

            # Return if no device could be opened
            if self.__device is None:
                print("Error: Device could not be opened!")
                return False

            # Open standard data stream
            datastreams = self.__device.DataStreams()
            if datastreams.empty():
                print("Error: Device has no DataStream!")
                self.__device = None
                return False

            self.__datastream = datastreams[0].OpenDataStream()

            # Get nodemap of the remote device for all accesses to the genicam nodemap tree
            self.__nodemap_remote_device = self.__device.RemoteDevice().NodeMaps()[0]

            # To prepare for untriggered continuous image acquisition, load the default user set if available and
            # wait until execution is finished
            try:
                self.__nodemap_remote_device.FindNode("UserSetSelector").SetCurrentEntry("Default")
                self.__nodemap_remote_device.FindNode("UserSetLoad").Execute()
                self.__nodemap_remote_device.FindNode("UserSetLoad").WaitUntilDone()
            except ids_peak.Exception:
                # Userset is not available
                pass

            # Get the payload size for correct buffer allocation
            payload_size = self.__nodemap_remote_device.FindNode("PayloadSize").Value()

            # Get minimum number of buffers that must be announced
            buffer_count_max = self.__datastream.NumBuffersAnnouncedMinRequired()

            # Allocate and announce image buffers and queue them
            for _ in range(buffer_count_max):
                buffer = self.__datastream.AllocAndAnnounceBuffer(payload_size)
                self.__datastream.QueueBuffer(buffer)

            return True
        except ids_peak.Exception as e:
            print("Exception in OPEN DEVICE: ", str(e))

        return False
    
    def __close_device(self):
        """
        Stop acquisition if still running and close datastream and nodemap of the device
        """
        # Stop Acquisition in case it is still running
        self.__stop_acquisition()

        # If a datastream has been opened, try to revoke its image buffers
        if self.__datastream is not None:
            try:
                for buffer in self.__datastream.AnnouncedBuffers():
                    self.__datastream.RevokeBuffer(buffer)
            except Exception as e:
                print("Exception in CLOSE DEVICE: ", str(e))

    def __start_acquisition(self):
        """
        Start Acquisition on camera and start the acquisition timer to receive and display images

        :return: True/False if acquisition start was successful
        """
        # Check that a device is opened and that the acquisition is NOT running. If not, return.
        if self.__device is None:
            return False
        if self.__acquisition_running is True:
            return True
        
        exposure_time_node = self.__nodemap_remote_device.FindNode("ExposureTime")
        if exposure_time_node.IsWriteable() :
            exposure_time_node.SetValue(self._exp_time) # Set exposure time to 20,000 microseconds (20 ms)
            print(f"Exposure time set to {exposure_time_node.Value()} microseconds")
        else:
            print("Exposure time is not writable")

        # Get the maximum framerate possible, limit it to the configured FPS_LIMIT. If the limit can't be reached, set
        # acquisition interval to the maximum possible framerate
        try:
            max_fps = self.__nodemap_remote_device.FindNode("AcquisitionFrameRate").Maximum()
            target_fps = min(max_fps, FPS_LIMIT)
            # print(target_fps)
            self.__nodemap_remote_device.FindNode("AcquisitionFrameRate").SetValue(target_fps)
        except ids_peak.Exception:
            # AcquisitionFrameRate is not available. Unable to limit fps. Print warning and continue on.
            print("Warning: ","Unable to limit fps, since the AcquisitionFrameRate Node is"
                                " not supported by the connected camera. Program will continue without limit.")

        # # Setup acquisition timer accordingly
        # self.__acquisition_timer.setInterval((1 / target_fps) * 1000)
        # self.__acquisition_timer.setSingleShot(False)
        # self.__acquisition_timer.timeout.connect(self.on_acquisition_timer)
        # 
        
        

        try:
            # Lock critical features to prevent them from changing during acquisition
            self.__nodemap_remote_device.FindNode("TLParamsLocked").SetValue(1)

            # Start acquisition on camera
            self.__datastream.StartAcquisition()
            self.__nodemap_remote_device.FindNode("AcquisitionStart").Execute()
            self.__nodemap_remote_device.FindNode("AcquisitionStart").WaitUntilDone()
        except Exception as e:
            print("Exception: " + str(e))
            return False

        # # Start acquisition timer
        # self.__acquisition_timer.start()
        # self.__acquisition_running = True
        # self.on_acquisition_timer()
        # self.__frame_counter = 0
    
        # While loop that checks if seconds_left reaches zero
        # If not zero, decrement total time by 1/frame_rate
        seconds_left = self.__time_on
        delta = (1 / target_fps)

        while seconds_left > 0:

            time.sleep(delta)
            self.on_acquisition_timer()
            seconds_left -= delta

        return True

    def on_acquisition_timer(self):
        # print("here")
        """
        This function gets called on every timeout of the acquisition timer
        """
        try:
            # Get buffer from device's datastream
            buffer = self.__datastream.WaitForFinishedBuffer(5000)
            
            # Create IDS peak IPL image for debayering and convert it to RGBa8 format
            ipl_image = ids_peak_ipl_extension.BufferToImage(buffer)
            converted_ipl_image = ipl_image.ConvertTo(ids_peak_ipl.PixelFormatName_BGRa8)

            # Queue buffer so that it can be used again
            
            self.__datastream.QueueBuffer(buffer)
            

            # Get raw image data from converted image and construct a QImage from it
            image_np_array = converted_ipl_image.get_numpy_1D()
            # print(type(converted_ipl_image.Width()))
            image_np_2d = np.reshape(image_np_array,(converted_ipl_image.Height(), converted_ipl_image.Width(),4))
            # image_to_save = np.mean(image_np_2d[:,:,0:2],axis=2)
            # print(image_to_save.shape)
            # print('1d array length:\t',len(image_np_array))
            # print('WidthxHeight:\t',converted_ipl_image.Width(),'x',converted_ipl_image.Height())
            # scipy.misc.toimage(image_to_save, cmin=0.0, cmax=...).save('outfile.jpg')
            # scipy.misc.imsave('outfile.jpg', image_to_save)
            
            data = im.fromarray(image_np_2d) 

            if self.__frame_counter == 0:
                try:
                    os.mkdir(self.__out_dir)
                except PermissionError:
                    print(f"Permission denied: Unable to create '{self.__out_dir}'.")
                except Exception as e:
                    print(f"An error occurred: {e}")

            name = 'outfile' + str(self.__frame_counter) + '.png'
            saving_dir = os.path.join(self.__out_dir,name)
            print(saving_dir)
            data.save(saving_dir) 

            # Increase frame counter
            self.__frame_counter += 1
        except ids_peak.Exception as e:
            self.__error_counter += 1  
            print("Exception: " + str(e))

        # print("here")
        # Update counters
        # self.update_counters()


    def __stop_acquisition(self):
        """
        Stop acquisition timer and stop acquisition on camera
        :return:
        """
        # Check that a device is opened and that the acquisition is running. If not, return.
        if self.__device is None or self.__acquisition_running is False:
            return

        # Otherwise try to stop acquisition
        try:
            remote_nodemap = self.__device.RemoteDevice().NodeMaps()[0]
            remote_nodemap.FindNode("AcquisitionStop").Execute()

            # Stop and flush datastream
            self.__datastream.KillWait()
            self.__datastream.StopAcquisition(ids_peak.AcquisitionStopMode_Default)
            self.__datastream.Flush(ids_peak.DataStreamFlushMode_DiscardAll)

            self.__acquisition_running = False

            # Unlock parameters after acquisition stop
            if self.__nodemap_remote_device is not None:
                try:
                    self.__nodemap_remote_device.FindNode("TLParamsLocked").SetValue(0)
                except Exception as e:
                    print("Exception in UNLOCKING PARAMETERS", str(e))

        except Exception as e:
            print("Exception in STOP ACQUISITION", str(e))

    
    
    
    def update_counters(self):
        """
        This function gets called when the frame and error counters have changed
        :return:
        """

    
        # self.__label_infos.setText("Acquired: " + str(self.__frame_counter) + ", Errors: " + str(self.__error_counter))