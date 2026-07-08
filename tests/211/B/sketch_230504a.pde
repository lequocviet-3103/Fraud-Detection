/**
 *  Mandelbrot set with hardcoded (start) zoom value using naive successive refinements.
 *
 *  Possible optimizations:
 *   . the topright corner of every block is already done and
 *     does not need to be recalculated.
 *
 *  Left click: the zoom is multiplied by zoomMult and the fractal is redrawn.
 *  Right click: reset the zoom.
 */

int pixSize = 500;
float rmin=-2, imin=-1.3, side=2.6;
float rmax=rmin+side, imax=imin+side;

float init_rmin = rmin;
float init_imin = imin;
float init_side = side;

int maxIter = 1500;
int logmax = (int)Math.ceil(log(maxIter));

float zoom, lastzoom=0, init_zoom;
float zoomMult = 3;

int[] blocksizes = { 16, 8, 4, 2, 1 };
int b=0, bsize = blocksizes[b];
boolean done = false;

void settings() {

  size( pixSize, pixSize );
}

void setup() {

  colorMode( HSB, logmax, 180, 1000 );

  zoom = width/(rmax-rmin);
  init_zoom = zoom;
  if (height/(imax-imin)>zoom) {
    zoom = height/(imax-imin);
  }
  noStroke();
}

void draw() {

  loadPixels();

  if ( lastzoom == zoom && done ) return;
  println(lastzoom+","+zoom+","+bsize);

  background(0, 0, -1);
  int start = millis();

  float zr, zi, cr, ci, zrtmp;

  int it;

  for ( int j=0; j<height; j+=bsize ) {

    for ( int i=0; i<width; i+=bsize ) {

      ci = zi = imin+j/zoom;
      cr = zr = rmin+i/zoom;
      if (zr*zr+zi*zi>4f) continue;

      for ( it=0; it<maxIter; it++ ) {
        zrtmp = zr*zr-zi*zi + cr;
        zi = 2*zr*zi + ci;
        zr = zrtmp;

        if (zr*zr+zi*zi>4f) break;
      }

      color col;
      if (it==maxIter) col = color(0, 0, -1);
      else {

        float rad = sqrt(zr*zr+zi*zi);
        float alfa = acos(zr/rad)*180f/PI;

        int angle = (int)(Math.round(alfa));
        int rad1000 = (int)(1000f*rad)-2000;
        int logit = Math.round(log(it));

        col = color( logit, angle, rad1000 );
      }

      if (bsize == 1) {
        pixels[j*width+i] = col;
      } else {
        fill(col);
        rect(i, j, i+bsize, j+bsize);
      }
    }
  }

  if ( b>=blocksizes.length) {
    updatePixels();
    b=0;
    done = true;
  } else bsize = blocksizes[b++];

  //saveFrame( "BuddhaImg_iter-###.tif" );

  int end = millis();
  println( (end-start)+ " msec (" + 
    (pixSize*pixSize*1000/(end-start)) + " pixels/sec)" );

  lastzoom = zoom;
}

