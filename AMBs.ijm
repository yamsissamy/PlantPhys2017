macro "AMBs" {
	Dialog.create("Save All?");
	Dialog.addChoice("Save all intermediate step outputs?", newArray("No","Yes"));
	Dialog.show();
	saveAll = Dialog.getChoice();
	
	// Selects directory where the microtubule z-stacks are located. Source images
	title="";
	msg="Select Input Stacks";	
	waitForUser(title,msg);
	myDir = getDirectory("Choose a directory");
	// Selects directory where the output text image files (.txt) and segment xy coordinates (.csv) will be outputted 
	title="";
	msg="Select Output Folder";	
	waitForUser(title,msg);
	outDir = getDirectory("Output");

	if (saveAll == "Yes"){
		intDir = outDir+"Intermediates"+File.separator;
		File.makeDirectory(intDir);
		if (!File.exists(intDir)) exit("Unable to create directory");
	}
	
	/* 
	 *  Selects ROI zip file which were manually traced and are in the following format ##-##-##
	 *  First set of #'s are Time-point e.g. 05
	 *  Second set of #'s are z-slide from which that segment starts, e.g. 01
	 *  Third set of #'s are z-slide from which the segment ends, e.g. 18
	 *  e.g. 05-01-18 is time-point 5 from which a duplicate z-stack will be created from z-slide 1 to 18 
	 *  which encompases the whole traced segment 
	 */ 
	title="";
	msg="Select ROI file";	
	waitForUser(title,msg);
	roiFile = File.openDialog("Select ROI zip file");
	list= getFileList(myDir);
	m = lengthOf(list);
	roiManager("reset"); 
	roiManager("open",roiFile);
	n = roiManager("count"); // Counts number of ROIs
	newImage("M", "16-bit white", 512, 512, 1);
	run("Properties...", "channels=1 slices=1 frames=1 unit=µm pixel_width=.212 pixel_height=.212 voxel_depth=.5 global");
	selectWindow("M");close();
	setBatchMode(true);
	for (i=0; i<n; i++){
		newImage("M", "16-bit white", 512, 512, 1);
		roiManager("select",i);
		r = getInfo("roi.name");
		selectWindow("M");close();
		t=substring(r,0,2);
		fileName = "T"+t+".tiff";
		open(myDir + fileName);
		ID1=getImageID();
 		original=getTitle();
 		fileName=File.nameWithoutExtension();
		
		
		/*
		 * Next bloxk of code will extract information from the ROI names for stack duplication 
		 * only having the slides that contain the segment of interest as defined by the user
		 */
 		
 		zmin = substring(r,3,5);
 		zmax = substring(r,6,8);
  		run("Duplicate...", "duplicate range=&zmin-&zmax");
 		ID2=getImageID();
 		selectImage(ID2);

 		/*
 		 * Next block will first smooth the images, subtrack background using the rolling ball method 
 		 * using a bal radius of 15 pixels then sharpen the image
 		 */
 		run("Smooth", "stack");
		run("Subtract Background...", "rolling=15 stack");
		run("Sharpen", "stack");

 		if (saveAll == "Yes"){
		newName = "RB15_"+original;
		saveAs("tiff", intDir+newName);
		}
 		/*
 		 * Next block will straighten the segment
 		 * set the correct resoulution for x,y,and z
 		 * Reslice the image with .212 output 
 		 * Project the reslice using SUM slice projection method and
 		 * output the image as a text image in the output folder 
 		 * as a .txt file
 		 */
 		roiManager("select",i);
 		run("Straighten...", "title=Straight line=20 process");
 		ID3=getImageID();
		if (saveAll == "Yes"){
		newName = "ST_RB15_"+original;
		saveAs("tiff", intDir+newName);
		}
 		
 		selectImage(ID2);close();
 		selectImage(ID3);
 		setVoxelSize(0.212, 0.212, 0.5, "um");
 		run("Select All");
 		run("Reslice [/]...", "output=.212 start=Top flip");
 		ID4=getImageID();
 		if (saveAll == "Yes"){
		newName = "Resl_ST_RB15_"+original;
		saveAs("tiff", intDir+newName);
		}
		
 		selectImage(ID3);close();
 		selectImage(ID4);
 		run("Z Project...", "projection=[Sum Slices]");
 		ID5=getImageID();
 		if (saveAll == "Yes"){
		newName = "SUM_Resl_ST_RB15_"+original;
		saveAs("tiff", intDir+newName);
		}
		
 		selectImage(ID4);close();
 		selectImage(ID5);
 		saveAs("Text Image",outDir+original);
 		selectImage(ID1);
		
 		/*
 		 * Next block will extract the xy-coordinates of the ROI and save them as a .csv file
 		 */
 		roiManager("select",i);
 		Roi.getCoordinates(x, y);
		run("Clear Results");
		for (j=0; j<x.length; j++){
			setResult("X",j,x[j]);
			setResult("Y",j,y[j]);
			}
		setOption("ShowRowNumbers",false);
		updateResults;
		csvName=fileName+".csv";
		saveAs("Results",outDir+csvName);
 		selectImage(ID1);close();
 		selectImage(ID5);close();
 		}
 		selectWindow("ROI Manager");run("Close");
 		selectWindow("Results");run("Close");
}
