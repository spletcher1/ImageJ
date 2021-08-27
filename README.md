## Pletcher Lab ImageJ scripts 
In this repository you will find the latest ImageJ scripts used by the Pletcher laboratory at the University of Michigan to analyze brain images.

### Version 1.0-beta (August 27, 2021)

#### **Installation**

1. Create folder called ‘*PletcherLab*’ in the *plugins/scripts/* folder within the location of the Fiji/ImageJ app.
    a. Note, copy to the scripts folder that is in the **plugins** folder, not the scripts folder that is in the ImageJ installation folder.
2.	Copy all ‘.ijm’ files to the *PletcherLab* directory.
3.  Restart ImageJ and the scripts can be accessed under the new PletcherLab menu item.



#### **CaMPARI Image Analysis Script**
##### Usage
1.  Click on the *PletcherLab>Analyze Campari RatioPlus* menu item.
2. Set the parameters for the analysis. 
    1. Specify the directory in which the stack files are located. This directory must not have a subdirectory called "Projections" located within.  If so, rename it.
    2. Choose the starting and ending slices between which projections will be calculated. They do not need to be adjusted to include all stacks.  If ending slice is larger than the number of available slices, the images up to and including the last slice will be used.
    3. Choose the type of projection that will be used to merge the information in the chosen slices.
    4. Choose a background rolling window over which a local background correction will be applied.  If this is specified as zero, no background subtraction will be applied.
    5. Choose the percentage of saturated pixels for contrast enhancement for the channels in the stack.  If this is specified as zero, no contrast enhancement will be applied.
    6. Choose the percentage of saturated pixels for contrast enhancement specifically for the ratio projection.  If this is specified as zero, no contrast enhancement will be applied.
    7. Specify the file identifier for the stack files.
3. Click OK.
    

##### Script Mechanics
1. First, this script will identify all stack files (by file extension defined in '2g') in the specified directory (as specified in '2a') and a projection image for each channel according to the following procedure.
    1. Open the stack file in ImageJ (autoscaling, hyperstack order XYCZT)
    2. Execute a median filter with a pixel radius of 5 pixels on all slices to remove noise.
    3. Execute the projection of the chosen type (as specified in 'c') over the chosen slices (as specified in '2b').  Do this for each channel.
    4. If the rolling background window > 0 (as specified in '2d'), then the Subtract Background function is applied to the projection (all channels) with the specified window.
    5. If the contrast enhancement for channels > 0 (as speficied in '2e') then the Enhance Contrast function is applied to the projection (all channels) with the specified saturation.
    6. The projection is saved in the '*Projections*' subdirectory. If there are multiple channels in the original stack file, there will be the same number of channels in the projection.
    7. Close the original stack file.
    
2. Second, for each of the stack files identified in step 1, the script will next create projections that are formed from the ratio (slice by slice) of channel 2 to channel 1.  This is meant to be used for CaMPARI imaging where channel 1 is GFP and channel 2 is RFP.
    1. Open the stack file in ImageJ (autoscaling, hyperstack order XYCZT)
    2. Execute a median filter with a pixel radius of 5 pixels on all slices to remove noise.
    3. Split the channels.
    4. Execute the *Ratio Plus* plugin (background1=10 clipping_value1=20 background2=10 clipping_value2=20 multiplication=2) to create a stack of images formed by the ratio of each slice from each of the two channels, where the ratio is Channel 2/Channel 1.
    5. Execute a '*sum slices*' projection over the chosen slices (as specified in '2b').
    6. If the contrast enhancement for channels > 0 (as speficied in '2e'), then the Enhance Contrast function is applied to the projection with the specified saturation.
    7.  If the rolling background window > 0 (as specified in '2d'), then the Subtract Background function is applied to the projection with the specified window.
    8.  The projection (now a single channel) is saved in the '*Projections/Ratio*' subdirectory. 
    9.  Close the original stack file.
    
3. Third, the script will isolate the individual channels into separate files and create a montage image for easy viewing of the data.
    1. For each projection file in the '*Projections*' subdirectory, the channels are separated and each corresponding image is saved in either the '*Projections/Green*' (for Channel 1) or '*Projections/Red*' (for Channel 2) subdirectory.
    2. At this point there will be three folders (*Green*, *Red*, and *Ratio*).  In each folder there will be a single image for each of the original stacks, corresponding to the processed and projected data.
    3. In each directory, a montage of all the images in that directory will be made using the '*pub montag*' plugin.  The first time this is executed, the user must input the number of rows and columns desired for the montage.  It is recommended that a number of columns be chosen to divide up the treatments appropriately. The Close Stack After option should be selected.  An image scaling factor and image with of 2 works well; the 'no border' option should be chosen; and the file name should be checked to label each image.
    4. Click Ok and then Ok again to run each of the three montages.

    
#### **CaMPARI ROI Analysis Script**
##### Usage
1.  Open the images that you would like to analyze in ImageJ by highlighting them in windows explorer and dragging the files onto the ImageJ application.  This script will work for single images as well as for files with multiple slices/channels.  
      a. For CaMPARI analysis, you would focus on the files in the "*Projections*" directory to analyze both green and red channels simultaneously.
2.  Click on the *PletcherLab>Measure On Mouse Click* menu item.
3.  Choose whether your ROI will be a rectangle or circle. Click Ok.
4.  Define the size of the ROI according to width/height or radius. Click Ok.
5.  Pick one of the images by activating the window with a left mouse click. Choose a channel in which your structure of interest is mostly clearly visible.  Left click the mouse directly in the center of the desired ROI.  This ROI will be added to each channel, and the *Measure* function will be executed.  The data from the ROI on both channels will be added to the *Results* window. The ROI will then be cleared from the ROI manager, and you are ready to click on a second ROI in that image or to choose another image for analysis.
6.  When finished with the current image, close it, and left click to activate the next image window. Then repeat step #5 until all the images are analyzed.
7.  As additional images/ROIs are defined, the *Measure* results will be appended to the *Results* window.  You can terminate the script by a right mouse click or by closing all of the images.  When terminated, a dialog window will notify you that the script has ended, and the data in the *Results* window will be automatically copied to the clipboard.  At this point you should switch to Excel or a similar program and paste your results.
      1. Note that the second column will indicate the file from which the measure results were obtained, and the sixth column will indicate the channel, if multiple channels/slices were quantified. The fourth column contains the mean pixel value in the ROI and is the measure of interest.
      2. If you receive an error dialog about window focus, you will need to restart the script.  Make sure to check the results table for the files that were successfully saved.
      3. Tip. I find it easiest to run this scripts on images from single treatments at a time.  First I open all the images from, say, Group 1.  Then analyze the ROI and copy the data to excel.  Then I repeat this procedure for the other groups. When doing this, remember to clear the results table between groups.
    


