#@ String (choices={"Circle", "Rectangle"}, style="radioButtonHorizontal") objectType

main();

function main(){
	if(nImages<=0) {
			Dialog.create("Script Complete");
	  		Dialog.addMessage("Must have open images! Script terminated.");
	  		Dialog.show();      				 
      		exit();
	}
	if(objectType=="Circle"){
		CircleOn_MouseClick();
	}
	else if(objectType=="Rectangle"){
		RectangleOn_MouseClick();
	}
	Dialog.create("Script Complete");
	Dialog.addMessage("Script ended; results copied to clipboard.");
	Dialog.show();      
	String.copyResults();		
}

function RectangleOn_MouseClick(){
        setOption("DisablePopupMenu", true);
        getPixelSize(unit, pixelWidth, pixelHeight);
        setTool("rectangle");
        leftButton=16;
        rightButton=4;
        width = 50;
        height = 50;
        Dialog.create("Settings");
        Dialog.addNumber("Set height of rectangle", height);
        Dialog.addNumber("Set width of rectangle", width);
        Dialog.show();
        height = Dialog.getNumber();
        width = Dialog.getNumber();      
        x2=-1; y2=-1; z2=-1; flags2=-1;
        getCursorLoc(x, y, z, flags);
        wasLeftPressed = false;
        while (flags&rightButton==0){        		
        		if(nImages<=0) {        			 				
      				 return;
        		}
                getCursorLoc(x, y, z, flags);               
                if (flags&leftButton!=0) {
                	// Wait for it to be released
                	wasLeftPressed = true;
                } 
                else if (wasLeftPressed) {
                	wasLeftPressed = false;
                	if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
                                x = x - width/2;
                                y = y - height/2;
                                makeRectangle(x, y, width, height);
                                roiManager("Add");
                                if(nSlices>1) {
                                	roiManager("multi-measure measure_all one append");
                                }
                                else {
                                	roiManager("measure");
                                }
                                roiManager("reset");
                                 
                        }
                }
      }    
      setOption("DisablePopupMenu", false);
      return;      
}

function CircleOn_MouseClick(){
        setOption("DisablePopupMenu", true);
        getPixelSize(unit, pixelWidth, pixelHeight);
        setTool("rectangle");
        leftButton=16;
        rightButton=4;
        radius = 100;
        Dialog.create("Settings");
        Dialog.addNumber("Set radius of circle", radius);
        Dialog.show();
        radius = Dialog.getNumber();
        height = 2*pixelHeight*radius;
        width = 2*pixelWidth*radius;
        x2=-1; y2=-1; z2=-1; flags2=-1;
        getCursorLoc(x, y, z, flags);
        wasLeftPressed = false;
        while (flags&rightButton==0){
        		if(nImages<=0) {
        			return;
        		}
                getCursorLoc(x, y, z, flags);               
                if (flags&leftButton!=0) {
                	// Wait for it to be released
                	wasLeftPressed = true;
                } 
                else if (wasLeftPressed) {
                	wasLeftPressed = false;
                	if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
                                x = x - width/2;
                                y = y - height/2;
                                makeOval(x, y, width, height);
                                roiManager("Add");
                                if(nSlices>1) {
                                	roiManager("multi-measure measure_all one append");
                                }
                                else {
                                	roiManager("measure");
                                }
                                roiManager("reset");
                                 
                        }
                }
      }      
      setOption("DisablePopupMenu", false);
      return;
}