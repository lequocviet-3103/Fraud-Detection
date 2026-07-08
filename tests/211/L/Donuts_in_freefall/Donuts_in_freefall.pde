class Torus {
  float x, y, z;
  float radius, tubeRadius;
  float rotationSpeed;
  
  Torus(float x, float y, float z, float radius, float tubeRadius, float rotationSpeed) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.radius = radius;
    this.tubeRadius = tubeRadius;
    this.rotationSpeed = rotationSpeed;
  }
  
  void update() {
    y += 1;  // Move the torus down the screen
    rotateX(rotationSpeed);  // Rotate around the x-axis
    rotateY(rotationSpeed);  // Rotate around the y-axis
  }
  
  void display() {
    pushMatrix();
    translate(x, y, z);
    fill(255, 0, 0);  // Set the fill color to red
    drawTorus(radius, tubeRadius);
    popMatrix();
  }
}

ArrayList<Torus> toruses;
int numToruses = 10;

void setup() {
  size(800, 600, P3D);  
  
  toruses = new ArrayList<Torus>();
  
  for (int i = 0; i < numToruses; i++) {
    float x = random(width);
    float y = random(-height, 0);
    float z = random(-200, 200);
    float radius = random(50, 150);
    float tubeRadius = random(10, 50);
    float rotationSpeed = random(0.01, 0.05);
    
    Torus torus = new Torus(x, y, z, radius, tubeRadius, rotationSpeed);
    toruses.add(torus);
  }
}

void draw() {
  background(0,0,200);  
  
  lights(); 
  
  for (Torus torus : toruses) {
    torus.update();
    torus.display();
    
    // Reset torus position if it goes below the screen
    if (torus.y > height) {
      torus.y = random(-height, 0);
    }
  }
}

