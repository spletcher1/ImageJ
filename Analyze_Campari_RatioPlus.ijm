
#@ File (label = "Input directory", style = "directory") inputDir
#@ Integer (label="Starting slice", style="slider", min=1, max=30, stepSize=1, value=1, persist=false) startSlice
#@ Integer (label="Ending slice", style="slider", min=1, max=30, stepSize=1, value=30, persist=false) endSlice
#@ String (label="Projection type (channel): ", choices={"Max", "Average", "Min","Median","Sum"}, style="radioButtonHorizontal") projectionType
#@ Float   (label="Enhance contrast (channel)", style="slider", min=0, max=1, stepSize=0.05, value=0.35) theContrast
#@ String (label="Projection type (ratio): ", choices={"Max", "Average", "Min","Median","Sum"}, style="radioButtonHorizontal") projectionTypeRatio
#@ Float   (label="Enhance contrast (ratio)", style="slider", min=0, max=1, stepSize=0.05, value=0.2) theContrastForRatio
#@ Integer (label="Background rolling", style="slider", min=0, max=200, stepSize=2, value=50, persist=false) rollingBackground
#@ String (label = "Stack file suffix", value = ".oir") suffix

stackDirectory = inputDir;
projectionDirectory = inputDir+"/Projections/"
greenDirectory = projectionDirectory+"/Green/"
redDirectory = projectionDirectory+"/Red/"
ratioDirectory=projectionDirectory+"/Ratio/"

main();

function main(){
	CheckParameters();
	CreateDirectories();
	ProcessStacks();
	ProcessProjections();
	MakeRedMontage();
	MakeGreenMontage();
	MakeRatioMontage();
	SaveParameters();
}


function SaveParameters(){
	tmp = projectionDirectory +"\\Parameters.txt";
	file = File.open(tmp);
	print(file,"Starting slice: " + startSlice);
	print(file,"Ending slice: " + endSlice);
	print(file,"Projection Type: " + projectionType);
	print(file,"Rolling Backgroud: " + rollingBackground);
	print(file,"Contrast Saturation: " + theContrast);
	print(file,"Contrast Saturation (Ratio): " + theContrastForRatio);
	File.close(file);
	
}

function CreateDirectories(){
	File.makeDirectory(projectionDirectory); 
	File.makeDirectory(greenDirectory); 
	File.makeDirectory(redDirectory); 
	File.makeDirectory(ratioDirectory); 
}

function CheckParameters(){	
	if(endSlice<startSlice+1){
		exit("Incorrect slice designations!!")	
	}
	if(projectionType == "Max")
		projectionType = "[Max Intensity]";
	else if(projectionType == "Average")
		projectionType = "[Average Intensity]";
	else if(projectionType == "Min")
		projectionType = "[Min Intensity]";
	else if(projectionType == "Median")
		projectionType = "Median";
	else if(projectionType == "Sum")
		projectionType = "[Sum Slices]";
	else
		projectionType = "[Max Intensity]";

	if(projectionTypeRatio == "Max")
		projectionTypeRatio = "[Max Intensity]";
	else if(projectionTypeRatio == "Average")
		projectionTypeRatio = "[Average Intensity]";
	else if(projectionTypeRatio == "Min")
		projectionTypeRatio = "[Min Intensity]";
	else if(projectionTypeRatio == "Median")
		projectionTypeRatio = "Median";
	else if(projectionTypeRatio == "Sum")
		projectionTypeRatio = "[Sum Slices]";
	else
		projectionTypeRatio = "[Max Intensity]";
}


// function to scan folders/subfolders/files to find files with correct suffix
function ProcessStacks() {	
	list = getFileList(stackDirectory);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {		
		if(endsWith(list[i], suffix)) {
			processStackFile(list[i]);	
			processRatioStackFile(list[i]);		
		}
	}
}

