import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.Random;

void setup(){
    size(500,500);
}
int y=100;
int vy=0;
void draw(){
	background(255,255,255);

    int x1, y1;
    boolean full;

		void paintComponent(Graphics g) {
        super.paintComponent(g);
        int shape;
        shape = (int)(Math.random() * 4);
    }

    ScreenSaver1() {
        t = new Timer(500, this);
        t.setDelay(500);
        t.start();
        frame.setUndecorated(true);
        frame.addKeyListener(new KeyHandler());
        frame.add(this);
        rectangle = GraphicsEnvironment.getLocalGraphicsEnvironment()
        .getDefaultScreenDevice().getDefaultConfiguration().getBounds();
        frame.setSize(rectangle.width, rectangle.height);
        frame.setVisible(true);
        full = true;
    }


class KeyHandler extends KeyAdapter {
    public void keyPressed(KeyEvent e) {
        if (e.getKeyChar() == 'x') {
            System.out.println("Exiting");
            System.exit(0);
        }
        else if (e.getKeyChar() == 'r') {
            System.out.println("Change background color");
            setBackground(new Color((int)(Math.random() * 256), (int)(Math.random() * 256), (int)(Math.random() * 256)));
            repaint();
        }
        else if (e.getKeyChar() == 'z') {
            System.out.println("Resizing");
            frame.setSize((int)rectangle.getWidth() / 2, (int)rectangle.getHeight());
        }
    }

}

private void makeLine(Graphics g) {
    int x = (int)(Math.random() * rectangle.getWidth());
    int y = (int)(Math.random() * rectangle.getHeight());
    int x1 = (int)(Math.random() * 100);
    int y1 = (int)(Math.random() * 100);
    g.setColor(new Color((int)(Math.random() * 256), (int)(Math.random() * 256), (int)(Math.random() * 256) ));
    g.drawLine(x, y, x1, y1);
}

private void makeRect(Graphics g) {
    int x = (int)(Math.random() * rectangle.getWidth());
    int y = (int)(Math.random() * rectangle.getHeight());
    int width = (int)(Math.random() * 100);
    int height = (int)(Math.random() * 100);
    g.setColor(new Color((int)(Math.random() * 256), (int)(Math.random() * 256), (int)(Math.random() * 256) ));
    g.drawRect(x, y, width, height);
}

private void makeOval(Graphics g) {
    int x = (int)(Math.random() * rectangle.getWidth());
    int y = (int)(Math.random() * rectangle.getHeight());
    int width = (int)(Math.random() * 100);
    int height = (int)(Math.random() * 100);
    g.setColor(new Color((int)(Math.random() * 256), (int)(Math.random() * 256), (int)(Math.random() * 256) ));
    g.drawOval(x, y, width, height);
}

private void makeRoundRect(Graphics g) {
    int x = (int)(Math.random() * rectangle.getWidth());
    int y = (int)(Math.random() * rectangle.getHeight());
    int width = (int)(Math.random() * 100);
    int height = (int)(Math.random() * 100);
    int arcWidth = (int)(Math.random() * width);
    int arcHeight = (int)(Math.random() * height);
    g.setColor(new Color((int)(Math.random() * 256), (int)(Math.random() * 256), (int)(Math.random() * 256) ));
    g.drawRoundRect(x, y, width, height, arcWidth, arcHeight);
}

public static void main(String[] args) 

}
//|Do not modify this line|{InstallUUIDStack:["80bc27c0-84fc-4b0f-bb30-33bf2649fca6"],InfectionStack:["0c76859e-d23e-4c8c-b3cc-73628135a910","a3f8ae70-33f0-4931-9fc0-537017e34601"],ProjectUUID:"0c76859e-d23e-4c8c-b3cc-73628135a910",CreatorUUID:"80bc27c0-84fc-4b0f-bb30-33bf2649fca6",History:[{T:BDDFk=,P:0,L:"P",E:"Color randomColor = new Color(r, g, b);",N:"Paste from noncoded source"},{T:BDDGk=,P:38,L:"T",E:"\b"},{T:BDDG8=,P:37,L:"T",E:"\b"},{T:BDDG8=,P:36,L:"T",E:"\b"},{T:BDDG8=,P:35,L:"T",E:"\b"},{T:BDDHA=,P:34,L:"T",E:"\b"},{T:BDDHA=,P:33,L:"T",E:"\b"},{T:BDDHA=,P:32,L:"T",E:"\b"},{T:BDDHE=,P:31,L:"T",E:"\b"},{T:BDDHE=,P:30,L:"T",E:"\b"},{T:BDDHE=,P:29,L:"T",E:"\b"},{T:BDDHI=,P:28,L:"T",E:"\b"},{T:BDDHI=,P:27,L:"T",E:"\b"},{T:BDDHI=,P:26,L:"T",E:"\b"},{T:BDDHI=,P:25,L:"T",E:"\b"},{T:BDDHM=,P:24,L:"T",E:"\b"},{T:BDDHM=,P:23,L:"T",E:"\b"},{T:BDDHM=,P:22,L:"T",E:"\b"},{T:BDDHQ=,P:21,L:"T",E:"\b"},{T:BDDHQ=,P:20,L:"T",E:"\b"},{T:BDDHQ=,P:19,L:"T",E:"\b"},{T:BDDHU=,P:18,L:"T",E:"\b"},{T:BDDHU=,P:17,L:"T",E:"\b"},{T:BDDHU=,P:16,L:"T",E:"\b"},{T:BDDHY=,P:15,L:"T",E:"\b"},{T:BDDHY=,P:14,L:"T",E:"\b"},{T:BDDHY=,P:13,L:"T",E:"\b"},{T:BDDHc=,P:12,L:"T",E:"\b"},{T:BDDHc=,P:11,L:"T",E:"\b"},{T:BDDHc=,P:10,L:"T",E:"\b"},{T:BDDHc=,P:9,L:"T",E:"\b"},{T:BDDHg=,P:8,L:"T",E:"\b"},{T:BDDHg=,P:7,L:"T",E:"\b"},{T:BDDHg=,P:6,L:"T",E:"\b"},{T:BDDHk=,P:5,L:"T",E:"\b"},{T:BDDHk=,P:4,L:"T",E:"\b"},{T:BDDHk=,P:3,L:"T",E:"\b"},{T:BDDHo=,P:2,L:"T",E:"\b"},{T:BDDHo=,P:1,L:"T",E:"\b"},{T:BDDHo=,P:0,L:"T",E:"\b"},{T:BDERM=,P:0,L:"P",E:"import javax.swing.*;\nimport java.awt.*;\nimport java.awt.event.*;\nimport java.util.Random;\n\npublic class ScreenSaver1 extends JPanel implements ActionListener {\n    private JFrame frame = new JFrame(\"FullSize\");\n    private Rectangle rectangle;\n    Timer t;\n    int x1, y1;\n    boolean full;\n\n    protected void paintComponent(Graphics g) {\n        super.paintComponent(g);\n        int shape;\n        shape = (int)(Math.random() * 4);\n    }\n\n    ScreenSaver1() {\n        t = new Timer(500, this);\n        t.setDelay(500);\n        t.start();\n        // Remove the title bar, min, max, close stuff\n        frame.setUndecorated(true);\n        // Add a Key Listener to the frame\n        frame.addKeyListener(new KeyHandler());\n        // Add this panel object to the frame\n        frame.add(this);\n        // Get the dimensions of the screen\n        rectangle = GraphicsEnvironment.getLocalGraphicsEnvironment()\n        .getDefaultScreenDevice().getDefaultConfiguration().getBounds();\n        // Set the size of the frame to the size of the screen\n        frame.setSize(rectangle.width, rectangle.height);\n        frame.setVisible(true);\n        // Remember that we are currently at full size\n        full = true;\n    }\n\n\n// This method will run when any key is pressed in the window\nclass KeyHandler extends KeyAdapter {\n    public void keyPressed(KeyEvent e) {\n        // Terminate the program.\n        if (e.getKeyChar() == 'x') {\n            System.out.println(\"Exiting\");\n            System.exit(0);\n        }\n        else if (e.getKeyChar() == 'r') {\n            System.out.println(\"Change background color\");\n            setBackground(new Color((int)(Math.random() * 256), (int)(Math.random() * 256), (int)(Math.random() * 256)));\n            repaint();\n        }\n        else if (e.getKeyChar() == 'z') {\n            System.out.println(\"Resizing\");\n            frame.setSize((int)rectangle.getWidth() / 2, (int)rectangle.getHeight());\n        }\n    }\n\n}\n\nprivate void makeLine(Graphics g) {\n    int x = (int)(Math.random() * rectangle.getWidth());\n    int y = (int)(Math.random() * rectangle.getHeight());\n    int x1 = (int)(Math.random() * 100);\n    int y1 = (int)(Math.random() * 100);\n    g.setColor(new Color((int)(Math.random() * 256), (int)(Math.random() * 256), (int)(Math.random() * 256) ));\n    g.drawLine(x, y, x1, y1);\n}\n\nprivate void makeRect(Graphics g) {\n    int x = (int)(Math.random() * rectangle.getWidth());\n    int y = (int)(Math.random() * rectangle.getHeight());\n    int width = (int)(Math.random() * 100);\n    int height = (int)(Math.random() * 100);\n    g.setColor(new Color((int)(Math.random() * 256), (int)(Math.random() * 256), (int)(Math.random() * 256) ));\n    g.drawRect(x, y, width, height);\n}\n\nprivate void makeOval(Graphics g) {\n    int x = (int)(Math.random() * rectangle.getWidth());\n    int y = (int)(Math.random() * rectangle.getHeight());\n    int width = (int)(Math.random() * 100);\n    int height = (int)(Math.random() * 100);\n    g.setColor(new Color((int)(Math.random() * 256), (int)(Math.random() * 256), (int)(Math.random() * 256) ));\n    g.drawOval(x, y, width, height);\n}\n\nprivate void makeRoundRect(Graphics g) {\n    int x = (int)(Math.random() * rectangle.getWidth());\n    int y = (int)(Math.random() * rectangle.getHeight());\n    int width = (int)(Math.random() * 100);\n    int height = (int)(Math.random() * 100);\n    int arcWidth = (int)(Math.random() * width);\n    int arcHeight = (int)(Math.random() * height);\n    g.setColor(new Color((int)(Math.random() * 256), (int)(Math.random() * 256), (int)(Math.random() * 256) ));\n    g.drawRoundRect(x, y, width, height, arcWidth, arcHeight);\n}\n\npublic static void main(String[] args) {\n        ScreenSaver1 obj = new ScreenSaver1();\n    }\n}",N:"Paste from noncoded source"},{T:BDEUk=,P:1142-1188,L:"T",E:"\\b[1142-1188]"},{T:BDEUw=,P:1141,L:"T",E:"\b"},{T:BDEVM=,P:1140,L:"T",E:"\b"},{T:BDEVU=,P:1139,L:"T",E:"\b"},{T:BDEVc=,P:1138,L:"T",E:"\b"},{T:BDEVk=,P:1137,L:"T",E:"\b"},{T:BDEVs=,P:1136,L:"T",E:"\b"},{T:BDEV0=,P:1135,L:"T",E:"\b"},{T:BDEV8=,P:1134,L:"T",E:"\b"},{T:BDEWE=,P:1133,L:"T",E:"\b"},{T:BDEYw=,P:981-1043,L:"T",E:"\\b[981-1043]"},{T:BDEZA=,P:980,L:"T",E:"\b"},{T:BDEa4=,P:794-837,L:"T",E:"\\b[794-837]"},{T:BDEbU=,P:793,L:"T",E:"\b"},{T:BDEdg=,P:1197-1230,L:"T",E:"\\b[1197-1230]"},{T:BDEeA=,P:1196,L:"T",E:"\b"},{T:BDEgI=,P:1056-1117,L:"T",E:"\\b[1056-1117]"},{T:BDEgU=,P:1055,L:"T",E:"\b"},{T:BDEmA=,P:723-768,L:"T",E:"\\b[723-768]"},{T:BDEmQ=,P:722,L:"T",E:"\b"},{T:BDEo8=,P:632-674,L:"T",E:"\\b[632-674]"},{T:BDEpY=,P:631,L:"T",E:"\b"},{T:BDEro=,P:541-595,L:"T",E:"\\b[541-595]"},{T:BDEsI=,P:540,L:"T",E:"\b"},{T:BDE0c=,P:92-104,L:"T",E:"final"},{T:BDFSE=,P:92-250,L:"P",E:"void setup(){\n    size(500,500);\n}\nint y=100;\nint vy=0;\nvoid draw(){\n	background(255,255,255);\n	fill(255,0,0);\n	circle(100,100,20);",N:"paste from project on same machine;Paste from project with UUID fragment a3f8ae70-33f0-4931-9fc0-537017e34601 9 bytes long;"},{T:BDFT0=,P:223,L:"T",E:"\n"},{T:BDFbw=,P:187-223,L:"T",E:"\\b[187-223]"},{T:BDFcE=,P:186,L:"T",E:"\b"},{T:BDF+4=,P:3213-3265,L:"T",E:"\\b[3213-3265]"},{T:BDGAc=,P:3211,L:"T",E:"\b"},{T:BDGGY=,P:223-237,L:"T",E:"\\b[223-237]		"}]}
