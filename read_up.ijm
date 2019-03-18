//get the input file and determine bit depth
inputFile = File.openDialog("Select a *.up(1/2) file");
len = lengthOf(inputFile)
if(49 == charCodeAt(inputFile, len-1)) {
	bits =  8; // '1' is final character
} else if(50 == charCodeAt(inputFile, len-1)) {
	bits = 16; // '2' is final character
} else {
	//we couldn't get the bitdepth from the extension, ask the user
	Dialog.create("Select Pattern Bit Depth");
	Dialog.addChoice("Bit Depth", newArray("8 (.up1)", "16 (.up2)"));
	Dialog.show();
	if("8 (.up1)" == Dialog.getChoice()) {
		bits = 8; 
	} else {//"16 (.up2)"
		bits = 16;
	}
}

if(8 == bits) {
	bitString = "8-bit";
} else {//16
	bitString = "16-bit Unsigned";
}

//read the header and parse
setBatchMode(true);//we don't want to show the header 'image'
run("Raw...", "open=" + inputFile + " image=[32-bit Signed] width=4 height=1 offset=0 number=1 little-endian");
vers = getPixel(0, 0);
width   = getPixel(1, 0);
height  = getPixel(2, 0);
dStart  = getPixel(3, 0);
if(width < 1 || height < 1 || width > 5000 || height > 5000 || dStart < 0) {
	if(vers > 2) {
		height = width;
		width = vers;
		dStart = 8;
	}
	if(width < 1 || height < 1 || width > 5000 || height > 5000 || dStart < 0) {
		Dialog.create("Error");
		Dialog.addMessage("Not a valid *.up(1/2) file");
		Dialog.show();
		return;
	}
}


//now figure out how many images are in the file
dataBytes = File.length(inputFile) - dStart;
maxMB = 256;//lets not go crazy on opening a massive file, limit to this many MB by default
if(8 == bits) {
	patBytes = width * height;//size of a single pattern
} else {//16 bits
	patBytes = width * height * 2;//size of a single pattern
}
patterns = dataBytes / patBytes;
pMB = (maxMB * 1024 * 1024) / patBytes;
if(patterns < pMB) {
	pMB = patterns;//read everything if the file is smaller than our target size
}

//next determine how many images should be read
Dialog.create("Select Pattern Count");
Dialog.addSlider("Patterns", 1, patterns, pMB);
Dialog.show()
count = Dialog.getNumber();

run("Raw...", "open=" + inputFile + " image=[" + bitString + "] width=" + width +" height=" +height + " offset=" + dStart + " number=" + count + " little-endian");
setBatchMode(false);
