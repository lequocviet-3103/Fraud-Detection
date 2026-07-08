import java.awt.Color;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import javax.swing.JFrame;

public class MandelbrotSet extends JFrame {

    private final int MAX_ITER = 1000;
    private final double ZOOM = 150;
    private BufferedImage image;

    public MandelbrotSet() {
        super("Mandelbrot Set");
        setBounds(100, 100, 800, 600);
        setResizable(false);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        image = new BufferedImage(getWidth(), getHeight(), BufferedImage.TYPE_INT_RGB);
        int[] colors = new int[MAX_ITER];
        for (int i = 0; i < MAX_ITER; i++) {
            colors[i] = Color.HSBtoRGB(i/256f, 1, i/(i+8f));
        }
        for (int y = 0; y < getHeight(); y++) {
            for (int x = 0; x < getWidth(); x++) {
                double zx = 0;
                double zy = 0;
                double cX = (x - 400) / ZOOM;
                double cY = (y - 300) / ZOOM;
                int iter = MAX_ITER;
                while (zx*zx + zy*zy < 4 && iter > 0) {
                    double tmp = zx*zx - zy*zy + cX;
                    zy = 2.0*zx*zy + cY;
                    zx = tmp;
                    iter--;
                }
                image.setRGB(x, y, iter == 0 ? 0 : colors[iter % MAX_ITER]);
            }
        }
    }

    @Override
    public void paint(Graphics g) {
        g.drawImage(image, 0, 0, this);
    }

    public static void main(String[] args) {
        MandelbrotSet mandelbrot = new MandelbrotSet();
        mandelbrot.setVisible(true);
    }

}

