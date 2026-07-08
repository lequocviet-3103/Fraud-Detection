
//list of shapes with associated variables for speed and size

float shape1X, shape1Y, shape1SpeedX, shape1SpeedY, shape1Size;
float shape2X, shape2Y, shape2SpeedX, shape2SpeedY, shape2Size;
float shape3X, shape3Y, shape3SpeedX, shape3SpeedY, shape3Size;
  
  // Define the boundaries of the screen
  float minX, minY, maxX, maxY;
  
  public void settings() {
    size(800, 600);
  }
  
  public void setup() {
    
    // Initialize the shapes
    shape1X = random(width);
    shape1Y = random(height);
    shape1SpeedX = random(2, 5);
    shape1SpeedY = random(2, 5);
    shape1Size = random(20, 50);
    
    shape2X = random(width);
    shape2Y = random(height);
    shape2SpeedX = random(2, 5);
    shape2SpeedY = random(2, 5);
    shape2Size = random(20, 50);
    
    shape3X = random(width);
    shape3Y = random(height);
    shape3SpeedX = random(2, 5);
    shape3SpeedY = random(2, 5);
    shape3Size = random(20, 50);
    
    // Set the boundaries of the screen
    minX = 0;
    minY = 0;
    maxX = width;
    maxY = height;
  }
  
  public void draw() {
    
    // Clear the screen
    background(255);
    
    // Move and draw the first shape
    shape1X += shape1SpeedX;
    shape1Y += shape1SpeedY;
    fill(255, 0, 0);
    ellipse(shape1X, shape1Y, shape1Size, shape1Size);
    
    // Move and draw the second shape
    shape2X += shape2SpeedX;
    shape2Y += shape2SpeedY;
    fill(0, 255, 0);
    rect(shape2X, shape2Y, shape2Size, shape2Size);
    
    // Move and draw the third shape
    shape3X += shape3SpeedX;
    shape3Y += shape3SpeedY;
    fill(0, 0, 255);
    triangle(shape3X, shape3Y, shape3X - shape3Size/2, shape3Y + shape3Size, shape3X + shape3Size/2, shape3Y + shape3Size);
    
    // Check for collisions with the screen boundaries and bounce the shapes off them
    if (shape1X < minX || shape1X > maxX) {
      shape1SpeedX *= -1;
    }
    if (shape1Y < minY || shape1Y > maxY) {
      shape1SpeedY *= -1;
    }
    
    if (shape2X < minX || shape2X > maxX - shape2Size) {
      shape2SpeedX *= -1;
    }
    if (shape2Y < minY || shape2Y > maxY - shape2Size) {
      shape2SpeedY *= -1;
    }
     if (shape3X < minX || shape3X > maxX - shape3Size) {
      shape3SpeedX *= -1;
    }
    if (shape3Y < minY || shape3Y > maxY - shape3Size) {
      shape3SpeedY *= -1;
    }}
