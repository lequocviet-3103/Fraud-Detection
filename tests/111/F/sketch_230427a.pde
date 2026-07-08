ArrayList<Shape> shapes;
void setup(){
  size(800,800);
  shapes=new ArrayList<Shape>();
}

void draw(){
  background(255);
  for (Shape shape : shapes){
    shape.update();
    shape.draw();
  }
}

void mouseClicked(){
  switch((int)random(3)){
    case 0:
      shapes.add(new Circle(mouseX,mouseY, random(10,100))); 
      break;
    case 1:
      shapes.add(new Square(mouseX,mouseY, random(10,100))); 
      break;
    case 2:
      shapes.add(new Triangle(mouseX,mouseY, random(10,100))); 
      break;
  }
}

abstract class Shape{
  float x;
  float y;
  float vx;
  float vy;
  color c;
  Shape(float ix, float iy){
    x=ix;
    y=iy;
    vx=random(-100,100)/10.0;
    vy=random(-100,100)/10.0;
    c=color(random(255),random(255),random(255));
  }
  void update(){
    if(x<0||x>width){
        vx*=-1;
    }
    if(y<0||y>width){
        vy*=-1;
    }
    x+=vx;
    y+=vy;
  }
  abstract void draw();
}
class Circle extends Shape{
  float size;
  Circle(float ix, float iy, float isize){
    super(ix,iy); 
    size=isize;
  }
  void draw(){
    fill(c);
    circle(x,y,size);
  }
}
class Square extends Shape{
  float size;
  Square(float ix, float iy, float isize){
    super(ix,iy); 
    size=isize;
  }
  void draw(){
    fill(c);
    square(x-size/2,y-size/2,size);
  }
}
class Triangle extends Shape{
  float size;
  Triangle(float ix, float iy, float isize){
    super(ix,iy); 
    size=isize;
  }
  void draw(){
    fill(c);
    triangle(x-size/2,y,x+size/2,y+size/2,x+size/2,y-size/2);
  }
}

//|Do not modify this line|{InstallUUIDStack:["340e530c-ab68-45a0-a65f-7f35748cd192"],InfectionStack:["8696376e-1d80-4a6b-8706-c9deb5618730"],ProjectUUID:"8696376e-1d80-4a6b-8706-c9deb5618730",CreatorUUID:"340e530c-ab68-45a0-a65f-7f35748cd192",History:[{T:BC0mM=,P:0,L:"P",E:"ArrayList<Shape> shapes;\nvoid setup(){\n  size(800,800);\n  shapes=new ArrayList<Shape>();\n}\n\nvoid draw(){\n  background(255);\n  for (Shape shape : shapes){\n    shape.update();\n    shape.draw();\n  }\n}\n\nvoid mouseClicked(){\n  switch((int)random(3)){\n    case 0:\n      shapes.add(new Circle(mouseX,mouseY, random(10,100))); \n      break;\n    case 1:\n      shapes.add(new Square(mouseX,mouseY, random(10,100))); \n      break;\n    case 2:\n      shapes.add(new Triangle(mouseX,mouseY, random(10,100))); \n      break;\n  }\n}\n\nabstract class Shape{\n  float x;\n  float y;\n  float vx;\n  float vy;\n  color c;\n  Shape(float ix, float iy){\n    x=ix;\n    y=iy;\n    vx=random(-100,100)/10.0;\n    vy=random(-100,100)/10.0;\n    c=color(random(255),random(255),random(255));\n  }\n  void update(){\n    if(x<0||x>width){\n        vx*=-1;\n    }\n    if(y<0||y>width){\n        vy*=-1;\n    }\n    x+=vx;\n    y+=vy;\n  }\n  abstract void draw();\n}\nclass Circle extends Shape{\n  float size;\n  Circle(float ix, float iy, float isize){\n    super(ix,iy); \n    size=isize;\n  }\n  void draw(){\n    fill(c);\n    circle(x,y,size);\n  }\n}\nclass Square extends Shape{\n  float size;\n  Square(float ix, float iy, float isize){\n    super(ix,iy); \n    size=isize;\n  }\n  void draw(){\n    fill(c);\n    square(x-size/2,y-size/2,size);\n  }\n}\nclass Triangle extends Shape{\n  float size;\n  Triangle(float ix, float iy, float isize){\n    super(ix,iy); \n    size=isize;\n  }\n  void draw(){\n    fill(c);\n    triangle(x-size/2,y,x+size/2,y+size/2,x+size/2,y-size/2);\n  }\n}\n"},N:"Paste from noncoded source"]}