// i found this while googling mandelbrot set code for java
//|Do not modify this line|{InstallUUIDStack:["84710a06-ae66-45d4-9962-f6ad0d0a157b"],InfectionStack:["07fc2447-225b-42ea-bcb1-499706b4e24c"],ProjectUUID:"07fc2447-225b-42ea-bcb1-499706b4e24c",CreatorUUID:"84710a06-ae66-45d4-9962-f6ad0d0a157b",History:[{T:Cryug=,P:0,L:"P",E:"import java.awt.Color;\n\npublic class Mandelbrot {\n\n    // return number of iterations to check if c = a + ib is in Mandelbrot set\n    public static int mand(Complex z0, int max) {\n        Complex z = z0;\n        for (int t = 0; t < max; t++) {\n            if (z.abs() > 2.0) return t;\n            z = z.times(z).plus(z0);\n        }\n        return max;\n    }\n\n    public static void main(String[] args)  {\n        double xc   = Double.parseDouble(args[0]);\n        double yc   = Double.parseDouble(args[1]);\n        double size = Double.parseDouble(args[2]);\n\n        int n   = 512;   // create n-by-n image\n        int max = 255;   // maximum number of iterations\n\n        Picture picture = new Picture(n, n);\n        for (int i = 0; i < n; i++) {\n            for (int j = 0; j < n; j++) {\n                double x0 = xc - size/2 + size*i/n;\n                double y0 = yc - size/2 + size*j/n;\n                Complex z0 = new Complex(x0, y0);\n                int gray = max - mand(z0, max);\n                Color color = new Color(gray, gray, gray);\n                picture.set(i, n-1-j, color);\n            }\n        }\n        picture.show();\n    }\n}"},N:"Paste from noncoded source",{T:Cry3Y=,P:1014-1019,L:"T",E:"thing"},{T:Cry6A=,P:1089-1094,L:"T",E:"thing"},{T:Cr0To=,P:24-1152,L:"P",E:"for (int row = 0; row < height; row++) {\n    for (int col = 0; col < width; col++) {\n        double c_re = (col - width/2.0)*4.0/width;\n        double c_im = (row - height/2.0)*4.0/width;\n        double x = 0, y = 0;\n        int iteration = 0;\n        while (x*x+y*y <= 4 && iteration < max) {\n            double x_new = x*x - y*y + c_re;\n            y = 2*x*y + c_im;\n            x = x_new;\n            iteration++;\n        }\n        if (iteration < max) putpixel(col, row, white);\n        else putpixel(col, row, black);\n    }\n}"},N:"Paste from noncoded source",{T:Cr02A=,P:24-554,L:"P",E:"import java.awt.Color;\n\npublic class Mandelbrot {\n\n    // return number of iterations to check if c = a + ib is in Mandelbrot set\n    public static int mand(Complex z0, int max) {\n        Complex z = z0;\n        for (int t = 0; t < max; t++) {\n            if (z.abs() > 2.0) return t;\n            z = z.times(z).plus(z0);\n        }\n        return max;\n    }\n\n    public static void main(String[] args)  {\n        double xc   = Double.parseDouble(args[0]);\n        double yc   = Double.parseDouble(args[1]);\n        double size = Double.parseDouble(args[2]);\n\n        int n   = 512;   // create n-by-n image\n        int max = 255;   // maximum number of iterations\n\n        Picture picture = new Picture(n, n);\n        for (int i = 0; i < n; i++) {\n            for (int j = 0; j < n; j++) {\n                double x0 = xc - size/2 + size*i/n;\n                double y0 = yc - size/2 + size*j/n;\n                Complex z0 = new Complex(x0, y0);\n                int gray = max - mand(z0, max);\n                Color color = new Color(gray, gray, gray);\n                picture.set(i, n-1-j, color);\n            }\n        }\n        picture.show();\n    }\n}"},N:"Paste from noncoded source",{T:Cr5uc=,P:0-1176,L:"P",E:"import java.awt.Color;\nimport java.awt.Graphics;\nimport java.awt.image.BufferedImage;\nimport javax.swing.JFrame;\n\npublic class MandelbrotSet extends JFrame {\n\n    private final int MAX_ITER = 1000;\n    private final double ZOOM = 150;\n    private BufferedImage image;\n\n    public MandelbrotSet() {\n        super(\"Mandelbrot Set\");\n        setBounds(100, 100, 800, 600);\n        setResizable(false);\n        setDefaultCloseOperation(EXIT_ON_CLOSE);\n        image = new BufferedImage(getWidth(), getHeight(), BufferedImage.TYPE_INT_RGB);\n        int[] colors = new int[MAX_ITER];\n        for (int i = 0; i < MAX_ITER; i++) {\n            colors[i] = Color.HSBtoRGB(i/256f, 1, i/(i+8f));\n        }\n        for (int y = 0; y < getHeight(); y++) {\n            for (int x = 0; x < getWidth(); x++) {\n                double zx = 0;\n                double zy = 0;\n                double cX = (x - 400) / ZOOM;\n                double cY = (y - 300) / ZOOM;\n                int iter = MAX_ITER;\n                while (zx*zx + zy*zy < 4 && iter > 0) {\n                    double tmp = zx*zx - zy*zy + cX;\n                    zy = 2.0*zx*zy + cY;\n                    zx = tmp;\n                    iter--;\n                }\n                image.setRGB(x, y, iter == 0 ? 0 : colors[iter % MAX_ITER]);\n            }\n        }\n    }\n\n    @Override\n    public void paint(Graphics g) {\n        g.drawImage(image, 0, 0, this);\n    }\n\n    public static void main(String[] args) {\n        MandelbrotSet mandelbrot = new MandelbrotSet();\n        mandelbrot.setVisible(true);\n    }\n\n}"},N:"Paste from noncoded source",{T:Cr6tQ=,P:1561,L:"T",E:"\n\n// i found this while google"},{T:Cr6xw=,P:1590,L:"T",E:"\bing ho"},{T:Cr6yg=,P:1595,L:"T",E:"\b"},{T:Cr6zQ=,P:1594,L:"T",E:"\bmandelbrot set code for java"}]}