function processStackFile(file) {
	print("Stack: " + file);
	fileName = stackDirectory + File.separator + file;
	run("Bio-Formats", "check_for_upgrades open=[" + fileName + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	effectiveEndSlice=(nSlices/2)-1;	
	if(endSlice<effectiveEndSlice){
		effectiveEndSlice = endSlice;
	}
	
	run("Median...", "radius=0.5");	
	command = "start=" + startSlice + " stop=" + effectiveEndSlice + " projection="+projectionType;
	
	run("Z Project...", command);

	setSlice(1);
	if(rollingBackground>0){	
		run("Subtract Background...", "rolling="+rollingBackground);
	}
	if(theContrast>0) {	
		run("Enhance Contrast", "saturated="+theContrast);
	}
	setSlice(2);
	if(rollingBackground>0){	
		run("Subtract Background...", "rolling="+rollingBackground);
	}
	if(theContrast>0) {	
		run("Enhance Contrast", "saturated="+theContrast);
	}

	
	imageTitle = getTitle();
	saveAs("Tiff", projectionDirectory + File.separator + imageTitle);
	run("Close All");
}

function processRatioStackFile(file) {
	print("Stack: " + file);
	fileName = stackDirectory + File.separator + file;
	run("Bio-Formats", "check_for_upgrades open=[" + fileName + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	effectiveEndSlice=(nSlices/2)-1;	
	if(endSlice<effectiveEndSlice){
		effectiveEndSlice = endSlice;
	}
	
	run("Median...", "radius=0.5");

	tmpTitle = getTitle();
	c1Title="C1-"+tmpTitle;
	c2Title="C2-"+tmpTitle;
	run("Split Channels");
	run("Ratio Plus", "image1="+c2Title+ " image2=" + c1Title + " background1=10 clipping_value1=20 background2=10 clipping_value2=20 multiplication=2");	
	close(c1Title);
	close(c2Title);	
	command = "start=" + startSlice + " stop=" + effectiveEndSlice + " projection="+projectionTypeRatio;	
	rename(tmpTitle);
	run("Z Project...", command);
	if(rollingBackground>0){	
		run("Subtract Background...", "rolling="+rollingBackground);	
	}
	if(theContrastForRatio>0){
		run("Enhance Contrast", "saturated="+theContrastForRatio);
	}
	imageTitle = getTitle();
	saveAs("Tiff", ratioDirectory + File.separator + imageTitle);
	run("Close All");
}


function ProcessProjections() {	
	list = getFileList(projectionDirectory);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {		
		if(endsWith(list[i], ".tif")) {
			ProcessProjectionFile(list[i]);			
		}
	}
}

function ProcessProjectionFile(file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	dotIndex = indexOf(file, "." );
	nameWithoutExtension = substring( file, 0, dotIndex);
	name1 = nameWithoutExtension+"_ch1";
	name2 = nameWithoutExtension+"_ch2";	
	print("Projection: " + file);	
	open(projectionDirectory + File.separator + file);	
	
	imageTitle = getTitle();
	run("Duplicate...", "title="+name1+" duplicate channels=1");				
	saveAs("Tiff", greenDirectory + File.separator + name1 +".tif");
	//close();
	selectWindow(imageTitle);	
	run("Duplicate...", "title="+name2+" duplicate channels=2");	
	saveAs("Tiff", redDirectory + File.separator + name2 + ".tif");
	run("Close All");
}

function MakeRedMontage(){
	OpenAllRed();
	run("pub montage");
	saveAs("Tiff", redDirectory + File.separator + "RedMontage");
	run("Close All");
}

function MakeRatioMontage(){
	OpenAllRatio();
	run("pub montage");
	saveAs("Tiff", ratioDirectory + File.separator + "RatioMontage");
	run("Close All");
}

function MakeGreenMontage(){
	OpenAllGreen();
	run("pub montage");
	saveAs("Tiff", greenDirectory + File.separator + "GreenMontage");
	run("Close All");
}

function OpenAllRed(){
	list = getFileList( redDirectory );
	for ( i=0; i<list.length; i++ ) {
    	open( redDirectory + list[i] );
	}
}

function OpenAllRatio(){
	list = getFileList( ratioDirectory );
	for ( i=0; i<list.length; i++ ) {
    	open( ratioDirectory + list[i] );
	}
}


function OpenAllGreen(){
	list = getFileList( greenDirectory );
	for ( i=0; i<list.length; i++ ) {
    	open( greenDirectory + list[i] );
	}
}