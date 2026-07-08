void setup() {
  size(800, 800);
  colorMode(HSB, 255);  // Use HSB color mode for more interesting colors
  noStroke();           // Turn off stroke for faster rendering
}

void draw() {
  loadPixels();
  
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      // Convert pixel coordinates to complex number c
      float a = map(x, 0, width, -2.5, 1);
      float b = map(y, 0, height, -1, 1);
      float ca = a;
      float cb = b;
      
      int n = 0;
      
      // Iterate the function z^2 + c until it diverges or the maximum number of iterations is reached
      while (n < 100) {
        float aa = a * a - b * b;
        float bb = 2 * a * b;
        a = aa + ca;
        b = bb + cb;
        
        if (a * a + b * b > 4) {
          break;
        }
        
        n++;
      }
      
      // Set pixel color based on the number of iterations
      if (n == 100) {
        pixels[x + y * width] = color(0);  // Black if it does not diverge
      } else {
        pixels[x + y * width] = color(n % 255, 255, 255);  // Color based on iterations
      }
    }
  }
  
  updatePixels();
}

//|Do not modify this line|{InstallUUIDStack:["62a95f8d-c246-4733-a9b8-31919fd0c2f7"],InfectionStack:["36e20e2e-71b3-4c96-bab5-2c7d5c96085a"],ProjectUUID:"36e20e2e-71b3-4c96-bab5-2c7d5c96085a",CreatorUUID:"62a95f8d-c246-4733-a9b8-31919fd0c2f7",History:[{T:CtDHg=,P:0,L:"P",E:"void setup() {\n  size(800, 800);\n  colorMode(HSB, 255);  // Use HSB color mode for more interesting colors\n  noStroke();           // Turn off stroke for faster rendering\n}\n\nvoid draw() {\n  loadPixels();\n  \n  for (int x = 0; x < width; x++) {\n    for (int y = 0; y < height; y++) {\n      // Convert pixel coordinates to complex number c\n      float a = map(x, 0, width, -2.5, 1);\n      float b = map(y, 0, height, -1, 1);\n      float ca = a;\n      float cb = b;\n      \n      int n = 0;\n      \n      // Iterate the function z^2 + c until it diverges or the maximum number of iterations is reached\n      while (n < 100) {\n        float aa = a * a - b * b;\n        float bb = 2 * a * b;\n        a = aa + ca;\n        b = bb + cb;\n        \n        if (a * a + b * b > 4) {\n          break;\n        }\n        \n        n++;\n      }\n      \n      // Set pixel color based on the number of iterations\n      if (n == 100) {\n        pixels[x + y * width] = color(0);  // Black if it does not diverge\n      } else {\n        pixels[x + y * width] = color(n % 255, 255, 255);  // Color based on iterations\n      }\n    }\n  }\n  \n  updatePixels();\n}\n"},N:"Paste from noncoded source"]}
