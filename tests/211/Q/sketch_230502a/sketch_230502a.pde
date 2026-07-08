//Asked chatgpt the following
/*Create a fractal with the following: size(int width,int height) call this function once in setup to set the size of the window
background(int greyValue) or background(int red, int green, int blue) call this function as the thing in draw to erase the previous frame. If you don't call it, frames are persistent.
fill(int greyValue), stroke(int greyValue), fill(int red, int green, int blue) stroke(int red, int green, int blue) These set the fill or outline (stroke) of all shapes drawn after it to a specific color. Each also supports a 4th alpha number for transparent colors
line(int x1, int y1, int x2,int y2) draws a line from (x1,y1) to (x2,y2)
int width and int height; these are 2 built in constants you can use. They are set to the current width and height of the window
int mouseX, int mouseY not needed by this assignment, but this is the position of the mouse
loadPixels() loads the current screen values into the 1d pixels array, updatePixels() takes that array and sets each screen pixel to the value in the array.
println(String) shorthand for System.out.println(String)
note: (0,0) is the top left corner, and (width,height) is the bottom right corner.
*/ 
 int maxIterations = 100;
float minReal = -2;
float maxReal = 2;
float minImaginary = -2;
float maxImaginary = 2;

void setup() {
  size(800, 800);
}

void draw() {
  background(0);

  loadPixels();

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float cReal = map(x, 0, width, minReal, maxReal);
      float cImaginary = map(y, 0, height, minImaginary, maxImaginary);

      int iteration = 0;
      float zReal = 0;
      float zImaginary = 0;

      while (iteration < maxIterations && zReal * zReal + zImaginary * zImaginary < 4) {
        float nextZReal = zReal * zReal - zImaginary * zImaginary + cReal;
        float nextZImaginary = 2 * zReal * zImaginary + cImaginary;

        zReal = nextZReal;
        zImaginary = nextZImaginary;

        iteration++;
      }

      int pixelColor;
      if (iteration == maxIterations) {
        pixelColor = color(0);
      } else {
        float hue = map(iteration, 0, maxIterations, 0, 255);
        pixelColor = color(hue, 255, 255);
      }

      pixels[x + y * width] = pixelColor;
    }
  }

  updatePixels();

  println("Fractal rendered");
}
//|Do not modify this line|{InstallUUIDStack:["5031093f-c680-4eb4-82ce-9112bff5f987"],InfectionStack:["c8ba2743-51c9-4ae0-8566-067e76c19980","e09bbe03-934d-4129-9745-dbefa1a277b0","c8ba2743-51c9-4ae0-8566-067e76c19980","e09bbe03-934d-4129-9745-dbefa1a277b0"],ProjectUUID:"e09bbe03-934d-4129-9745-dbefa1a277b0",CreatorUUID:"5031093f-c680-4eb4-82ce-9112bff5f987",History:[{T:CFs0I=,P:0,L:"T",E:" "},{T:CFs34=,P:1,L:"T",E:"void setup(){\n     si\n     "},{T:CFs8Q=,P:23-28,L:"T",E:" }"},{T:CFs9I=,P:22,L:"T",E:"ze()"},{T:CFs/A=,P:25,L:"T",E:"580,580"},{T:CFtCU=,P:33,L:"T",E:";"},{T:CFtC4=,P:37,L:"T",E:"\n \n void draw(){\n     "},{T:CFtFw=,P:54-59,L:"T",E:" }"},{T:CFtGY=,P:55,L:"T",E:"\n     "},{T:CFtGY=,P:57-61,L:"T",E:"\\b[57-61]"},{T:CFtcM=,P:55,L:"T",E:"	background();"},{T:CFths=,P:68,L:"T",E:"0"},{T:CFtis=,P:68,L:"T",E:"\b"},{T:CFtj0=,P:67,L:"T",E:"255,255,255"},{T:CFuFc=,P:82,L:"T",E:"//"},{T:CFuF8=,P:56,L:"T",E:"//"},{T:CFuHI=,P:41,L:"T",E:"//"},{T:CFuH4=,P:36,L:"T",E:"//"},{T:CFuIY=,P:18,L:"T",E:"//"},{T:CFuJs=,P:1,L:"T",E:"//"},{T:CFuLQ=,P:99,L:"P",E:"int maxIterations = 100;\nfloat minReal = -2;\nfloat maxReal = 2;\nfloat minImaginary = -2;\nfloat maxImaginary = 2;\n\nvoid setup() {\n  size(800, 800);\n}\n\nvoid draw() {\n  background(0);\n\n  loadPixels();\n\n  for (int x = 0; x < width; x++) {\n    for (int y = 0; y < height; y++) {\n      float cReal = map(x, 0, width, minReal, maxReal);\n      float cImaginary = map(y, 0, height, minImaginary, maxImaginary);\n\n      int iteration = 0;\n      float zReal = 0;\n      float zImaginary = 0;\n\n      while (iteration < maxIterations && zReal * zReal + zImaginary * zImaginary < 4) {\n        float nextZReal = zReal * zReal - zImaginary * zImaginary + cReal;\n        float nextZImaginary = 2 * zReal * zImaginary + cImaginary;\n\n        zReal = nextZReal;\n        zImaginary = nextZImaginary;\n\n        iteration++;\n      }\n\n      int pixelColor;\n      if (iteration == maxIterations) {\n        pixelColor = color(0);\n      } else {\n        float hue = map(iteration, 0, maxIterations, 0, 255);\n        pixelColor = color(hue, 255, 255);\n      }\n\n      pixels[x + y * width] = pixelColor;\n    }\n  }\n\n  updatePixels();\n\n  println(\"Fractal rendered\");\n}"},N:"Paste from noncoded source",{T:CFuKw=,P:95,L:"T",E:"\n \n "},{T:CFvGI=,P:0-95,L:"T",E:"\\b[0-95,{T:CFwsY=,P:1198,L:"T",E:"."}]}
