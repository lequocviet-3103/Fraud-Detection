// I was having trouble with the processor
// I'm putting my code here incase the saved file did not save
// because everytime I went back to look at it, it opened up blank

/**
I completed the assignment by looking through chatgpt, and other popular code websites. 
This one is the only code that I found that worked, despite not fulfilling the complete
requirements of the assignment. I decided to use this since its the only one that could 
run on the IDE. 
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
//|Do not modify this line|{InstallUUIDStack:["ebe3a7d4-d019-40bc-93bf-d6eb7a90fdbf"],InfectionStack:["e215f064-83a3-4358-8d35-93a8b21b58bd"],ProjectUUID:"e215f064-83a3-4358-8d35-93a8b21b58bd",CreatorUUID:"ebe3a7d4-d019-40bc-93bf-d6eb7a90fdbf",History:[{T:CwTPk=,P:0,L:"P",E:"// I was having trouble with the processor\n// I'm putting my code here incase the saved file did not save\n// because everytime I went back to look at it, it opened up blank\n\n/**\nI completed the assignment by looking through chatgpt, and other popular code websites. \nThis one is the only code that I found that worked, despite not fulfilling the complete\nrequirements of the assignment. I decided to use this since its the only one that could \nrun on the IDE. \n*/\n\n\nsize(640, 360);\nnoLoop();\nbackground(255);\n\n// Establish a range of values on the complex plane\n// A different range will allow us to \"zoom\" in or out on the fractal\n\n// It all starts with the width, try higher or lower values\nfloat w = 4;\nfloat h = (w * height) / width;\n\n// Start at negative half the width and height\nfloat xmin = -w/2;\nfloat ymin = -h/2;\n\n// Make sure we can write to the pixels[] array.\n// Only need to do this once since we don't do any other drawing.\nloadPixels();\n\n// Maximum number of iterations for each point on the complex plane\nint maxiterations = 100;\n\n// x goes from xmin to xmax\nfloat xmax = xmin + w;\n// y goes from ymin to ymax\nfloat ymax = ymin + h;\n\n// Calculate amount we increment x,y for each pixel\nfloat dx = (xmax - xmin) / (width);\nfloat dy = (ymax - ymin) / (height);\n\n// Start y\nfloat y = ymin;\nfor (int j = 0; j < height; j++) {\n  // Start x\n  float x = xmin;\n  for (int i = 0; i < width; i++) {\n\n    // Now we test, as we iterate z = z^2 + c does z tend towards infinity?\n    float a = x;\n    float b = y;\n    int n = 0;\n    float max = 4.0;  // Infinity in our finite world is simple, let's just consider it 4\n    float absOld = 0.0;\n    float convergeNumber = maxiterations; // this will change if the while loop breaks due to non-convergence\n    while (n < maxiterations) {\n      // We suppose z = a+ib\n      float aa = a * a;\n      float bb = b * b;\n      float abs = sqrt(aa + bb);\n      if (abs > max) { // |z| = sqrt(a^2+b^2)\n        // Now measure how much we exceeded the maximum: \n        float diffToLast = (float) (abs - absOld);\n        float diffToMax  = (float) (max - absOld);\n        convergeNumber = n + diffToMax/diffToLast;\n        break;  // Bail\n      }\n      float twoab = 2.0 * a * b;\n      a = aa - bb + x; // this operation corresponds to z -> z^2+c where z=a+ib c=(x,y)\n      b = twoab + y;\n      n++;\n      absOld = abs;\n    }\n\n    // We color each pixel based on how long it takes to get to infinity\n    // If we never got there, let's pick the color black\n    if (n == maxiterations) {\n      pixels[i+j*width] = color(0);\n    } else {\n      // Gosh, we could make fancy colors here if we wanted\n      float norm = map(convergeNumber, 0, maxiterations, 0, 1);\n      pixels[i+j*width] = color(map(sqrt(norm), 0, 1, 0, 255));\n    }\n    x += dx;\n  }\n  y += dy;\n}\nupdatePixels();"},N:"Paste from noncoded source"]}