void mousePressed() {

  if ( mouseButton == LEFT ) {
    float pressR, pressI;
    pressR = rmin + mouseX/zoom;
    pressI = imin + mouseY/zoom;
    println( "Zoom requested at ("+pressR+" + " + pressI + "i )" );

    zoom*= zoomMult;
    float rspread = width/zoom;
    float ispread = height/zoom;

    rmin = pressR-rspread/2;
    rmax = rmin + rspread;

    imin = pressI-ispread/2;
    imax = imin + ispread;
    b = 0;
    bsize = blocksizes[0];
    done = false;
  } else {

    // Reset
    zoom = init_zoom;
    rmin = init_rmin;
    imin = init_imin;

    b = 0;
    bsize = blocksizes[0];
    done = false;
  }
}
//|Do not modify this line|{InstallUUIDStack:["cb7b6816-b233-4392-b953-0fd882b54501"],InfectionStack:["80ff444a-1654-4be2-a83d-885ae03c263d","58b8dbb5-1c08-4c9f-b404-04615ea120f8"],ProjectUUID:"58b8dbb5-1c08-4c9f-b404-04615ea120f8",CreatorUUID:"cb7b6816-b233-4392-b953-0fd882b54501",History:[{T:Cive4=,P:0,L:"P",E:"void setup(){\n			//setup code here   \n		}\n\n		void draw(){\n		 	//draw code here   \n		}"},N:"Paste from noncoded source",{T:Civl0=,P:0,L:"T",E:"voud"},{T:Civmc=,P:3,L:"T",E:"\b"},{T:Civmg=,P:2,L:"T",E:"\bid setup()\n{\n    "},{T:Civq8=,P:19,L:"T",E:"\n    "},{T:CivrM=,P:23,L:"T",E:"\b"},{T:CivrU=,P:22,L:"T",E:"\b"},{T:Civrc=,P:21,L:"T",E:"\b"},{T:Civrw=,P:20,L:"T",E:"\b\\b[20-20]}\n\nvoid draw()"},{T:CivwQ=,P:34,L:"T",E:"\n{\n    \n    "},{T:Civxo=,P:42-46,L:"T",E:"\\b[42-46]}"},{T:CixE4=,P:19,L:"T",E:"sie"},{T:CixFQ=,P:21,L:"T",E:"\bze(500,500);"},{T:CixVA=,P:55,L:"T",E:"a"},{T:CixVQ=,P:55,L:"T",E:"\bbackground(255,0,0"},{T:CixYs=,P:72,L:"T",E:"\b255);"},{T:Cixgo=,P:70,L:"T",E:"\b255"},{T:CixuM=,P:68,L:"T",E:"\b"},{T:CixuU=,P:67,L:"T",E:"\b"},{T:Cixuc=,P:66,L:"T",E:"\b178"},{T:CixxY=,P:72,L:"T",E:"\b5"},{T:Cixyw=,P:68,L:"T",E:"\b"},{T:Cixy0=,P:67,L:"T",E:"\b"},{T:Cixy8=,P:66,L:"T",E:"\b255"},{T:Cix0g=,P:79,L:"T",E:"\n    "},{T:Cix08=,P:83,L:"T",E:"\b"},{T:Cix1I=,P:82,L:"T",E:"\b"},{T:Cix1Q=,P:81,L:"T",E:"\b"},{T:Cix1o=,P:80,L:"T",E:"\b"},{T:Ci41U=,P:19,L:"P",E:" size(800, 800);\n  background(0);\n  noStroke();\n  colorMode(HSB, 1);"},N:"Paste from noncoded source",{T:Ci5HA=,P:114,L:"P",E:"void keyPressed() {\n  if (key == ' ') {\n    redraw();\n  }\n}"},N:"Paste from noncoded source",{T:Ci5Gw=,P:112,L:"T",E:"\n\n"},{T:Ci5Lk=,P:91-112,L:"P",E:"void draw() {\n  float zoom = 1.5;\n  int maxIterations = 100;\n  loadPixels();\n  for (int x = 0; x < width; x++) {\n    for (int y = 0; y < height; y++) {\n      float a = map(x, 0, width, -zoom, zoom);\n      float b = map(y, 0, height, -zoom, zoom);\n      float ca = a;\n      float cb = b;\n      int n = 0;\n      while (n < maxIterations) {\n        float aa = a * a - b * b;\n        float bb = 2 * a * b;\n        a = aa + ca;\n        b = bb + cb;\n        if (abs(a + b) > 16) {\n          break;\n        }\n        n++;\n      }\n      if (n == maxIterations) {\n        pixels[x + y * width] = color(0);\n      } else {\n        float hu = map(n, 0, maxIterations, 0, 1);\n        hu = sqrt(hu);\n        pixels[x + y * width] = color(hu, 1, 1);\n      }\n    }\n  }\n  updatePixels();\n}"},N:"Paste from noncoded source",{T:Ci6DU=,P:0-924,L:"P",E:"float minVal = -2.5;\nfloat maxVal = 2.5;\nfloat range = maxVal - minVal;\n\nvoid setup() {\n  size(800, 800);\n  colorMode(HSB, 1);\n  noStroke();\n}\n\nvoid draw() {\n  loadPixels();\n\n  for (int x = 0; x < width; x++) {\n    for (int y = 0; y < height; y++) {\n      float a = map(x, 0, width, minVal, maxVal);\n      float b = map(y, 0, height, minVal, maxVal);\n      float ca = a;\n      float cb = b;\n      int n = 0;\n\n      while (n < 100) {\n        float aa = a * a - b * b;\n        float bb = 2 * a * b;\n        a = aa + ca;\n        b = bb + cb;\n        if (a * a + b * b > 16) {\n          break;\n        }\n        n++;\n      }\n\n      if (n == 100) {\n        pixels[x + y * width] = color(0, 0, 0);\n      } else {\n        float hue = map(n, 0, 100, 0, 1);\n        pixels[x + y * width] = color(hue, 1, 1);\n      }\n    }\n  }\n\n  updatePixels();\n}"},N:"Paste from noncoded source",{T:Ci6R4=,P:140,L:"T",E:"\n  draw)_"},{T:Ci6TA=,P:148,L:"T",E:"\b"},{T:Ci6TI=,P:147,L:"T",E:"\b();"},{T:Ci6ms=,P:143-150,L:"T",E:"\\b[143-150]"},{T:Ci7w0=,P:0-840,L:"P",E:"/**\n * The Mandelbrot Set\n * by Daniel Shiffman.  \n * (slight modification by l8l)\n *\n * Simple rendering of the Mandelbrot set.\n */\n\nsize(640, 360);\nnoLoop();\nbackground(255);\n\n// Establish a range of values on the complex plane\n// A different range will allow us to \"zoom\" in or out on the fractal\n\n// It all starts with the width, try higher or lower values\nfloat w = 4;\nfloat h = (w * height) / width;\n\n// Start at negative half the width and height\nfloat xmin = -w/2;\nfloat ymin = -h/2;\n\n// Make sure we can write to the pixels[,{T:Ci+gc=,P:0-2484,L:"P",E:"/**\n *  Mandelbrot set with hardcoded (start) zoom value using naive successive refinements.\n *\n *  Possible optimizations:\n *   . the topright corner of every block is already done and\n *     does not need to be recalculated.\n *\n *  Left click: the zoom is multiplied by zoomMult and the fractal is redrawn.\n *  Right click: reset the zoom.\n */\n\nint pixSize = 500;\nfloat rmin=-2, imin=-1.3, side=2.6;\nfloat rmax=rmin+side, imax=imin+side;\n\nfloat init_rmin = rmin;\nfloat init_imin = imin;\nfloat init_side = side;\n\nint maxIter = 1500;\nint logmax = (int)Math.ceil(log(maxIter));\n\nfloat zoom, lastzoom=0, init_zoom;\nfloat zoomMult = 3;\n\nint[] blocksizes = { 16, 8, 4, 2, 1 };\nint b=0, bsize = blocksizes[b];\nboolean done = false;\n\nvoid settings() {\n\n  size( pixSize, pixSize );\n}\n\nvoid setup() {\n\n  colorMode( HSB, logmax, 255, 255 );\n\n  zoom = width/(rmax-rmin);\n  init_zoom = zoom;\n  if (height/(imax-imin)>zoom) {\n    zoom = height/(imax-imin);\n  }\n  noStroke();\n}\n\nint mandel(int x, int y) {\n  float zr, zi, cr, ci, zrtmp;\n  int it;\n\n  ci = zi = imin+y/zoom;\n  cr = zr = rmin+x/zoom;\n\n  for ( it=0; it<maxIter && (zr*zr+zi*zi<4f); it++ ) {\n    zrtmp = zr*zr-zi*zi + cr;\n    zi = 2*zr*zi + ci;\n    zr = zrtmp;\n  }\n  \n  return it;\n}\n\nvoid draw() {\n\n  loadPixels();\n\n  if ( lastzoom == zoom && done ) return;\n  println(lastzoom+\",\"+zoom+\",\"+bsize);\n\n  background(0);\n  int start = millis();\n\n  for ( int j=0; j<height; j+=bsize ) {\n\n    for ( int i=0; i<width; i+=bsize ) {\n\n      int it = mandel(i,j);\n      color col = (it==maxIter)? color(0): color( log(it), 255, 255 );\n\n      if (bsize == 1) {\n        pixels[j*width+i] = col;\n      } else {\n        fill(col);\n        rect(i, j, i+bsize, j+bsize);\n      }\n    }\n  }\n\n  if ( b>=blocksizes.length) {\n    updatePixels();\n    b=0;\n    done = true;\n  } else bsize = blocksizes[b++];\n\n  int end = millis();\n  println( (end-start)+ \" msec (\" + \n    (pixSize*pixSize*1000/(end-start)) + \" pixels/sec)\" );\n\n  lastzoom = zoom;\n}\n\nvoid mousePressed() {\n\n  if ( mouseButton == LEFT ) {\n    float pressR, pressI;\n    pressR = rmin + mouseX/zoom;\n    pressI = imin + mouseY/zoom;\n    println( \"Zoom requested at (\"+pressR+\" + \" + pressI + \"i )\" );\n\n    zoom*= zoomMult;\n    float rspread = width/zoom;\n    float ispread = height/zoom;\n\n    rmin = pressR-rspread/2;\n    rmax = rmin + rspread;\n\n    imin = pressI-ispread/2;\n    imax = imin + ispread;\n    b = 0;\n    bsize = blocksizes[0];\n    done = false;\n  } else {\n\n    // Reset\n    zoom = init_zoom;\n    rmin = init_rmin;\n    imin = init_imin;\n\n    b = 0;\n    bsize = blocksizes[0];\n    done = false;\n  }\n}"},N:"Paste from noncoded source",{T:Ci/BY=,P:0-2598,L:"P",E:"/**\n *  Mandelbrot set with hardcoded (start) zoom value using naive successive refinements.\n *\n *  Possible optimizations:\n *   . the topright corner of every block is already done and\n *     does not need to be recalculated.\n *\n *  Left click: the zoom is multiplied by zoomMult and the fractal is redrawn.\n *  Right click: reset the zoom.\n */\n\nint pixSize = 500;\nfloat rmin=-2, imin=-1.3, side=2.6;\nfloat rmax=rmin+side, imax=imin+side;\n\nfloat init_rmin = rmin;\nfloat init_imin = imin;\nfloat init_side = side;\n\nint maxIter = 1500;\nint logmax = (int)Math.ceil(log(maxIter));\n\nfloat zoom, lastzoom=0, init_zoom;\nfloat zoomMult = 3;\n\nint[] blocksizes = { 16, 8, 4, 2, 1 };\nint b=0, bsize = blocksizes[b];\nboolean done = false;\n\nvoid settings() {\n\n  size( pixSize, pixSize );\n}\n\nvoid setup() {\n\n  colorMode( HSB, logmax, 255, 255 );\n\n  zoom = width/(rmax-rmin);\n  init_zoom = zoom;\n  if (height/(imax-imin)>zoom) {\n    zoom = height/(imax-imin);\n  }\n  noStroke();\n}\n\nint mandel(int x, int y) {\n  float zr, zi, cr, ci, zrtmp;\n  int it;\n\n  ci = zi = imin+y/zoom;\n  cr = zr = rmin+x/zoom;\n\n  for ( it=0; it<maxIter && (zr*zr+zi*zi<4f); it++ ) {\n    zrtmp = zr*zr-zi*zi + cr;\n    zi = 2*zr*zi + ci;\n    zr = zrtmp;\n  }\n  \n  return it;\n}\n\nvoid draw() {\n\n  loadPixels();\n\n  if ( lastzoom == zoom && done ) return;\n  println(lastzoom+\",\"+zoom+\",\"+bsize);\n\n  background(0);\n  int start = millis();\n\n  for ( int j=0; j<height; j+=bsize ) {\n\n    for ( int i=0; i<width; i+=bsize ) {\n\n      int it = mandel(i,j);\n      color col = (it==maxIter)? color(0): color( log(it), 255, 255 );\n\n      if (bsize == 1) {\n        pixels[j*width+i] = col;\n      } else {\n        fill(col);\n        rect(i, j, i+bsize, j+bsize);\n      }\n    }\n  }\n\n  if ( b>=blocksizes.length) {\n    updatePixels();\n    b=0;\n    done = true;\n  } else bsize = blocksizes[b++];\n\n  int end = millis();\n  println( (end-start)+ \" msec (\" + \n    (pixSize*pixSize*1000/(end-start)) + \" pixels/sec)\" );\n\n  lastzoom = zoom;\n}\n\nvoid mousePressed() {\n\n  if ( mouseButton == LEFT ) {\n    float pressR, pressI;\n    pressR = rmin + mouseX/zoom;\n    pressI = imin + mouseY/zoom;\n    println( \"Zoom requested at (\"+pressR+\" + \" + pressI + \"i )\" );\n\n    zoom*= zoomMult;\n    float rspread = width/zoom;\n    float ispread = height/zoom;\n\n    rmin = pressR-rspread/2;\n    rmax = rmin + rspread;\n\n    imin = pressI-ispread/2;\n    imax = imin + ispread;\n    b = 0;\n    bsize = blocksizes[0];\n    done = false;\n  } else {\n\n    // Reset\n    zoom = init_zoom;\n    rmin = init_rmin;\n    imin = init_imin;\n\n    b = 0;\n    bsize = blocksizes[0];\n    done = false;\n  }\n}"},N:"Paste from noncoded source",{T:Ci/SU=,P:0-2598,L:"P",E:"/**\n *  Mandelbrot set with hardcoded (start) zoom value using naive successive refinements.\n *\n *  Possible optimizations:\n *   . the topright corner of every block is already done and\n *     does not need to be recalculated.\n *\n *  Left click: the zoom is multiplied by zoomMult and the fractal is redrawn.\n *  Right click: reset the zoom.\n */\n\nint pixSize = 500;\nfloat rmin=-2, imin=-1.3, side=2.6;\nfloat rmax=rmin+side, imax=imin+side;\n\nfloat init_rmin = rmin;\nfloat init_imin = imin;\nfloat init_side = side;\n\nint maxIter = 1500;\nint logmax = (int)Math.ceil(log(maxIter));\n\nfloat zoom, lastzoom=0, init_zoom;\nfloat zoomMult = 3;\n\nint[] blocksizes = { 16, 8, 4, 2, 1 };\nint b=0, bsize = blocksizes[b];\nboolean done = false;\n\nvoid settings() {\n\n  size( pixSize, pixSize );\n}\n\nvoid setup() {\n\n  colorMode( HSB, logmax, 180, 1000 );\n\n  zoom = width/(rmax-rmin);\n  init_zoom = zoom;\n  if (height/(imax-imin)>zoom) {\n    zoom = height/(imax-imin);\n  }\n  noStroke();\n}\n\nvoid draw() {\n\n  loadPixels();\n\n  if ( lastzoom == zoom && done ) return;\n  println(lastzoom+\",\"+zoom+\",\"+bsize);\n\n  background(0, 0, -1);\n  int start = millis();\n\n  float zr, zi, cr, ci, zrtmp;\n\n  int it;\n\n  for ( int j=0; j<height; j+=bsize ) {\n\n    for ( int i=0; i<width; i+=bsize ) {\n\n      ci = zi = imin+j/zoom;\n      cr = zr = rmin+i/zoom;\n      if (zr*zr+zi*zi>4f) continue;\n\n      for ( it=0; it<maxIter; it++ ) {\n        zrtmp = zr*zr-zi*zi + cr;\n        zi = 2*zr*zi + ci;\n        zr = zrtmp;\n\n        if (zr*zr+zi*zi>4f) break;\n      }\n\n      color col;\n      if (it==maxIter) col = color(0, 0, -1);\n      else {\n\n        float rad = sqrt(zr*zr+zi*zi);\n        float alfa = acos(zr/rad)*180f/PI;\n\n        int angle = (int)(Math.round(alfa));\n        int rad1000 = (int)(1000f*rad)-2000;\n        int logit = Math.round(log(it));\n\n        col = color( logit, angle, rad1000 );\n      }\n\n      if (bsize == 1) {\n        pixels[j*width+i] = col;\n      } else {\n        fill(col);\n        rect(i, j, i+bsize, j+bsize);\n      }\n    }\n  }\n\n  if ( b>=blocksizes.length) {\n    updatePixels();\n    b=0;\n    done = true;\n  } else bsize = blocksizes[b++];\n\n  //saveFrame( \"BuddhaImg_iter-###.tif\" );\n\n  int end = millis();\n  println( (end-start)+ \" msec (\" + \n    (pixSize*pixSize*1000/(end-start)) + \" pixels/sec)\" );\n\n  lastzoom = zoom;\n}\n\nvoid mousePressed() {\n\n  if ( mouseButton == LEFT ) {\n    float pressR, pressI;\n    pressR = rmin + mouseX/zoom;\n    pressI = imin + mouseY/zoom;\n    println( \"Zoom requested at (\"+pressR+\" + \" + pressI + \"i )\" );\n\n    zoom*= zoomMult;\n    float rspread = width/zoom;\n    float ispread = height/zoom;\n\n    rmin = pressR-rspread/2;\n    rmax = rmin + rspread;\n\n    imin = pressI-ispread/2;\n    imax = imin + ispread;\n    b = 0;\n    bsize = blocksizes[0];\n    done = false;\n  } else {\n\n    // Reset\n    zoom = init_zoom;\n    rmin = init_rmin;\n    imin = init_imin;\n\n    b = 0;\n    bsize = blocksizes[0];\n    done = false;\n  }\n}"},N:"Paste from noncoded source"]}
