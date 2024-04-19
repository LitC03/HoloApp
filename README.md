# HoloApp

MATLAB App originally developed by Glenn Howe. Commented (and hopefully optimised) by Lito Chatzidavari.

The HoloApp is a MATLAB App to interface with the 1920x1152 Spatial Light Modulator (SLM) by MeadowLarks Optics in the following setup:

![](/other media/SLM_setup.png)


HoloApp allows users to choose and edit the images they can see on the detector by applying the Gerchberg-Saxton routine to retrieve the phase delays the SLM needs to apply to them.


To use, open the HoloApp_Lito file.


## Running the App if you ...

### 1. Already have an image that you want to display on the focal plane of your lens

- Put your image in the img/tgt folder.

	- Check that you are connected to the SLM by checking that the 'SLM connected?' lamp is green. If you think you should be connected, check MATLAB's terminal for errors or try opening the app again.

	- On the left, on the 'Step 1' tab, choose your picture. a preview of it should appear on the left figure in the centre of the app.

	- Go to the 'Step 2+3' tab and adjust your parameters for number of GS iterations and beam diameter. When you are done, press the 'Apply GS routine' button. A phase map and an estimate of your image will appear on the right-side figures.

	- At the bottom of the tab, in '3. Apply to SLM', select your desired wavelength and press 'Apply to SLM'. You should see your image at the focal plane of your lens!

### 2. Already have a phase map you want to apply to the SLM

Your image should be a 1920x1152 .bmp file in order for this to work.

	- Put your phase map in the img/out folder.

	- On the left, on the 'Step 2+3' tab, choose your image from the

	- At the bottom of the tab, in '3. Apply to SLM', select your desired wavelength and press 'Apply to SLM'. You should see your image at the focal plane of your lens!

### 3. Want to have one or more circles displayed

### 4. 