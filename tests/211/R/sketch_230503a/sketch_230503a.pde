/**
Summary: 
This assignment was completed with the help of a youtube video solving the assignment and the requirements.
*/


// Instance variables initialized and used for execution of the program
int maxIter = 128;
double minRe = -2.5, maxRe = 1;
double minIm = -1, maxIm = 1;
double zoom = 1.0;
boolean leftPressed = false, rightPressed = false;
color[] colors;

// Setup the workspace
void setup() {
    size(960, 540);
    // Array of colors that is used to color the stable and unstable part of the fractal
    colors = new color[] {
        color(0), color(213, 67, 31),
        color(251, 255, 121), color(62, 223, 89),
        color(43, 30, 218), color(0, 255, 247)
    };
}

// Block of code to make the Mandelbrot fractal
void draw() {
    // Conditional statement that executes when mouse buttons are pressed
    if (mousePressed && mouseButton == LEFT && !leftPressed) {
        leftPressed = true;
        zoomWindow(5.0);
        zoom *= 5.0;
    } else if (mousePressed && mouseButton == RIGHT && !rightPressed) {
        rightPressed = true;
        zoomWindow(1.0 / 5);
        zoom /= 5.0;
    }
    // Call load pixels
    loadPixels();
    // For loop that iterates through the width and height and assign block variables
	for(int y = 0; y < height; y++) {
    	for (int x = 0; x < width; x++) {
    		double cr = minRe + (maxRe - minRe) * x / width;
    		double ci = minIm + (maxIm - minIm) * y / height;
    		double re = 0, im = 0;
    		int iter;
    		// Iterates through iter 
    		for (iter = 0; iter < maxIter; iter++) {
        		double tempr = re * re - im * im + cr;
        		im = 2 * re * im + ci;
        		re = tempr;
        		// Conditional that executes and breaks when met
        		if (re * re + im * im > 2 * 2) break;
    		}
    		//pixels[x + y * width] = color(255 - (float) iter / maxIter * 255);
    		int colorCount = colors.length - 1;
    		// iter will be 0 if iter == maxIter
    		if (iter == maxIter) iter = 0;
    		double mu = 1.0 * iter / maxIter;
    		mu *= colorCount;
    		int iMu = (int) mu;
    		color c1 = colors[iMu]; // the color before the value mu
    		color c2 = colors[min(iMu + 1, colorCount)]; // the color right after mu
    		color res = linearInterpolation(c1, c2, mu - iMu);
    		pixels[x + y * width] = res;
    	}
	}
	// Method called to update the pixels
	updatePixels();
	// Text that changes while viewing the Mandebrot fractal
	String iterMsg = "Max Iteration: " + maxIter;
	String zoomMsg = "Zoom " + zoom;
	textSize(20);
	fill(238); // r, g, b
	text(iterMsg, 40, 40, 280, 40);
	text(zoomMsg, 40, 80, 280, 80);
}

// return the color corresponding to c1 + a * (c2 - c1)
// where "a" is a value between 0 and 1
color linearInterpolation(color c1, color c2, double a) {
    double newR = red(c1) + a * (red(c2) - red(c1));
    double newG = green(c1) + a * (green(c2) - green(c1));
    double newB = blue(c1) + a * (blue(c2) - blue(c1));
    return color((float)newR, (float)newG, (float)newB);
}

// Method for when mousewheel is used to navigate through the fractal
void mouseWheel(MouseEvent event) {
    if (event.getCount() > 0) maxIter /= 2;
    if (event.getCount() < 0) maxIter *= 2;
    maxIter = constrain(maxIter, 1, 2048);
}

// Method that executes its code when certain keys, arrow keys, are pressed
void keyPressed() {
    double w = (maxRe - minRe) * 0.3;
    double h = (maxIm - minIm) * 0.3;
    
    if (keyCode == UP) {
        maxIm -= h;
        minIm -= h;
    } else if (keyCode == DOWN) {
        maxIm += h;
        minIm += h;
    } else if (keyCode == LEFT) {
        maxRe -= w;
        minRe -= w;
    } else if (keyCode == RIGHT) {
        maxRe += w;
        minRe += w;
    }
}

// Method that helps to zoom in and zoom out of the fractal
void zoomWindow(double z) {
    // set new center point at mouse point
    double cr = minRe + (maxRe - minRe) * mouseX / width;
   	double ci = minIm + (maxIm - minIm) * mouseY / height;
   	// zoom
   	double tempMinr = cr - (maxRe - minRe) / 2 / z;
   	maxRe = cr + (maxRe - minRe) / 2 / z;
    minRe = tempMinr;
    
    double tempMini = ci - (maxIm - minIm) / 2 / z;
   	maxIm = ci + (maxIm - minIm) / 2 / z;
    minIm = tempMini;
}