void drawTorus(float radius, float tubeRadius) {
  int numVertices = 60;  // Number of vertices around the torus
  
  for (int i = 0; i < numVertices; i++) {
    float theta = map(i, 0, numVertices, 0, TWO_PI);  // Angle around the torus
    
    beginShape(QUAD_STRIP);
    for (int j = 0; j <= numVertices; j++) {
      float phi = map(j, 0, numVertices, 0, TWO_PI);  // Angle along the tube
      
      float x = (radius + tubeRadius * cos(phi)) * cos(theta);
      float y = (radius + tubeRadius * cos(phi)) * sin(theta);
      float z = tubeRadius * sin(phi);
      
      vertex(x, y, z);
      
      x = (radius + tubeRadius * cos(phi)) * cos(theta + 0.1);
      y = (radius + tubeRadius * cos(phi)) * sin(theta + 0.1);
      z = tubeRadius * sin(phi);
      
      vertex(x, y, z);
    }
    endShape();
  }
}
//|Do not modify this line|{InstallUUIDStack:["eed31c45-92f9-4a84-babb-ef447544be6a"],InfectionStack:["cbc8b4ef-9431-4b96-ae42-72bc35f84b48"],ProjectUUID:"cbc8b4ef-9431-4b96-ae42-72bc35f84b48",CreatorUUID:"eed31c45-92f9-4a84-babb-ef447544be6a",History:[{T:DfI8o=,P:0,L:"T",E:"void setr"},{T:DfI+Q=,P:8,L:"T",E:"\b"},{T:DfI+U=,P:7,L:"T",E:"\btup(){\n    size(500,500"},{T:DfJHM=,P:30,L:"T",E:");\n    "},{T:DfJIM=,P:33-37,L:"T",E:"\\b[33-37]}\n\n"},{T:DfJLw=,P:36,L:"T",E:"void draw()"},{T:DfJQQ=,P:47,L:"T",E:"{\n    "},{T:DfJRE=,P:49-53,L:"T",E:"\\b[49-53]}"},{T:DfJh0=,P:48,L:"T",E:"\n    "},{T:DfJjI=,P:53,L:"T",E:"background("},{T:DfJnE=,P:64,L:"T",E:"255,0,0"},{T:DfJr0=,P:71,L:"T",E:")"},{T:DfJtU=,P:72,L:"T",E:";"},{T:DfMgk=,P:35-75,L:"P",E:"import java.awt.*;\nimport javax.swing.*;\n\npublic class RainDisplay extends JPanel {\n    private static final int WIDTH = 800;\n    private static final int HEIGHT = 600;\n    private static final int NUM_RAINDROPS = 100;\n\n    private Raindrop[] raindrops;\n\n    public RainDisplay() {\n        setPreferredSize(new Dimension(WIDTH, HEIGHT));\n        setBackground(Color.BLACK);\n        raindrops = new Raindrop[NUM_RAINDROPS];\n        for (int i = 0; i < NUM_RAINDROPS; i++) {\n            raindrops[i] = new Raindrop();\n        }\n    }\n\n    @Override\n    protected void paintComponent(Graphics g) {\n        super.paintComponent(g);\n        Graphics2D g2d = (Graphics2D) g;\n\n        for (Raindrop raindrop : raindrops) {\n            raindrop.update();\n            g2d.setColor(Color.WHITE);\n            g2d.fillOval(raindrop.x, raindrop.y, 2, 10);\n        }\n\n        repaint();\n    }\n\n    private class Raindrop {\n        private int x;\n        private int y;\n        private double speed;\n\n        public Raindrop() {\n            this.x = (int) (Math.random() * WIDTH);\n            this.y = (int) (Math.random() * HEIGHT);\n            this.speed = Math.random() * 5 + 1;\n        }\n\n        public void update() {\n            y += speed;\n            if (y > HEIGHT) {\n                y = 0;\n                x = (int) (Math.random() * WIDTH);\n            }\n        }\n    }\n\n    public static void main(String[] args) {\n        JFrame frame = new JFrame(\"Rain Animation\");\n        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);\n        frame.getContentPane().add(new RainDisplay());\n        frame.pack();\n        frame.setLocationRelativeTo(null);\n        frame.setVisible(true);\n    }\n}",N:"Paste from noncoded source"},{T:DfM6A=,P:1407-1447,L:"T",E:"\\b[1407-1447]"},{T:DfM68=,P:1679,L:"T",E:"\b"},{T:DfNDQ=,P:1680,L:"T",E:"\b"},{T:DfNLI=,P:1407-1680,L:"T",E:"\\b[1407-1680]"},{T:DfNPI=,P:1401,L:"T",E:"}"},{T:DfPuk=,P:34-1408,L:"P",E:"import java.awt.*;\nimport javax.swing.*;\n\npublic class RainDisplay extends JPanel {\n    private static final int WIDTH = 800;\n    private static final int HEIGHT = 600;\n    private static final int NUM_RAINDROPS = 100;\n\n    private Raindrop[] raindrops;\n\n    public RainDisplay() {\n        setPreferredSize(new Dimension(WIDTH, HEIGHT));\n        setBackground(Color.BLACK);\n        raindrops = new Raindrop[NUM_RAINDROPS];\n        for (int i = 0; i < NUM_RAINDROPS; i++) {\n            raindrops[i] = new Raindrop();\n        }\n    }\n\n    @Override\n    protected void paintComponent(Graphics g) {\n        super.paintComponent(g);\n        Graphics2D g2d = (Graphics2D) g;\n\n        for (Raindrop raindrop : raindrops) {\n            raindrop.update();\n            g2d.setColor(Color.WHITE);\n            g2d.fillOval(raindrop.x, raindrop.y, 2, 10);\n        }\n\n        repaint();\n    }\n\n    private class Raindrop {\n        private int x;\n        private int y;\n        private double speed;\n\n        public Raindrop() {\n            this.x = (int) (Math.random() * WIDTH);\n            this.y = (int) (Math.random() * HEIGHT);\n            this.speed = Math.random() * 5 + 1;\n        }\n\n        public void update() {\n            y += speed;\n            if (y > HEIGHT) {\n                y = 0;\n                x = (int) (Math.random() * WIDTH);\n            }\n        }\n    }",N:"Paste from noncoded source"},{T:DfPyY=,P:34,L:"T",E:"\n"},{T:DfP3c=,P:1401,L:"T",E:"\n    "},{T:DfP34=,P:1402-1406,L:"T",E:"\\b[1402-1406]}"},{T:DfSio=,P:0-1403,L:"P",E:"import java.awt.*;\nimport javax.swing.*;\n\n/**\n * A simple Java program to display a rain animation.\n */\npublic class RainDisplay extends JPanel {\n    private static final int WIDTH = 800;\n    private static final int HEIGHT = 600;\n    private static final int NUM_RAINDROPS = 100;\n\n    private Raindrop[] raindrops;\n\n    /**\n     * Constructs a RainDisplay panel.\n     */\n    public RainDisplay() {\n        setPreferredSize(new Dimension(WIDTH, HEIGHT));\n        setBackground(Color.BLACK);\n        raindrops = new Raindrop[NUM_RAINDROPS];\n        for (int i = 0; i < NUM_RAINDROPS; i++) {\n            raindrops[i] = new Raindrop();\n        }\n    }\n\n    @Override\n    protected void paintComponent(Graphics g) {\n        super.paintComponent(g);\n        Graphics2D g2d = (Graphics2D) g;\n\n        for (Raindrop raindrop : raindrops) {\n            raindrop.update();\n            g2d.setColor(Color.WHITE);\n            g2d.fillOval(raindrop.x, raindrop.y, 2, 10);\n        }\n\n        repaint();\n    }\n\n    private class Raindrop {\n        private int x;\n        private int y;\n        private double speed;\n\n        /**\n         * Constructs a Raindrop object.\n         * Initializes the position and speed of the raindrop randomly.\n         */\n        public Raindrop() {\n            this.x = (int) (Math.random() * WIDTH);\n            this.y = (int) (Math.random() * HEIGHT);\n            this.speed = Math.random() * 5 + 1;\n        }\n\n        /**\n         * Updates the position of the raindrop based on its speed.\n         * If the raindrop reaches the bottom of the screen, it resets to the top.\n         */\n        public void update() {\n            y += speed;\n            if (y > HEIGHT) {\n                y = 0;\n                x = (int) (Math.random() * WIDTH);\n            }\n        }\n    }\n\n    /**\n     * The entry point of the program.\n     * Creates a JFrame and adds the RainDisplay panel to it.\n     * Sets up the JFrame and makes it visible.\n     *\n     * @param args the command line arguments\n     */\n    public static void main(String[] args) {\n        JFrame frame = new JFrame(\"Rain Animation\");\n        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);\n        frame.getContentPane().add(new RainDisplay());\n        frame.pack();\n        frame.setLocationRelativeTo(null);\n        frame.setVisible(true);\n    }\n}",N:"Paste from noncoded source"},{T:DfUGY=,P:104-2334,L:"P",E:"java\nCopy code\nvoid setup() {\n  size(800, 600, P3D);  // Create a P3D canvas with dimensions 800x600\n}\n\nvoid draw() {\n  background(255);  // Set the background color to white\n  \n  lights();  // Enable lighting\n  \n  translate(width / 2, height / 2, 0);  // Move the coordinate system to the center of the canvas\n  \n  fill(0, 0, 255);  // Set the fill color to blue\n  \n  sphere(100);  // Draw a sphere with a radius of 100\n}",N:"Paste from noncoded source"},{T:DfUJ8=,P:0-118,L:"T",E:"\\b[0-118]"},{T:DfUOI=,P:0,L:"T",E:"\b"},{T:DfUrM=,P:0-407,L:"P",E:"float angle = 0;\nfloat rotationSpeed = 0.02;\n\nvoid setup() {\n  size(800, 600, P3D);  // Create a P3D canvas with dimensions 800x600\n}\n\nvoid draw() {\n  background(255);  // Set the background color to white\n  \n  lights();  // Enable lighting\n  \n  translate(width / 2, height / 2, 0);  // Move the coordinate system to the center of the canvas\n  \n  rotateX(angle);  // Rotate around the x-axis\n  rotateY(angle);  // Rotate around the y-axis\n  \n  fill(255, 0, 0);  // Set the fill color to red\n  \n  torus(150, 50);  // Draw a torus with a radius of 150 and a tube radius of 50\n  \n  angle += rotationSpeed;  // Update the rotation angle\n}",N:"Paste from noncoded source"},{T:DfVGI=,P:444,L:"T",E:"draw"},{T:DfVcA=,P:0,L:"P",E:"float angle = 0;\nfloat rotationSpeed = 0.02;\n\nvoid setup() {\n  size(800, 600, P3D);  // Create a P3D canvas with dimensions 800x600\n}\n\nvoid draw() {\n  background(255);  // Set the background color to white\n  \n  lights();  // Enable lighting\n  \n  translate(width / 2, height / 2, 0);  // Move the coordinate system to the center of the canvas\n  \n  rotateX(angle);  // Rotate around the x-axis\n  rotateY(angle);  // Rotate around the y-axis\n  \n  fill(255, 0, 0);  // Set the fill color to red\n  \n  drawTorus(150, 50);  // Draw a torus with a radius of 150 and a tube radius of 50\n  \n  angle += rotationSpeed;  // Update the rotation angle\n}\n\nvoid drawTorus(float radius, float tubeRadius) {\n  int numVertices = 60;  // Number of vertices around the torus\n  \n  for (int i = 0; i < numVertices; i++) {\n    float theta = map(i, 0, numVertices, 0, TWO_PI);  // Angle around the torus\n    \n    beginShape(QUAD_STRIP);\n    for (int j = 0; j <= numVertices; j++) {\n      float phi = map(j, 0, numVertices, 0, TWO_PI);  // Angle along the tube\n      \n      float x = (radius + tubeRadius * cos(phi)) * cos(theta);\n      float y = (radius + tubeRadius * cos(phi)) * sin(theta);\n      float z = tubeRadius * sin(phi);\n      \n      vertex(x, y, z);\n      \n      x = (radius + tubeRadius * cos(phi)) * cos(theta + 0.1);\n      y = (radius + tubeRadius * cos(phi)) * sin(theta + 0.1);\n      z = tubeRadius * sin(phi);\n      \n      vertex(x, y, z);\n    }\n    endShape();\n  }\n}",N:"Paste from noncoded source"},{T:DfVbU=,P:0-638,L:"T",E:"\\b[0-638]"},{T:DfVuU=,P:84-131,L:"T",E:"\\b[84-131]"},{T:DfVuo=,P:83,L:"T",E:"\b"},{T:DfVvk=,P:85,L:"T",E:"\b"},{T:DfV0E=,P:158,L:"T",E:"\b"},{T:DfV0Q=,P:157,L:"T",E:"\b"},{T:DfV0g=,P:156,L:"T",E:"\b"},{T:DfV2s=,P:173-188,L:"T",E:"\\b[173-188]"},{T:DfV3k=,P:126,L:"T",E:"ting"},{T:DfV6E=,P:176,L:"T",E:"\b"},{T:DfV6I=,P:175,L:"T",E:"\b"},{T:DfV6U=,P:174,L:"T",E:"\b"},{T:DfV6c=,P:173,L:"T",E:"\b"},{T:DfV7k=,P:175,L:"T",E:"\b"},{T:DfV70=,P:174,L:"T",E:"\b"},{T:DfV8E=,P:173,L:"T",E:"\b"},{T:DfV+s=,P:214-271,L:"T",E:"\\b[214-271]"},{T:DfV+8=,P:213,L:"T",E:"\b"},{T:DfWAk=,P:215,L:"T",E:"\b"},{T:DfWAw=,P:214,L:"T",E:"\b"},{T:DfWBA=,P:213,L:"T",E:"\b"},{T:DfWC4=,P:309,L:"T",E:"\b"},{T:DfWDE=,P:308,L:"T",E:"\b"},{T:DfWDU=,P:307,L:"T",E:"\b"},{T:DfWIU=,P:326-356,L:"T",E:"\\b[326-356]"},{T:DfWJU=,P:328,L:"T",E:"\b"},{T:DfWJk=,P:327,L:"T",E:"\b"},{T:DfWJw=,P:326,L:"T",E:"\b"},{T:DfWKk=,P:412,L:"T",E:"\b"},{T:DfWKw=,P:411,L:"T",E:"\b"},{T:DfWK4=,P:410,L:"T",E:"\b"},{T:DfWMo=,P:437-466,L:"T",E:"\\b[437-466]"},{T:DfW4g=,P:0-1260,L:"T",E:"\\b[0-1260]"},{T:DfXQA=,P:0,L:"P",E:"class Torus {\n  float x, y, z;\n  float radius, tubeRadius;\n  float rotationSpeed;\n  \n  Torus(float x, float y, float z, float radius, float tubeRadius, float rotationSpeed) {\n    this.x = x;\n    this.y = y;\n    this.z = z;\n    this.radius = radius;\n    this.tubeRadius = tubeRadius;\n    this.rotationSpeed = rotationSpeed;\n  }\n  \n  void update() {\n    y += 1;  // Move the torus down the screen\n    rotateX(rotationSpeed);  // Rotate around the x-axis\n    rotateY(rotationSpeed);  // Rotate around the y-axis\n  }\n  \n  void display() {\n    pushMatrix();\n    translate(x, y, z);\n    fill(255, 0, 0);  // Set the fill color to red\n    drawTorus(radius, tubeRadius);\n    popMatrix();\n  }\n}\n\nArrayList<Torus> toruses;\nint numToruses = 100;\n\nvoid setup() {\n  size(800, 600, P3D);  // Create a P3D canvas with dimensions 800x600\n  \n  toruses = new ArrayList<Torus>();\n  \n  for (int i = 0; i < numToruses; i++) {\n    float x = random(width);\n    float y = random(-height, 0);\n    float z = random(-200, 200);\n    float radius = random(50, 150);\n    float tubeRadius = random(10, 50);\n    float rotationSpeed = random(0.01, 0.05);\n    \n    Torus torus = new Torus(x, y, z, radius, tubeRadius, rotationSpeed);\n    toruses.add(torus);\n  }\n}\n\nvoid draw() {\n  background(255);  // Set the background color to white\n  \n  lights();  // Enable lighting\n  \n  for (Torus torus : toruses) {\n    torus.update();\n    torus.display();\n    \n    // Reset torus position if it goes below the screen\n    if (torus.y > height) {\n      torus.y = random(-height, 0);\n    }\n  }\n}\n\nvoid drawTorus(float radius, float tubeRadius) {\n  int numVertices = 60;  // Number of vertices around the torus\n  \n  for (int i = 0; i < numVertices; i++) {\n    float theta = map(i, 0, numVertices, 0, TWO_PI);  // Angle around the torus\n    \n    beginShape(QUAD_STRIP);\n    for (int j = 0; j <= numVertices; j++) {\n      float phi = map(j, 0, numVertices, 0, TWO_PI);  // Angle along the tube\n      \n      float x = (radius + tubeRadius * cos(phi)) * cos(theta);\n      float y = (radius + tubeRadius * cos(phi)) * sin(theta);\n      float z = tubeRadius * sin(phi);\n      \n      vertex(x, y, z);\n      \n      x = (radius + tubeRadius * cos(phi)) * cos(theta + 0.1);\n      y = (radius + tubeRadius * cos(phi)) * sin(theta + 0.1);\n      z = tubeRadius * sin(phi);\n      \n      vertex(x, y, z);\n    }\n    endShape();\n  }\n}",N:"Paste from noncoded source"},{T:DfXn4=,P:732,L:"T",E:"\b"},{T:DfYMk=,P:774-820,L:"T",E:"\\b[774-820]"},{T:DfYRo=,P:1213,L:"T",E:"\b"},{T:DfYR4=,P:1212,L:"T",E:"\b"},{T:DfYSA=,P:1211,L:"T",E:"\b180"},{T:DfYdU=,P:1213,L:"T",E:"\b"},{T:DfYdY=,P:1212,L:"T",E:"\b"},{T:DfYdg=,P:1211,L:"T",E:"\b0,0,"},{T:DfYhA=,P:1215,L:"T",E:"200"},{T:DfYpQ=,P:1222-1258,L:"T",E:"\\b[1222-1258]"},{T:DfYrI=,P:1238-1257,L:"T",E:"\\b[1238-1257]"}]}
