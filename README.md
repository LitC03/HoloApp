# HoloApp

MATLAB App originally developed by Glenn Howe. Commented (and hopefully optimised) by Lito Chatzidavari.

The HoloApp is a MATLAB App to interface with the 1920x1152 Spatial Light Modulator (SLM) by MeadowLarks Optics in the following setup:

![Optical setup for SLM](/assets/SLM_setup.png)


HoloApp allows users to pick and edit the images that will appear on the detector. The phase delay the SLM applies onto each of its pixels is calculated using the Gerchberg-Saxton (GS) routine.


**To use, open the HoloApp_Lito.mlapp file in the `scr` directory.**


## Running the App if you ...

### 1. Already have an image that you want to display on the focal plane of your lens

1. Put your image in the `img/tgt` directory.

2. Check that you are connected to the SLM by ensuring that the 'SLM connected?' lamp is green. If you think you should be connected, check MATLAB's terminal for errors or try opening the app again.

3. On the left, on the "Step 1" tab, choose your picture. A preview of it should appear on the left figure in the centre of the app. You can move the image around using the sliders or the editable boxes next to them. You can also scale the image to your liking by changing the "Scale Target" value.

4. Go to the "Step 2+3" tab and adjust your parameters for number of iterations for the GS routine and beam diameter. When you are done, press the "Apply GS routine" button. A phase map and an estimate of your image will appear on the right-side figures.

5. At the bottom of the tab, in "3. Apply to SLM", select your desired wavelength and press "Apply to SLM". You should see your image at the focal plane of your lens!

### 2. Already have a phase map you want to apply to the SLM

> [!NOTE]
> **Your phase map should be a 1920x1152 .bmp file for this to work.**

1. Put your phase map in the `img/out` directory.

2. On the left of the app, on the "Step 2+3" tab, choose your image from the listbox titled "Or add already-generated phase map", you will see a preview of the phase map and an estimate of the target on the two top figures in the centre of the app.

3. At the bottom of the tab, in "3. Apply to SLM", select your desired wavelength and press "Apply to SLM". You should see your image at the focal plane of your lens!

### 3. Want one or more circles displayed

1. Go to the "Extra: move many circles" tab on the left of the app and press the "Add circle" button. You should see a white circle on a black baground on the "Target Image" figure. You can move it around with the sliders or with the editable boxes. The diameter of the circle can also be changed using the "Diameter (mm) - on SLM Surface" field. Note that changes will only be visible once you press the "Apply changes" button.

	You can add more circles by pressing the "Add circle" button. Deletion of the last 	circle is also possible with the "Remove last circle" button. You can pick which 	circle to edit using the "Circle selection" dropdown list. 

2. Once you are satisfied with your target image, follow steps 4 and 5 from Section 1. to see your image on your detector.

### 4. Want a to combine different images

1. On the left side of the app, go to the "Extra: Add multiple pictures tab" and choose one of the images you want to add. A preview of the image will appear at the bottom of the tab. Press the "Add Image" button and the image should appear on the "Target Image" figure in the centre of the app. You can repeat this step to add all the images you want.

2. On the next tab ("Extra: moving pictures") you can edit the scaling and position of the images using the sliders and the editable fields with the appropriate titles. Just choose the image you want to edit from the "Image selection" dropdown list, make your required modifications and press the "Apply changes" button.

3. Once you are satisfied with your target image, follow steps 4 and 5 from Section 1. to see your image on your detector.


## Target size (pixels)

Even though the SLM has a specific amount of pixels (1920x1152), the way we compute the phase delay has a tremendous effect on the image we see on the detector. For this reason, the HoloApp allows users to decide how this is done.

### 1920x1920 (recommended)

In this method, a 1920x1920 square is considered as the target, the phase is computed using the GS routine and the square is cut to fit the SLM dimensions.

### 1152x1152 

The considered target is a 1152x1152 square. The phase is only calculated for that square and the result is padded with zeros to fit the SLM dimensions.

### 1920x1152

The target and phase have the same dimensions as the SLM and no editing is done to this result. This setting is not recommended as it distorts the image in the Fourier Domain, squeezing it in the horizontal direction.
