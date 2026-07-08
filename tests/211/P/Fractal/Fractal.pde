/**
 * I Googled "mandelbrot set in processing" and clicked on a link from the 
 * Processing website and copied the code.
 * 
 * The Mandelbrot Set
 * by Daniel Shiffman.  
 * (slight modification by l8l)
 *
 * Simple rendering of the Mandelbrot set.
 */

size(640, 360);
noLoop();
background(255);

// Establish a range of values on the complex plane
// A different range will allow us to "zoom" in or out on the fractal

// It all starts with the width, try higher or lower values
float w = 4;
float h = (w * height) / width;

// Start at negative half the width and height
float xmin = -w/2;
float ymin = -h/2;

// Make sure we can write to the pixels[] array.
// Only need to do this once since we don't do any other drawing.
loadPixels();

// Maximum number of iterations for each point on the complex plane
int maxiterations = 100;

// x goes from xmin to xmax
float xmax = xmin + w;
// y goes from ymin to ymax
float ymax = ymin + h;

// Calculate amount we increment x,y for each pixel
float dx = (xmax - xmin) / (width);
float dy = (ymax - ymin) / (height);

// Start y
float y = ymin;
for (int j = 0; j < height; j++) {
  // Start x
  float x = xmin;
  for (int i = 0; i < width; i++) {

    // Now we test, as we iterate z = z^2 + c does z tend towards infinity?
    float a = x;
    float b = y;
    int n = 0;
    float max = 4.0;  // Infinity in our finite world is simple, let's just consider it 4
    float absOld = 0.0;
    float convergeNumber = maxiterations; // this will change if the while loop breaks due to non-convergence
    while (n < maxiterations) {
      // We suppose z = a+ib
      float aa = a * a;
      float bb = b * b;
      float abs = sqrt(aa + bb);
      if (abs > max) { // |z| = sqrt(a^2+b^2)
        // Now measure how much we exceeded the maximum: 
        float diffToLast = (float) (abs - absOld);
        float diffToMax  = (float) (max - absOld);
        convergeNumber = n + diffToMax/diffToLast;
        break;  // Bail
      }
      float twoab = 2.0 * a * b;
      a = aa - bb + x; // this operation corresponds to z -> z^2+c where z=a+ib c=(x,y)
      b = twoab + y;
      n++;
      absOld = abs;
    }

    // We color each pixel based on how long it takes to get to infinity
    // If we never got there, let's pick the color black
    if (n == maxiterations) {
      pixels[i+j*width] = color(0);
    } else {
      // Gosh, we could make fancy colors here if we wanted
      float norm = map(convergeNumber, 0, maxiterations, 0, 1);
      pixels[i+j*width] = color(map(sqrt(norm), 0, 1, 0, 255));
    }
    x += dx;
  }
  y += dy;
}
updatePixels();
//|Do not modify this line|{InstallUUIDStack:["12d6237c-1784-4c5a-8e9e-f36b4ca1c355"],InfectionStack:["102f6984-adca-4646-b686-5c64f39bd843"],ProjectUUID:"102f6984-adca-4646-b686-5c64f39bd843",CreatorUUID:"12d6237c-1784-4c5a-8e9e-f36b4ca1c355",History:[{T:DhWME=,P:0,L:"P",E:"/**\n * The Mandelbrot Set\n * by Daniel Shiffman.  \n * (slight modification by l8l)\n *\n * Simple rendering of the Mandelbrot set.\n */\n\nsize(640, 360);\nnoLoop();\nbackground(255);\n\n// Establish a range of values on the complex plane\n// A different range will allow us to \"zoom\" in or out on the fractal\n\n// It all starts with the width, try higher or lower values\nfloat w = 4;\nfloat h = (w * height) / width;\n\n// Start at negative half the width and height\nfloat xmin = -w/2;\nfloat ymin = -h/2;\n\n// Make sure we can write to the pixels[] array.\n// Only need to do this once since we don't do any other drawing.\nloadPixels();\n\n// Maximum number of iterations for each point on the complex plane\nint maxiterations = 100;\n\n// x goes from xmin to xmax\nfloat xmax = xmin + w;\n// y goes from ymin to ymax\nfloat ymax = ymin + h;\n\n// Calculate amount we increment x,y for each pixel\nfloat dx = (xmax - xmin) / (width);\nfloat dy = (ymax - ymin) / (height);\n\n// Start y\nfloat y = ymin;\nfor (int j = 0; j < height; j++) {\n  // Start x\n  float x = xmin;\n  for (int i = 0; i < width; i++) {\n\n    // Now we test, as we iterate z = z^2 + c does z tend towards infinity?\n    float a = x;\n    float b = y;\n    int n = 0;\n    float max = 4.0;  // Infinity in our finite world is simple, let's just consider it 4\n    float absOld = 0.0;\n    float convergeNumber = maxiterations; // this will change if the while loop breaks due to non-convergence\n    while (n < maxiterations) {\n      // We suppose z = a+ib\n      float aa = a * a;\n      float bb = b * b;\n      float abs = sqrt(aa + bb);\n      if (abs > max) { // |z| = sqrt(a^2+b^2)\n        // Now measure how much we exceeded the maximum: \n        float diffToLast = (float) (abs - absOld);\n        float diffToMax  = (float) (max - absOld);\n        convergeNumber = n + diffToMax/diffToLast;\n        break;  // Bail\n      }\n      float twoab = 2.0 * a * b;\n      a = aa - bb + x; // this operation corresponds to z -> z^2+c where z=a+ib c=(x,y)\n      b = twoab + y;\n      n++;\n      absOld = abs;\n    }\n\n    // We color each pixel based on how long it takes to get to infinity\n    // If we never got there, let's pick the color black\n    if (n == maxiterations) {\n      pixels[i+j*width] = color(0);\n    } else {\n      // Gosh, we could make fancy colors here if we wanted\n      float norm = map(convergeNumber, 0, maxiterations, 0, 1);\n      pixels[i+j*width] = color(map(sqrt(norm), 0, 1, 0, 255));\n    }\n    x += dx;\n  }\n  y += dy;\n}\nupdatePixels();",N:"Paste from noncoded source"},{T:DhXDw=,P:4,L:"T",E:"\n"},{T:DhXFM=,P:4,L:"T",E:" * I complete "},{T:DhXI4=,P:17,L:"T",E:"\bd the assigne"},{T:DhXLE=,P:9-30,L:"T",E:"looked p"},{T:DhXLw=,P:16,L:"T",E:"\b"},{T:DhXL0=,P:15,L:"T",E:"\b"},{T:DhXL8=,P:14,L:"T",E:"\b"},{T:DhXMA=,P:13,L:"T",E:"\b"},{T:DhXME=,P:12,L:"T",E:"\b"},{T:DhXMM=,P:11,L:"T",E:"\b"},{T:DhXMQ=,P:10,L:"T",E:"\b"},{T:DhXMU=,P:9,L:"T",E:"\bGoogled "},{T:DhXcQ=,P:17,L:"T",E:"\"na="},{T:DhXdY=,P:20,L:"T",E:"\b"},{T:DhXdc=,P:19,L:"T",E:"\b"},{T:DhXdk=,P:18,L:"T",E:"\bmandelbrot set in processing\" and clicked on the "},{T:DhXjs=,P:66,L:"T",E:"\b"},{T:DhXjw=,P:65,L:"T",E:"\b"},{T:DhXj0=,P:64,L:"T",E:"\b"},{T:DhXj8=,P:63,L:"T",E:"\ba link form the "},{T:DhXlE=,P:78,L:"T",E:"\b"},{T:DhXlI=,P:77,L:"T",E:"\b"},{T:DhXlQ=,P:76,L:"T",E:"\b"},{T:DhXlY=,P:75,L:"T",E:"\b"},{T:DhXlc=,P:74,L:"T",E:"\b"},{T:DhXls=,P:73,L:"T",E:"\b"},{T:DhXl0=,P:72,L:"T",E:"\b"},{T:DhXmM=,P:71,L:"T",E:"\b"},{T:DhXpE=,P:71,L:"T",E:"rom the \n "},{T:DhXsE=,P:81,L:"T",E:"p"},{T:DhXsU=,P:81,L:"T",E:"\b* Proeces"},{T:DhXuw=,P:89,L:"T",E:"\b"},{T:DhXu0=,P:88,L:"T",E:"\b"},{T:DhXu8=,P:87,L:"T",E:"\b"},{T:DhXvA=,P:86,L:"T",E:"\bcessing "},{T:DhYCo=,P:94,L:"T",E:"website and copied te "},{T:DhYEo=,P:115,L:"T",E:"\b"},{T:DhYEs=,P:114,L:"T",E:"\bhe code.\n * "}]}
