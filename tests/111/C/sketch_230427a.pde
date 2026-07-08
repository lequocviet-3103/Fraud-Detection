import java.util.ArrayList;

abstract class Shape {
  protected float x, y, vx, vy;
  protected int c;

  public Shape(float x, float y, float vx, float vy) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.c = color((int) random(256), (int) random(256), (int) random(256));
  }

  public abstract void draw();

  public void update() {
    x += vx;
    y += vy;

    if (x < 0 || x > width) {
      vx = -vx;
    }
    if (y < 0 || y > height) {
      vy = -vy;
    }
  }
}

class Square extends Shape {
  private float size;

  public Square(float x, float y, float vx, float vy, float size) {
    super(x, y, vx, vy);
    this.size = size;
  }

  public void draw() {
    fill(c);
    rect(x, y, size, size);
  }
}

class Circle extends Shape {
  private float radius;

  public Circle(float x, float y, float vx, float vy, float radius) {
    super(x, y, vx, vy);
    this.radius = radius;
  }

  public void draw() {
    fill(c);
    ellipse(x, y, 2 * radius, 2 * radius);
  }
}

class Triangle extends Shape {
  private float size;

  public Triangle(float x, float y, float vx, float vy, float size) {
    super(x, y, vx, vy);
    this.size = size;
  }

  public void draw() {
    fill(c);
    float halfSize = size / 2;
    triangle(x - halfSize, y + halfSize, x, y - halfSize, x + halfSize, y + halfSize);
  }
}

ArrayList<Shape> shapes;

void setup() {
  size(500, 500);
  shapes = new ArrayList<Shape>();
}

void draw() {
  background(255);

  for (Shape shape : shapes) {
    shape.update();
    shape.draw();
  }
}

void mouseClicked() {
  float x = mouseX;
  float y = mouseY;
  float vx = random(-5, 5);
  float vy = random(-5, 5);
  int type = (int) random(3);
  Shape shape;

  switch (type) {
    case 0:
      shape = new Square(x, y, vx, vy, random(50, 100));
      break;
    case 1:
      shape = new Circle(x, y, vx, vy, random(50, 100));
      break;
    case 2:
      shape = new Triangle(x, y, vx, vy, random(50, 100));
      break;
    default:
      shape = new Circle(x, y, vx, vy, random(50, 100));
  }

  shapes.add(shape);
}

//|Do not modify this line|{InstallUUIDStack:["109990d7-8395-40aa-b3fb-f057653161b4"],InfectionStack:["60d8b28d-52e5-4620-a042-c78efab7d485","3f942ced-3300-4ffc-b35e-d9da4c623f30","109990d7-8395-40aa-b3fb-f057653161b4"],ProjectUUID:"60d8b28d-52e5-4620-a042-c78efab7d485",CreatorUUID:"109990d7-8395-40aa-b3fb-f057653161b4",History:[{T:BDkjc=,P:0,L:"P",E:"import java.util.ArrayList;\n\nabstract class Shape {\n  protected float x, y, vx, vy;\n  protected int c;\n\n  public Shape(float x, float y, float vx, float vy) {\n    this.x = x;\n    this.y = y;\n    this.vx = vx;\n    this.vy = vy;\n    this.c = color((int) random(256), (int) random(256), (int) random(256));\n  }\n\n  public abstract void draw();\n\n  public void update() {\n    x += vx;\n    y += vy;\n\n    if (x < 0 || x > width) {\n      vx = -vx;\n    }\n    if (y < 0 || y > height) {\n      vy = -vy;\n    }\n  }\n}\n\nclass Square extends Shape {\n  private float size;\n\n  public Square(float x, float y, float vx, float vy, float size) {\n    super(x, y, vx, vy);\n    this.size = size;\n  }\n\n  public void draw() {\n    fill(c);\n    rect(x, y, size, size);\n  }\n}\n\nclass Circle extends Shape {\n  private float radius;\n\n  public Circle(float x, float y, float vx, float vy, float radius) {\n    super(x, y, vx, vy);\n    this.radius = radius;\n  }\n\n  public void draw() {\n    fill(c);\n    ellipse(x, y, 2 * radius, 2 * radius);\n  }\n}\n\nclass Triangle extends Shape {\n  private float size;\n\n  public Triangle(float x, float y, float vx, float vy, float size) {\n    super(x, y, vx, vy);\n    this.size = size;\n  }\n\n  public void draw() {\n    fill(c);\n    float halfSize = size / 2;\n    triangle(x - halfSize, y + halfSize, x, y - halfSize, x + halfSize, y + halfSize);\n  }\n}\n\nArrayList<Shape> shapes;\n\nvoid setup() {\n  size(500, 500);\n  shapes = new ArrayList<Shape>();\n}\n\nvoid draw() {\n  background(255);\n\n  for (Shape shape : shapes) {\n    shape.update();\n    shape.draw();\n  }\n}\n\nvoid mouseClicked() {\n  float x = mouseX;\n  float y = mouseY;\n  float vx = random(-5, 5);\n  float vy = random(-5, 5);\n  int type = (int) random(3);\n  Shape shape;\n\n  switch (type) {\n    case 0:\n      shape = new Square(x, y, vx, vy, random(50, 100));\n      break;\n    case 1:\n      shape = new Circle(x, y, vx, vy, random(50, 100));\n      break;\n    case 2:\n      shape = new Triangle(x, y, vx, vy, random(50, 100));\n      break;\n    default:\n      shape = new Circle(x, y, vx, vy, random(50, 100));\n  }\n\n  shapes.add(shape);\n}\n",N:"paste from project with same creator;Paste from project with UUID 3f942ced-3300-4ffc-b35e-d9da4c623f30;"}]}