//|Do not modify this line|{InstallUUIDStack:["489eb1e1-407c-4bdb-8818-94f0279a43d7"],InfectionStack:["b8829857-d590-474b-a4d0-3ea33e2dc297"],ProjectUUID:"b8829857-d590-474b-a4d0-3ea33e2dc297",CreatorUUID:"489eb1e1-407c-4bdb-8818-94f0279a43d7",History:[{T:BC2FA=,P:0,L:"P",E:"float shape1X, shape1Y, shape1SpeedX, shape1SpeedY, shape1Size;\n  float shape2X, shape2Y, shape2SpeedX, shape2SpeedY, shape2Size;\n  float shape3X, shape3Y, shape3SpeedX, shape3SpeedY, shape3Size;\n  \n  // Define the boundaries of the screen\n  float minX, minY, maxX, maxY;\n  \n  public void settings() {\n    size(800, 600);\n  }\n  \n  public void setup() {\n    \n    // Initialize the shapes\n    shape1X = random(width);\n    shape1Y = random(height);\n    shape1SpeedX = random(2, 5);\n    shape1SpeedY = random(2, 5);\n    shape1Size = random(20, 50);\n    \n    shape2X = random(width);\n    shape2Y = random(height);\n    shape2SpeedX = random(2, 5);\n    shape2SpeedY = random(2, 5);\n    shape2Size = random(20, 50);\n    \n    shape3X = random(width);\n    shape3Y = random(height);\n    shape3SpeedX = random(2, 5);\n    shape3SpeedY = random(2, 5);\n    shape3Size = random(20, 50);\n    \n    // Set the boundaries of the screen\n    minX = 0;\n    minY = 0;\n    maxX = width;\n    maxY = height;\n  }\n  \n  public void draw() {\n    \n    // Clear the screen\n    background(255);\n    \n    // Move and draw the first shape\n    shape1X += shape1SpeedX;\n    shape1Y += shape1SpeedY;\n    fill(255, 0, 0);\n    ellipse(shape1X, shape1Y, shape1Size, shape1Size);\n    \n    // Move and draw the second shape\n    shape2X += shape2SpeedX;\n    shape2Y += shape2SpeedY;\n    fill(0, 255, 0);\n    rect(shape2X, shape2Y, shape2Size, shape2Size);\n    \n    // Move and draw the third shape\n    shape3X += shape3SpeedX;\n    shape3Y += shape3SpeedY;\n    fill(0, 0, 255);\n    triangle(shape3X, shape3Y, shape3X - shape3Size/2, shape3Y + shape3Size, shape3X + shape3Size/2, shape3Y + shape3Size);\n    \n    // Check for collisions with the screen boundaries and bounce the shapes off them\n    if (shape1X < minX || shape1X > maxX) {\n      shape1SpeedX *= -1;\n    }\n    if (shape1Y < minY || shape1Y > maxY) {\n      shape1SpeedY *= -1;\n    }\n    \n    if (shape2X < minX || shape2X > maxX - shape2Size) {\n      shape2SpeedX *= -1;\n    }\n    if (shape2Y < minY || shape2Y > maxY - shape2Size) {\n      shape2SpeedY *= -1;\n    }",N:"Paste from noncoded source"},{T:BC2NY=,P:2080,L:"T",E:"\b"},{T:BC2P8=,P:2076-2080,L:"T",E:"    }"},{T:BC2T8=,P:2081,L:"T",E:"}"},{T:BC6Ro=,P:2081,L:"T",E:"\b"},{T:BC6Xk=,P:1996-2075,L:"C",E:" if (shape2Y < minY || shape2Y > maxY - shape2Size) {\n      shape2SpeedY *= -1;"},{T:BC6aE=,P:2086,L:"P",E:" if (shape2Y < minY || shape2Y > maxY - shape2Size) {\n      shape2SpeedY *= -1;",N:"internal paste;"},{T:BC6ZY=,P:2081,L:"T",E:"\n    "},{T:BC6io=,P:2096,L:"T",E:"\b3"},{T:BC6l8=,P:2104,L:"T",E:"\bX"},{T:BC6qw=,P:2087-2165,L:"T",E:"\\b[2087-2165]"},{T:BC6vM=,P:1908-2075,L:"C",E:"if (shape2X < minX || shape2X > maxX - shape2Size) {\n      shape2SpeedX *= -1;\n    }\n    if (shape2Y < minY || shape2Y > maxY - shape2Size) {\n      shape2SpeedY *= -1;"},{T:BC6wg=,P:2087,L:"P",E:"if (shape2X < minX || shape2X > maxX - shape2Size) {\n      shape2SpeedX *= -1;\n    }\n    if (shape2Y < minY || shape2Y > maxY - shape2Size) {\n      shape2SpeedY *= -1;",N:"paste from project on same machine;Paste from project with UUID fragment b8829857-d590-474b-a4d0-3ea33e2dc297 10 bytes long;"},{T:BC6zw=,P:2096,L:"T",E:"\b3"},{T:BC63A=,P:2114,L:"T",E:"\b"},{T:BC63E=,P:2113,L:"T",E:"\b3"},{T:BC65E=,P:2130,L:"T",E:"\b3"},{T:BC66s=,P:2184,L:"T",E:"\b3"},{T:BC68M=,P:2202,L:"T",E:"\b3"},{T:BC694=,P:2219,L:"T",E:"\b3"},{T:BC6/w=,P:2239,L:"T",E:"\b3"},{T:BC7BU=,P:2150,L:"T",E:"\b3"},{T:BC7FE=,P:2253,L:"T",E:"\n      "},{T:BC7GE=,P:2254-2260,L:"T",E:"    }}"},{T:BC7Nc=,P:2113,L:"T",E:"3"},{T:BC7OY=,P:2113,L:"T",E:"\be"},{T:BC8Ds=,P:0-2261,L:"C",E:"float shape1X, shape1Y, shape1SpeedX, shape1SpeedY, shape1Size;\n  float shape2X, shape2Y, shape2SpeedX, shape2SpeedY, shape2Size;\n  float shape3X, shape3Y, shape3SpeedX, shape3SpeedY, shape3Size;\n  \n  // Define the boundaries of the screen\n  float minX, minY, maxX, maxY;\n  \n  public void settings() {\n    size(800, 600);\n  }\n  \n  public void setup() {\n    \n    // Initialize the shapes\n    shape1X = random(width);\n    shape1Y = random(height);\n    shape1SpeedX = random(2, 5);\n    shape1SpeedY = random(2, 5);\n    shape1Size = random(20, 50);\n    \n    shape2X = random(width);\n    shape2Y = random(height);\n    shape2SpeedX = random(2, 5);\n    shape2SpeedY = random(2, 5);\n    shape2Size = random(20, 50);\n    \n    shape3X = random(width);\n    shape3Y = random(height);\n    shape3SpeedX = random(2, 5);\n    shape3SpeedY = random(2, 5);\n    shape3Size = random(20, 50);\n    \n    // Set the boundaries of the screen\n    minX = 0;\n    minY = 0;\n    maxX = width;\n    maxY = height;\n  }\n  \n  public void draw() {\n    \n    // Clear the screen\n    background(255);\n    \n    // Move and draw the first shape\n    shape1X += shape1SpeedX;\n    shape1Y += shape1SpeedY;\n    fill(255, 0, 0);\n    ellipse(shape1X, shape1Y, shape1Size, shape1Size);\n    \n    // Move and draw the second shape\n    shape2X += shape2SpeedX;\n    shape2Y += shape2SpeedY;\n    fill(0, 255, 0);\n    rect(shape2X, shape2Y, shape2Size, shape2Size);\n    \n    // Move and draw the third shape\n    shape3X += shape3SpeedX;\n    shape3Y += shape3SpeedY;\n    fill(0, 0, 255);\n    triangle(shape3X, shape3Y, shape3X - shape3Size/2, shape3Y + shape3Size, shape3X + shape3Size/2, shape3Y + shape3Size);\n    \n    // Check for collisions with the screen boundaries and bounce the shapes off them\n    if (shape1X < minX || shape1X > maxX) {\n      shape1SpeedX *= -1;\n    }\n    if (shape1Y < minY || shape1Y > maxY) {\n      shape1SpeedY *= -1;\n    }\n    \n    if (shape2X < minX || shape2X > maxX - shape2Size) {\n      shape2SpeedX *= -1;\n    }\n    if (shape2Y < minY || shape2Y > maxY - shape2Size) {\n      shape2SpeedY *= -1;\n    }\n     if (shape3X < minX || shape3X > maxX - shape3Size) {\n      shape3SpeedX *= -1;\n    }\n    if (shape3Y < minY || shape3Y > maxY - shape3Size) {\n      shape3SpeedY *= -1;\n    }}"},{T:BDA0Q=,P:65,L:"T",E:"\b"},{T:BDA18=,P:129,L:"T",E:"\b"},{T:BDA2s=,P:129,L:"T",E:"\b"},{T:BDA3w=,P:64,L:"T",E:"\b"},{T:BDA7g=,P:0,L:"T",E:"\n\n"},{T:BDA9A=,P:1,L:"T",E:"//list of "},{T:BDCPs=,P:11,L:"T",E:"shapes "},{T:BDCaM=,P:17,L:"T",E:"\b:"},{T:BDCfE=,P:17,L:"T",E:"\b with "},{T:BDCjI=,P:23,L:"T",E:"associated variable "},{T:BDCmQ=,P:42,L:"T",E:"\bs for speed"},{T:BDCpc=,P:53,L:"T",E:" and size."},{T:BDCss=,P:62,L:"T",E:"\b"},{T:BDCuE=,P:62,L:"T",E:"\n"},{T:BDC6E=,P:1-2321,L:"C",E:"//list of shapes with associated variables for speed and size\n\nfloat shape1X, shape1Y, shape1SpeedX, shape1SpeedY, shape1Size;\nfloat shape2X, shape2Y, shape2SpeedX, shape2SpeedY, shape2Size;\nfloat shape3X, shape3Y, shape3SpeedX, shape3SpeedY, shape3Size;\n  \n  // Define the boundaries of the screen\n  float minX, minY, maxX, maxY;\n  \n  public void settings() {\n    size(800, 600);\n  }\n  \n  public void setup() {\n    \n    // Initialize the shapes\n    shape1X = random(width);\n    shape1Y = random(height);\n    shape1SpeedX = random(2, 5);\n    shape1SpeedY = random(2, 5);\n    shape1Size = random(20, 50);\n    \n    shape2X = random(width);\n    shape2Y = random(height);\n    shape2SpeedX = random(2, 5);\n    shape2SpeedY = random(2, 5);\n    shape2Size = random(20, 50);\n    \n    shape3X = random(width);\n    shape3Y = random(height);\n    shape3SpeedX = random(2, 5);\n    shape3SpeedY = random(2, 5);\n    shape3Size = random(20, 50);\n    \n    // Set the boundaries of the screen\n    minX = 0;\n    minY = 0;\n    maxX = width;\n    maxY = height;\n  }\n  \n  public void draw() {\n    \n    // Clear the screen\n    background(255);\n    \n    // Move and draw the first shape\n    shape1X += shape1SpeedX;\n    shape1Y += shape1SpeedY;\n    fill(255, 0, 0);\n    ellipse(shape1X, shape1Y, shape1Size, shape1Size);\n    \n    // Move and draw the second shape\n    shape2X += shape2SpeedX;\n    shape2Y += shape2SpeedY;\n    fill(0, 255, 0);\n    rect(shape2X, shape2Y, shape2Size, shape2Size);\n    \n    // Move and draw the third shape\n    shape3X += shape3SpeedX;\n    shape3Y += shape3SpeedY;\n    fill(0, 0, 255);\n    triangle(shape3X, shape3Y, shape3X - shape3Size/2, shape3Y + shape3Size, shape3X + shape3Size/2, shape3Y + shape3Size);\n    \n    // Check for collisions with the screen boundaries and bounce the shapes off them\n    if (shape1X < minX || shape1X > maxX) {\n      shape1SpeedX *= -1;\n    }\n    if (shape1Y < minY || shape1Y > maxY) {\n      shape1SpeedY *= -1;\n    }\n    \n    if (shape2X < minX || shape2X > maxX - shape2Size) {\n      shape2SpeedX *= -1;\n    }\n    if (shape2Y < minY || shape2Y > maxY - shape2Size) {\n      shape2SpeedY *= -1;\n    }\n     if (shape3X < minX || shape3X > maxX - shape3Size) {\n      shape3SpeedX *= -1;\n    }\n    if (shape3Y < minY || shape3Y > maxY - shape3Size) {\n      shape3SpeedY *= -1;\n    }}"}]}