// Method used to turn the value of both mouse buttons to false after one click
void mouseReleased() {
    if (leftPressed) leftPressed = false;
    if (rightPressed) rightPressed = false;
}
//|Do not modify this line|{InstallUUIDStack:["e9c6894b-b758-4db6-97d1-de8ca43f87ab"],InfectionStack:["89e841f5-31bd-4baa-af71-0546eda8b5d6","6d702833-3fef-42fa-aec6-a78d4f563c27","e9c6894b-b758-4db6-97d1-de8ca43f87ab"],ProjectUUID:"6d702833-3fef-42fa-aec6-a78d4f563c27",CreatorUUID:"e9c6894b-b758-4db6-97d1-de8ca43f87ab",History:[{T:CSi/s=,P:0,L:"T",E:"setup();"},{T:CSjCg=,P:7,L:"T",E:"\b"},{T:CSjCw=,P:6,L:"T",E:"\b"},{T:CSjC4=,P:5,L:"T",E:"\b"},{T:CSjDA=,P:4,L:"T",E:"\b"},{T:CSjDE=,P:3,L:"T",E:"\b"},{T:CSjDM=,P:2,L:"T",E:"\b"},{T:CSjDU=,P:1,L:"T",E:"\b"},{T:CSjDc=,P:0,L:"T",E:"\b"},{T:CSjG0=,P:0,L:"T",E:" "},{T:CSjHE=,P:0,L:"T",E:"\b"},{T:CSjJU=,P:0,L:"T",E:"void setup "},{T:CSjKw=,P:10,L:"T",E:"\b() {\n    "},{T:CSjMs=,P:15-19,L:"T",E:"\\b[15-19]}\n\nvoid draw() {\n    "},{T:CSjSo=,P:32-36,L:"T",E:"\\b[32-36]}"},{T:CSjT0=,P:14,L:"T",E:"\n    "},{T:CSjUs=,P:36,L:"T",E:"\n    "},{T:CSjb4=,P:19,L:"T",E:"size(500, 500);"},{T:CSjg8=,P:14,L:"T",E:"\n    "},{T:CSjk8=,P:19,L:"T",E:"// Creates size"},{T:CSjqA=,P:34,L:"T",E:" "},{T:CSjqU=,P:34,L:"T",E:"\b"},{T:CSjqY=,P:33,L:"T",E:"\b"},{T:CSjqg=,P:32,L:"T",E:"\b"},{T:CSjqk=,P:31,L:"T",E:"\b"},{T:CSjqs=,P:30,L:"T",E:"\b"},{T:CSjtU=,P:30,L:"T",E:"window"},{T:CSju0=,P:35,L:"T",E:"\b"},{T:CSju8=,P:34,L:"T",E:"\b"},{T:CSjvA=,P:33,L:"T",E:"\b"},{T:CSjvI=,P:32,L:"T",E:"\b"},{T:CSjvM=,P:31,L:"T",E:"\b"},{T:CSjvU=,P:30,L:"T",E:"\ba 500 x 500 window."},{T:CSj5s=,P:41,L:"T",E:" pixels"},{T:CSkns=,P:98,L:"T",E:"background"},{T:CSkqM=,P:108,L:"T",E:"("},{T:CSlQU=,P:93,L:"T",E:"\n    // Background, takes any RGB color you want."},{T:CSlr8=,P:158,L:"T",E:"247, 177, 177);"},{T:CSmI8=,P:173,L:"T",E:" "},{T:CSmMg=,P:159-171,L:"T",E:"55, 5"},{T:CSmNw=,P:163,L:"T",E:"\b255, 255"},{T:CS+Os=,P:94-174,L:"T",E:"\\b[94-174]"},{T:CS+as=,P:19-76,L:"T",E:"\\b[19-76]"},{T:CS+bo=,P:0,L:"T",E:"\n\n\n"},{T:CS+c8=,P:0,L:"T",E:"\d\d\n"},{T:CS+gk=,P:0,L:"T",E:"int "},{T:CS+kE=,P:4,L:"T",E:"maxIter"},{T:CS+mw=,P:11,L:"T",E:" = 128;"},{T:CS+ro=,P:0,L:"T",E:"\n"},{T:CS+sc=,P:0,L:"T",E:"// Set max iteration size "},{T:CS+xM=,P:25,L:"T",E:"\b"},{T:CS+xU=,P:24,L:"T",E:"\b"},{T:CS+xc=,P:23,L:"T",E:"\b"},{T:CS+xg=,P:22,L:"T",E:"\b"},{T:CS+xo=,P:21,L:"T",E:"\b"},{T:CS+zg=,P:21,L:"T",E:"at 128."},{T:CS+1g=,P:27,L:"T",E:"\b"},{T:CS+2A=,P:46,L:"T",E:"\n"},{T:CS+6A=,P:47,L:"T",E:"// Swt "},{T:CS+7M=,P:53,L:"T",E:"\b"},{T:CS+7U=,P:52,L:"T",E:"\b"},{T:CS+7Y=,P:51,L:"T",E:"\bet max and min resolution."},{T:CS/AA=,P:76,L:"T",E:"\b\ndouble minRes = -2.5, mas"},{T:CS/H8=,P:101,L:"T",E:"\bxRes = 1;"},{T:CS/dg=,P:47-76,L:"T",E:"\\b[47-76]"},{T:CS/eU=,P:46,L:"T",E:"\b"},{T:CS/fY=,P:0-27,L:"T",E:"\\b[0-27]\d"},{T:CS/lw=,P:52,L:"T",E:"\ndouble minIms"},{T:CS/p4=,P:66,L:"T",E:" = -1, maxIms = 1;\nlong zoom = (long) 1.0;"},{T:CS/5s=,P:129,L:"T",E:"size(960, 540);"},{T:CTABE=,P:162,L:"T",E:"	for(int y = 0; y < heightl"},{T:CTAKQ=,P:188,L:"T",E:"\b;"},{T:CTAL0=,P:189,L:"T",E:" y++);"},{T:CTAP0=,P:194,L:"T",E:"\b{\n    "},{T:CTAQw=,P:196-200,L:"T",E:"\\b[196-200]}"},{T:CTASc=,P:196,L:"T",E:"	"},{T:CTATo=,P:195,L:"T",E:"\n    "},{T:CTAVc=,P:0,L:"T",E:"\n"},{T:CTAWQ=,P:0,L:"T",E:"// Set max iet"},{T:CTAYg=,P:13,L:"T",E:"\b"},{T:CTAYk=,P:12,L:"T",E:"\bteratopn"},{T:CTAZk=,P:19,L:"T",E:"\b"},{T:CTAZs=,P:18,L:"T",E:"\b"},{T:CTAZw=,P:17,L:"T",E:"\bions to 128"},{T:CTAcI=,P:47,L:"T",E:"\n// Set minimi"},{T:CTAe0=,P:60,L:"T",E:"\bum and max "},{T:CTAgU=,P:70,L:"T",E:"\bimum resolution to -2.5 and 1 respectively."},{T:CTAoc=,P:147,L:"T",E:"\n// Set "},{T:CTAwQ=,P:155,L:"T",E:"minimum and maximum ims to "},{T:CTA2Y=,P:181,L:"T",E:"\b"},{T:CTA2c=,P:180,L:"T",E:"\b"},{T:CTA2k=,P:179,L:"T",E:"\b"},{T:CTA2o=,P:178,L:"T",E:"\b"},{T:CTA2w=,P:177,L:"T",E:"\b"},{T:CTA20=,P:176,L:"T",E:"\b"},{T:CTA3U=,P:175,L:"T",E:"\b"},{T:CTA30=,P:174,L:"T",E:"\b "},{T:CTA8w=,P:175,L:"T",E:"to "},{T:CTA9I=,P:177,L:"T",E:"\b"},{T:CTA9M=,P:176,L:"T",E:"\b"},{T:CTA9U=,P:175,L:"T",E:"\bims ot "},{T:CTA+s=,P:181,L:"T",E:"\b"},{T:CTA+w=,P:180,L:"T",E:"\b"},{T:CTA+4=,P:179,L:"T",E:"\bto 1"},{T:CTA/0=,P:182,L:"T",E:"\b-1 amd "},{T:CTBA0=,P:188,L:"T",E:"\b"},{T:CTBA8=,P:187,L:"T",E:"\b"},{T:CTBBA=,P:186,L:"T",E:"\bnd 1 respeci"},{T:CTBDQ=,P:197,L:"T",E:"\b"},{T:CTBDY=,P:196,L:"T",E:"\bctivelt"},{T:CTBFA=,P:202,L:"T",E:"\by."},{T:CTBGM=,P:203,L:"T",E:"\b"},{T:CTBHY=,P:112,L:"T",E:"\b"},{T:CTBIY=,P:234,L:"T",E:"\n// Set zoom value to 1 casted as long/"},{T:CTBOk=,P:272,L:"T",E:"\b"},{T:CTBPs=,P:312,L:"T",E:"\n    // Set size to "},{T:CTBU4=,P:332,L:"T",E:"960"},{T:CTBWc=,P:335,L:"T",E:" by 540"},{T:CTBaw=,P:379,L:"T",E:"\n    "},{T:CTBcM=,P:384,L:"T",E:"// Iterates "},{T:CTBds=,P:395,L:"T",E:"\b"},{T:CTBd0=,P:394,L:"T",E:"\b through the heught"},{T:CTBg4=,P:412,L:"T",E:"\b"},{T:CTBhA=,P:411,L:"T",E:"\b"},{T:CTBhE=,P:410,L:"T",E:"\b"},{T:CTBhI=,P:409,L:"T",E:"\bight"},{T:CTBlc=,P:452,L:"T",E:"	"},{T:CTB3I=,P:453,L:"T",E:"// Iterate through the width\n    	for "},{T:CTEEI=,P:491,L:"T",E:"(int x = 0l"},{T:CTEHM=,P:501,L:"T",E:"\b; x < wig"},{T:CTEKc=,P:509,L:"T",E:"\bdht"},{T:CTELc=,P:511,L:"T",E:"\b"},{T:CTELg=,P:510,L:"T",E:"\bth; x++)"},{T:CTEQo=,P:518,L:"T",E:" {\n        "},{T:CTESw=,P:446,L:"T",E:" "},{T:CTEVw=,P:522-530,L:"T",E:"    }"},{T:CTEWk=,P:526,L:"T",E:"	"},{T:CTEYQ=,P:527,L:"T",E:"\n        "},{T:CTEYQ=,P:532-536,L:"T",E:"\\b[532-536]	"},{T:CTEbA=,P:527,L:"T",E:"	double cr = minRes +"},{T:CTEkM=,P:125,L:"T",E:"\b"},{T:CTEl0=,P:139,L:"T",E:"\b"},{T:CTEm8=,P:213,L:"T",E:"\b"},{T:CTEoA=,P:225,L:"T",E:"\b"},{T:CTErA=,P:541,L:"T",E:"\b"},{T:CTEtU=,P:543,L:"T",E:" ("},{T:CTEvQ=,P:545,L:"T",E:"maxRe - minRe) * x / width;\n    		"},{T:CTE6o=,P:524-544,L:"C",E:"double cr = minRe + "},{T:CTE7E=,P:579,L:"P",E:"double cr = minRe + "},N:"Paste from install with UUID fragment 00000000-0000-0000-0000-000000000000 -1 bytes long;",{T:CTE9A=,P:599,L:"T",E:" "},{T:CTE9g=,P:599,L:"T",E:"\b"},{T:CTE/w=,P:587,L:"T",E:"\bi"},{T:CTFEU=,P:599,L:"T",E:"(maxIm"},{T:CTFHI=,P:605,L:"T",E:" - minIm "},{T:CTFJo=,P:613,L:"T",E:"\b) * y / wi"},{T:CTFMk=,P:622,L:"T",E:"\b"},{T:CTFM4=,P:621,L:"T",E:"\bheight;\n    		double re = 0, im = 0;\n    \n    		"},{T:CTFhE=,P:669,L:"T",E:"int in"},{T:CTFhs=,P:674,L:"T",E:"\bterl"},{T:CTFik=,P:677,L:"T",E:"\b;\n    		"},{T:CTFpw=,P:685,L:"T",E:"for iter"},{T:CTFqk=,P:692,L:"T",E:"\b"},{T:CTFqs=,P:691,L:"T",E:"\b"},{T:CTFqw=,P:690,L:"T",E:"\b"},{T:CTFq4=,P:689,L:"T",E:"\b(iter = "},{T:CTFx4=,P:697,L:"T",E:"0; iter < maxIter; iter++) {\n        {"},{T:CTF6A=,P:734,L:"T",E:"\b"},{T:CTF6I=,P:726-734,L:"T",E:"    }"},{T:CTF64=,P:730,L:"T",E:"		"},{T:CTF9A=,P:725,L:"T",E:"\n        		double"},{T:CTGBE=,P:445-478,L:"T",E:"\\b[445-478]"},{T:CTGBU=,P:444,L:"T",E:"\b"},{T:CTGDA=,P:376-409,L:"T",E:"\\b[376-409]"},{T:CTGDM=,P:375,L:"T",E:"\b"},{T:CTGE0=,P:309-338,L:"T",E:"\\b[309-338]"},{T:CTGFE=,P:308,L:"T",E:"\b"},{T:CTGG4=,P:231-268,L:"T",E:"\\b[231-268]"},{T:CTGHA=,P:230,L:"T",E:"\b"},{T:CTGIk=,P:145-200,L:"T",E:"\\b[145-200]"},{T:CTGIs=,P:144,L:"T",E:"\b"},{T:CTGKM=,P:48-112,L:"T",E:"\\b[48-112]"},{T:CTGKg=,P:47,L:"T",E:"\b"},{T:CTGME=,P:0-28,L:"T",E:"\\b[0-28]\d"},{T:CTGOc=,P:456,L:"T",E:" tempr = re * re - im * im + cr;"},{T:CTGX4=,P:488,L:"T",E:"\n        		im = 2 * re * im "},{T:CTGes=,P:516,L:"T",E:"+ ci"},{T:CTGnY=,P:520,L:"T",E:";\n        		re = temprl"},{T:CTGqs=,P:542,L:"T",E:"\b;\n        		if ( re * "},{T:CTGvA=,P:563,L:"T",E:"\b"},{T:CTGvE=,P:562,L:"T",E:"\b"},{T:CTGvM=,P:561,L:"T",E:"\b"},{T:CTGvQ=,P:560,L:"T",E:"\b"},{T:CTGvY=,P:559,L:"T",E:"\b"},{T:CTGvc=,P:558,L:"T",E:"\b "},{T:CTGv4=,P:558,L:"T",E:"\bre * re + im * im > 2*"},{T:CTG2k=,P:579,L:"T",E:"\b * @"},{T:CTG3o=,P:582,L:"T",E:"\b2) break;"},{T:CTHPI=,P:157,L:"T",E:"\n    load "},{T:CTHQE=,P:166,L:"T",E:"\bpixe"},{T:CTHRU=,P:169,L:"T",E:"\b"},{T:CTHRY=,P:168,L:"T",E:"\b"},{T:CTHRg=,P:167,L:"T",E:"\b"},{T:CTHRo=,P:166,L:"T",E:"\bPixels();"},{T:CTHYY=,P:617,L:"T",E:"\n    		"},{T:CTHmU=,P:624,L:"T",E:"pixels[x + y * width"},{T:CTHsA=,P:644,L:"T",E:"] = color "},{T:CTHus=,P:653,L:"T",E:"\b("},{T:CTIIg=,P:654,L:"T",E:"255 - (float) iter / maxIter * 255);"},{T:CTITI=,P:700,L:"T",E:"\n	updatePixels()l"},{T:CTIXM=,P:716,L:"T",E:"\b;"},{T:CTJAA=,P:327,L:"T",E:"\b"},{T:CTJAE=,P:326,L:"T",E:"\bIm"},{T:CTJLg=,P:157,L:"T",E:"\n    if ( "},{T:CTJM4=,P:166,L:"T",E:"\bmousePressed && moute"},{T:CTJRA=,P:186,L:"T",E:"\b"},{T:CTJRE=,P:185,L:"T",E:"\be"},{T:CTJRc=,P:185,L:"T",E:"\bseButton == LEFT)"},{T:CTJYE=,P:105,L:"T",E:"\n\n"},{T:CTJd8=,P:106,L:"T",E:"boolean leftPressed = left"},{T:CTJiw=,P:131,L:"T",E:"\b"},{T:CTJi4=,P:130,L:"T",E:"\b"},{T:CTJi8=,P:129,L:"T",E:"\b"},{T:CTJjE=,P:128,L:"T",E:"\bfasle"},{T:CTJj8=,P:132,L:"T",E:"\b"},{T:CTJkE=,P:131,L:"T",E:"\b"},{T:CTJkM=,P:130,L:"T",E:"\bs"},{T:CTJkw=,P:130,L:"T",E:"\blse, rightPressed = false;"},{T:CTJsQ=,P:253,L:"T",E:" && !leftPressed"},{T:CTJyE=,P:270,L:"T",E:" {\n        "},{T:CTJy8=,P:273-281,L:"T",E:"    }"},{T:CTJ0M=,P:272,L:"T",E:"\n        "},{T:CTJ+w=,P:281,L:"T",E:"leftPressed = truel\n        "},{T:CTKCg=,P:308,L:"T",E:"\b"},{T:CTKCo=,P:307,L:"T",E:"\b"},{T:CTKCs=,P:306,L:"T",E:"\b"},{T:CTKC0=,P:305,L:"T",E:"\b"},{T:CTKC4=,P:304,L:"T",E:"\b"},{T:CTKDA=,P:303,L:"T",E:"\b"},{T:CTKDE=,P:302,L:"T",E:"\b"},{T:CTKDM=,P:301,L:"T",E:"\b"},{T:CTKDU=,P:300,L:"T",E:"\b"},{T:CTKDw=,P:299,L:"T",E:"\b;\n        "},{T:CTKFo=,P:309,L:"T",E:"zoomWindow(5.0);"},{T:CTKMA=,P:325,L:"T",E:"\n        zoom *= 5;"},{T:CTKQ4=,P:281-344,L:"C",E:"leftPressed = true;\n        zoomWindow(5.0);\n        zoom *= 5;"},{T:CTKRg=,P:350,L:"T",E:" else if (mousePressed && mouseButton == IRGHT"},{T:CTKZE=,P:395,L:"T",E:"\b"},{T:CTKZM=,P:394,L:"T",E:"\b"},{T:CTKZQ=,P:393,L:"T",E:"\b"},{T:CTKZY=,P:392,L:"T",E:"\b"},{T:CTKZc=,P:391,L:"T",E:"\bRIGHT && !rightPressed"},{T:CTKgc=,P:413,L:"T",E:") {\n        "},{T:CTKh0=,P:417-425,L:"T",E:"    }"},{T:CTKi8=,P:416,L:"T",E:"\n        "},{T:CTKkU=,P:425,L:"P",E:"leftPressed = true;\n        zoomWindow(5.0);\n        zoom *= 5;"},N:"Paste from install with UUID fragment 00000000-0000-0000-0000-000000000000 -1 bytes long;",{T:CTKmA=,P:425-436,L:"T",E:"rightPressed"},{T:CTKqQ=,P:484,L:"T",E:"\b/"},{T:CTKv0=,P:465,L:"T",E:"\b1"},{T:CTKw0=,P:468,L:"T",E:"/"},{T:CTKxI=,P:468,L:"T",E:"\b / 5"},{T:CTLL8=,P:195,L:"T",E:"\n\n"},{T:CTLNM=,P:196,L:"T",E:"void zooo"},{T:CTLPE=,P:204,L:"T",E:"\bmWindow()"},{T:CTLSU=,P:212,L:"T",E:"double z"},{T:CTLT0=,P:221,L:"T",E:" {\n    "},{T:CTLUo=,P:224-228,L:"T",E:"\\b[224-228]}"},{T:CTLV0=,P:223,L:"T",E:"\n    double cr = minRE"},{T:CTLak=,P:244,L:"T",E:"\be + ("},{T:CTLn0=,P:655-759,L:"C",E:"double cr = minRe + (maxRe - minRe) * x / width;\n    		double ci = minIm + (maxIm - minIm) * y / height;"},{T:CTLqM=,P:228-249,L:"P",E:"double cr = minRe + (maxRe - minRe) * x / width;\n    		double ci = minIm + (maxIm - minIm) * y / height;"},N:"paste from project on same machine;Paste from project with UUID fragment 6d702833-3fef-42fa-0000-000000000000 -1 bytes long;",{T:CTLrE=,P:282,L:"T",E:"\b"},{T:CTLrM=,P:281,L:"T",E:"\b"},{T:CTLrU=,P:280,L:"T",E:"\b	"},{T:CTLwM=,P:266,L:"T",E:"\bmouseX"},{T:CTLyo=,P:324,L:"T",E:"\bmouseY"},{T:CTL3s=,P:340,L:"T",E:"\n   \n   	"},{T:CTL6s=,P:348,L:"T",E:"\b"},{T:CTL6w=,P:347,L:"T",E:"\b"},{T:CTL64=,P:346,L:"T",E:"\b"},{T:CTL68=,P:345,L:"T",E:"\b"},{T:CTL7E=,P:344,L:"T",E:"\b"},{T:CTL7c=,P:343,L:"T",E:"\b"},{T:CTL7o=,P:342,L:"T",E:"\b"},{T:CTL7w=,P:341,L:"T",E:"\b"},{T:CTL78=,P:340,L:"T",E:"\b\n   	"},{T:CTL+s=,P:345,L:"T",E:"double tempMin"},{T:CTMCk=,P:359,L:"T",E:"r"},{T:CTMEs=,P:223,L:"T",E:"\n    // set new center point at mouse point"},{T:CTMMs=,P:383,L:"T",E:"\n   // zoom"},{T:CTMPM=,P:387,L:"T",E:"	"},{T:CTMQ0=,P:415,L:"T",E:" = cr - (maxr"},{T:CTMT8=,P:427,L:"T",E:"\bRe - minRe)"},{T:CTMb4=,P:438,L:"T",E:" /2 /z;"},{T:CTMfc=,P:440,L:"T",E:" "},{T:CTMgE=,P:444,L:"T",E:" "},{T:CTMiI=,P:447,L:"T",E:"\n   maxRe "},{T:CTMlc=,P:451,L:"T",E:"	"},{T:CTMm0=,P:458,L:"T",E:"= cr + (maxRe - minRe) /2 /"},{T:CTMt8=,P:484,L:"T",E:"\b"},{T:CTMuA=,P:483,L:"T",E:"\b"},{T:CTMuI=,P:482,L:"T",E:"\b 2."},{T:CTMu8=,P:484,L:"T",E:"\b /2 "},{T:CTMvw=,P:487,L:"T",E:"\b"},{T:CTMv4=,P:486,L:"T",E:"\b z;\n   min "},{T:CTMzM=,P:496,L:"T",E:"\b"},{T:CTMzQ=,P:495,L:"T",E:"\b"},{T:CTMzY=,P:494,L:"T",E:"\b"},{T:CTMzc=,P:493,L:"T",E:"\b min Re"},{T:CTM00=,P:499,L:"T",E:"\b"},{T:CTM08=,P:498,L:"T",E:"\b"},{T:CTM1A=,P:497,L:"T",E:"\bre"},{T:CTM1Q=,P:498,L:"T",E:"\b"},{T:CTM1Y=,P:497,L:"T",E:"\bRE "},{T:CTM14=,P:499,L:"T",E:"\b"},{T:CTM2A=,P:498,L:"T",E:"\be -"},{T:CTM2g=,P:500,L:"T",E:"\b= "},{T:CTM48=,P:502,L:"T",E:"tempMinr;"},{T:CTNB8=,P:400-511,L:"C",E:"double tempMinr = cr - (maxRe - minRe) / 2 / z;\n   	maxRe = cr + (maxRe - minRe) / 2 / z;\n    minRe = tempMinr;"},{T:CTNJs=,P:521,L:"P",E:"double tempMinr = cr - (maxRe - minRe) / 2 / z;\n   	maxRe = cr + (maxRe - minRe) / 2 / z;\n    minRe = tempMinr;"},N:"paste from project on same machine;Paste from project with UUID fragment 6d702833-3fef-42fa-ae00-000000000000 -1 bytes long;",{T:CTNHg=,P:511,L:"T",E:"\n    \n    "},{T:CTNOI=,P:535,L:"T",E:"\bi"},{T:CTNU4=,P:540,L:"T",E:"\bi"},{T:CTNXM=,P:549,L:"T",E:"\b"},{T:CTNXQ=,P:548,L:"T",E:"\bIm"},{T:CTNYo=,P:557,L:"T",E:"\b"},{T:CTNYw=,P:556,L:"T",E:"\bIm"},{T:CTNcI=,P:577,L:"T",E:"\b"},{T:CTNcQ=,P:576,L:"T",E:"\bIm"},{T:CTNfA=,P:582,L:"T",E:"\bi"},{T:CTNno=,P:591,L:"T",E:"\b"},{T:CTNns=,P:590,L:"T",E:"\bIm"},{T:CTNpk=,P:599,L:"T",E:"\b"},{T:CTNpo=,P:598,L:"T",E:"\bIm"},{T:CTNsA=,P:619,L:"T",E:"\b"},{T:CTNsI=,P:618,L:"T",E:"\bIm"},{T:CTNt8=,P:630,L:"T",E:"\bi"},{T:CTOJE=,P:196-634,L:"C",E:"void zoomWindow(double z) {\n    // set new center point at mouse point\n    double cr = minRe + (maxRe - minRe) * mouseX / width;\n   	double ci = minIm + (maxIm - minIm) * mouseY / height;\n   	// zoom\n   	double tempMinr = cr - (maxRe - minRe) / 2 / z;\n   	maxRe = cr + (maxRe - minRe) / 2 / z;\n    minRe = tempMinr;\n    \n    double tempMini = ci - (maxIm - minIm) / 2 / z;\n   	maxIm = ci + (maxIm - minIm) / 2 / z;\n    minIm = tempMini;\n}"},{T:CTOJM=,P:196-634,L:"T",E:"\\b[196-634]"},{T:CTOJY=,P:195,L:"T",E:"\b"},{T:CTOJo=,P:194,L:"T",E:"\b"},{T:CTOMI=,P:1062,L:"P",E:"void zoomWindow(double z) {\n    // set new center point at mouse point\n    double cr = minRe + (maxRe - minRe) * mouseX / width;\n   	double ci = minIm + (maxIm - minIm) * mouseY / height;\n   	// zoom\n   	double tempMinr = cr - (maxRe - minRe) / 2 / z;\n   	maxRe = cr + (maxRe - minRe) / 2 / z;\n    minRe = tempMinr;\n    \n    double tempMini = ci - (maxIm - minIm) / 2 / z;\n   	maxIm = ci + (maxIm - minIm) / 2 / z;\n    minIm = tempMini;\n}"},N:"internal paste;",{T:CTOL8=,P:1061,L:"T",E:"\n"},{T:CTONI=,P:1061,L:"T",E:"\n"},{T:CTOuw=,P:1501,L:"T",E:"\n\nvoid mouseReleased() {\n    "},{T:CTO04=,P:1526-1530,L:"T",E:"\\b[1526-1530]}"},{T:CTO2Q=,P:1525,L:"T",E:"\n    if (leftPreses"},{T:CTO6I=,P:1543,L:"T",E:"\b"},{T:CTO6Q=,P:1542,L:"T",E:"\bsed) leftPressed"},{T:CTO/g=,P:1558,L:"T",E:" = false;\n    if (rightPressed) rightPressed = false;"},{T:CTP8w=,P:1061,L:"T",E:"\n\n"},{T:CTQNw=,P:1063,L:"T",E:"void keyPressed() {\n    "},{T:CTQRc=,P:1083-1087,L:"T",E:"\\b[1083-1087]}"},{T:CTQS0=,P:1082,L:"T",E:"\n    double w = (maxRe ="},{T:CTQYE=,P:1105,L:"T",E:"\b0 "},{T:CTQYk=,P:1106,L:"T",E:"\b"},{T:CTQYo=,P:1105,L:"T",E:"\b- min "},{T:CTQaU=,P:1110,L:"T",E:"\bRe) * 0.3;\n    double h = (M"},{T:CTQh0=,P:1137,L:"T",E:"\bmaxIm 0"},{T:CTQjw=,P:1143,L:"T",E:"\b- minIm) * 0.3;\n    \n    if (keyCode == UP) {\n        "},{T:CTQvU=,P:1189-1197,L:"T",E:"    }"},{T:CTQyg=,P:1188,L:"T",E:"\n        maxIm -= h;\n        imn"},{T:CTQ4Y=,P:1219,L:"T",E:"\b"},{T:CTQ4c=,P:1218,L:"T",E:"\b"},{T:CTQ4k=,P:1217,L:"T",E:"\bmin I"},{T:CTQ5o=,P:1221,L:"T",E:"\b"},{T:CTQ5s=,P:1220,L:"T",E:"\bIm -= h;"},{T:CTRCI=,P:1234,L:"T",E:" else if ( ke"},{T:CTRFk=,P:1246,L:"T",E:"\b"},{T:CTRFs=,P:1245,L:"T",E:"\b"},{T:CTRFw=,P:1244,L:"T",E:"\bkeyCode == DOWN) {\n        "},{T:CTRME=,P:1263-1271,L:"T",E:"    }"},{T:CTRNA=,P:1262,L:"T",E:"\n        maxIm += "},{T:CTRRo=,P:1280,L:"T",E:"h;\n        min "},{T:CTRTs=,P:1294,L:"T",E:"\bIm += h;"},{T:CTRYE=,P:1308,L:"T",E:" else if ( "},{T:CTRZ4=,P:1318,L:"T",E:"\bkeyCode == "},{T:CTRdI=,P:1329,L:"T",E:"Lef"},{T:CTRdk=,P:1331,L:"T",E:"\b"},{T:CTRds=,P:1330,L:"T",E:"\bLE"},{T:CTReE=,P:1331,L:"T",E:"\b"},{T:CTReI=,P:1330,L:"T",E:"\bEFT) {\n        "},{T:CTRhk=,P:1337-1345,L:"T",E:"    }"},{T:CTRi4=,P:1336,L:"T",E:"\n        "},{T:CTRlM=,P:1345,L:"T",E:"maxRe += wl"},{T:CTRns=,P:1355,L:"T",E:"\b;\n        "},{T:CTRps=,P:1365,L:"T",E:"minRe += wl"},{T:CTRsc=,P:1375,L:"T",E:"\b;"},{T:CTRxM=,P:1351,L:"T",E:"\b-"},{T:CTRyM=,P:1371,L:"T",E:"\b-"},{T:CTR0c=,P:1382,L:"T",E:" else if (keyCode == RIGHT) {\n        "},{T:CTR7Y=,P:1412-1420,L:"T",E:"    }"},{T:CTR8Y=,P:1411,L:"T",E:"\n        maxRe += w;\n        minRe += w,"},{T:CTSC4=,P:1450,L:"T",E:"\b;"},{T:CTTPE=,P:1061,L:"T",E:"\n\n"},{T:CTTmI=,P:1063,L:"T",E:"void mouseWheel ("},{T:CTTpo=,P:1079,L:"T",E:"\b"},{T:CTTpw=,P:1078,L:"T",E:"\b(MouseEvent event) {\n    "},{T:CTTwo=,P:1099-1103,L:"T",E:"\\b[1099-1103]}"},{T:CTTx8=,P:1098,L:"T",E:"\n    if ("},{T:CTTzQ=,P:1106,L:"T",E:"\b(event.getCount() > 0"},{T:CTT5k=,P:1127,L:"T",E:") "},{T:CTT7E=,P:1129,L:"T",E:"maxIter / = 2;\n    "},{T:CTUCE=,P:1138,L:"T",E:"\b"},{T:CTUD8=,P:1103-1142,L:"C",E:"if (event.getCount() > 0) maxIter /= 2;"},{T:CTUEk=,P:1147,L:"P",E:"if (event.getCount() > 0) maxIter /= 2;"},N:"Paste from install with UUID fragment 00000000-0000-0000-0000-000000000000 -1 bytes long;",{T:CTUHE=,P:1168,L:"T",E:"\b<"},{T:CTUJo=,P:1181,L:"T",E:"\b*"},{T:CTUL4=,P:1186,L:"T",E:"\n    \n    maxIter = copns"},{T:CTUPo=,P:1210,L:"T",E:"\b"},{T:CTUPw=,P:1209,L:"T",E:"\b"},{T:CTUP0=,P:1208,L:"T",E:"\bnstrain(maxIter, 1 "},{T:CTUUU=,P:1226,L:"T",E:"\b, 2048);"},{T:CTVBo=,P:1059,L:"T",E:"\n\n"},{T:CTVCk=,P:1060,L:"T",E:"\b	"},{T:CTVP4=,P:1061,L:"T",E:"Strin "},{T:CTVQk=,P:1066,L:"T",E:"\bg iterMsg"},{T:CTVTk=,P:1075,L:"T",E:" = \"\""},{T:CTVVw=,P:1079,L:"T",E:"Max Iteration: "},{T:CTVZY=,P:1095,L:"T",E:" + maxIter;\n		"},{T:CTVdE=,P:1108,L:"T",E:"\bString zoomMsg = \"Zoom\""},{T:CTVjM=,P:1130,L:"T",E:"\b \" + o"},{T:CTVls=,P:1135,L:"T",E:"\bzoom;\n		"},{T:CTVok=,P:1142,L:"T",E:"\btes"},{T:CTVp8=,P:1144,L:"T",E:"\bxtSize(20);\n	fill(0, 0, 238_"},{T:CTVy8=,P:1171,L:"T",E:"\b)"},{T:CTV0Y=,P:1172,L:"T",E:"; // r,g"},{T:CTV2k=,P:1179,L:"T",E:"\b g, b"},{T:CTV5Y=,P:1184,L:"T",E:"\n	text(iterMsg, 40, "},{T:CTWA8=,P:1204,L:"T",E:"40, 280, 40);"},{T:CTWHY=,P:1186-1217,L:"C",E:"text(iterMsg, 40, 40, 280, 40);"},{T:CTWII=,P:1218,L:"P",E:"text(iterMsg, 40, 40, 280, 40);"},N:"Paste from install with UUID fragment 00000000-0000-0000-0000-000000000000 -1 bytes long;",{T:CTWIA=,P:1217,L:"T",E:"\n"},{T:CTWJc=,P:1218,L:"T",E:"	"},{T:CTWMw=,P:1227,L:"T",E:"\b"},{T:CTWM0=,P:1226,L:"T",E:"\b"},{T:CTWM4=,P:1225,L:"T",E:"\b"},{T:CTWNA=,P:1224,L:"T",E:"\bzoom"},{T:CTWiE=,P:1246,L:"T",E:"\b8"},{T:CTWmk=,P:1237,L:"T",E:"\b8"},{T:CTXHs=,P:492,L:"T",E:".0"},{T:CTXZ4=,P:81-84,L:"T",E:"\\b[81-84,{T:CU708=,P:0,L:"T",E:"\n\n\n"},{T:CU72U=,P:0,L:"T",E:"/**\n*/"},{T:CU75g=,P:3,L:"T",E:"\nSummary: \nThis assignment was solved"},{T:CU8J4=,P:39,L:"T",E:"\b"},{T:CU8KE=,P:38,L:"T",E:"\b"},{T:CU8KI=,P:37,L:"T",E:"\b"},{T:CU8KQ=,P:36,L:"T",E:"\b"},{T:CU8KU=,P:35,L:"T",E:"\b"},{T:CU8Kc=,P:34,L:"T",E:"\bcompleted "},{T:CU8Oc=,P:44,L:"T",E:"with the help of a youtube video "},{T:CU8Uc=,P:77,L:"T",E:"solving the assignmennt "},{T:CU8W8=,P:100,L:"T",E:"\b"},{T:CU8XA=,P:99,L:"T",E:"\b"},{T:CU8XI=,P:98,L:"T",E:"\bt and the requirements."}]}
