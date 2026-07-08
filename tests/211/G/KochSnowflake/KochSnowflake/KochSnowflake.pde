/*Attempted to utilize the USB, but ended up just downloading the IDE. 
*In order to complete this assignmeent, I got helped from my peers 
*I also had searched up the solutions from NatureOfCode.com and CHAT GPT.
*/


class KochSnowflake {
  PVector start;
  PVector end;
  ArrayList<KochSnowflake> lines;

  KochSnowflake(PVector a, PVector b) {
    start = a.get();
    end = b.get();
  }

  void display() {
    stroke(0);
    line(start.x, start.y, end.x, end.y);
  }

  void setup() {
    size(600, 300);
    lines = new ArrayList<KochSnowflake>();
    PVector start = new PVector(0, 200);
    PVector end = new PVector(width, 200);
    lines.add(new KochSnowflake(start, end));
  }

  void draw() {
    background(255);
    for (KochSnowflake l : lines) {
      l.display();
    }
  }

  void generate() {
    ArrayList<KochSnowflake> next = new ArrayList<KochSnowflake>();
    for (KochSnowflake l : lines) {
      PVector a = l.kochA();
      PVector b = l.kochB();
      PVector c = l.kochC();
      PVector d = l.kochD();
      PVector e = l.kochE();

      next.add(new KochSnowflake(a, b));
      next.add(new KochSnowflake(b, c));
      next.add(new KochSnowflake(c, d));
      next.add(new KochSnowflake(d, e));
    }

    lines = next;
  }

  PVector kochA() {
    return start.get();
  }

  PVector kochB() {
    PVector v = PVector.sub(end, start);
    v.div(3);
    v.add(start);
    return v;
  }

  PVector kochC() {
    PVector a = start.get();
    PVector v = PVector.sub(end, start);
    v.div(3);
    v.rotate(-radians(60));
    a.add(v);
    return a;
  }

  PVector kochD() {
    PVector v = PVector.sub(end, start);
    v.mult(2f/3);
    v.add(start);
    return v;
  }

  PVector kochE() {
    return end.get();
  }
}

//|Do not modify this line|{InstallUUIDStack:["fcfc067f-9a53-46af-a3de-0967600a7fa3"],InfectionStack:["ad8bddac-9f39-4261-862c-49bca89d42bc","c9d46b00-0868-4cb2-9671-632204dbd19a","fcfc067f-9a53-46af-a3de-0967600a7fa3"],ProjectUUID:"ad8bddac-9f39-4261-862c-49bca89d42bc",CreatorUUID:"fcfc067f-9a53-46af-a3de-0967600a7fa3",History:[{T:CwDKA=,P:0,L:"P",E:"class KochSnowflake{\n  \n  PVector start;\n  PVector end;\n  ArrayList<KochSnowflake> lines;\n \n  KochSnowflake(PVector a, PVector b) {\n    start = a.get();\n    end = b.get();\n  }\n \n  void display() {\n    stroke(0);\n    line(start.x, start.y, end.x, end.y);\n  }\n\nvoid setup() {\n  size(600, 300);\n  lines = new ArrayList<KochSnowflake>();\n\n  PVector start = new PVector(0, 200);\n  PVector end   = new PVector(width, 200);\n  lines.add(new KochSnowflake(start, end));\n}\nvoid draw() {\n  background(255);\n  for (KochSnowflake l : lines) {\n    l.display();\n  }\n}\n\nvoid generate() {\n  ArrayList next = new ArrayList<KochSnowflake>();\n  for (KochSnowflake l : lines) {\n    \n    PVector a = l.kochA();\n    PVector b = l.kochB();\n    PVector c = l.kochC();\n    PVector d = l.kochD();\n    PVector e = l.kochE();\n\n    next.add(new KochSnowflake(a,b));\n    next.add(new KochSnowflake(b,c));\n    next.add(new KochSnowflake(c,d));\n    next.add(new KochSnowflake(d,e));\n  }\n\n  lines = next;\n}\n\n  PVector kochA() {\n    return start.get();\n  }\n \n PVector kochB() {\n    PVector v = PVector.sub(end, start);\n    v.div(3);\n    v.add(start);\n    return v;\n  }\n  \n   PVector kochC() {\n    PVector a = start.get();\n    PVector v = PVector.sub(end, start);\n    v.div(3);\n    a.add(v);\n    v.rotate(-radians(60));\n    a.add(v);\n \n    return a;\n  }\n\n \n  PVector kochD() {\n    PVector v = PVector.sub(end, start);\n    v.mult(2/3.0);\n    v.add(start);\n    return v;\n  }\n  \n  PVector kochE() {\n    return end.get();\n  }\n\n\n\n\n}"},N:"paste from project with same creator;Paste from project with UUID c9d46b00-0868-4cb2-9671-632204dbd19a;",{T:CwEUg=,P:0-1491,L:"C",E:"class KochSnowflake{\n  \n  PVector start;\n  PVector end;\n  ArrayList<KochSnowflake> lines;\n \n  KochSnowflake(PVector a, PVector b) {\n    start = a.get();\n    end = b.get();\n  }\n \n  void display() {\n    stroke(0);\n    line(start.x, start.y, end.x, end.y);\n  }\n\nvoid setup() {\n  size(600, 300);\n  lines = new ArrayList<KochSnowflake>();\n\n  PVector start = new PVector(0, 200);\n  PVector end   = new PVector(width, 200);\n  lines.add(new KochSnowflake(start, end));\n}\nvoid draw() {\n  background(255);\n  for (KochSnowflake l : lines) {\n    l.display();\n  }\n}\n\nvoid generate() {\n  ArrayList next = new ArrayList<KochSnowflake>();\n  for (KochSnowflake l : lines) {\n    \n    PVector a = l.kochA();\n    PVector b = l.kochB();\n    PVector c = l.kochC();\n    PVector d = l.kochD();\n    PVector e = l.kochE();\n\n    next.add(new KochSnowflake(a,b));\n    next.add(new KochSnowflake(b,c));\n    next.add(new KochSnowflake(c,d));\n    next.add(new KochSnowflake(d,e));\n  }\n\n  lines = next;\n}\n\n  PVector kochA() {\n    return start.get();\n  }\n \n PVector kochB() {\n    PVector v = PVector.sub(end, start);\n    v.div(3);\n    v.add(start);\n    return v;\n  }\n  \n   PVector kochC() {\n    PVector a = start.get();\n    PVector v = PVector.sub(end, start);\n    v.div(3);\n    a.add(v);\n    v.rotate(-radians(60));\n    a.add(v);\n \n    return a;\n  }\n\n \n  PVector kochD() {\n    PVector v = PVector.sub(end, start);\n    v.mult(2/3.0);\n    v.add(start);\n    return v;\n  }\n  \n  PVector kochE() {\n    return end.get();\n  }\n\n\n\n\n}"},{T:CwK14=,P:0-1491,L:"P",E:"class KochSnowflake {\n  PVector start;\n  PVector end;\n  ArrayList<KochSnowflake> lines;\n\n  KochSnowflake(PVector a, PVector b) {\n    start = a.get();\n    end = b.get();\n  }\n\n  void display() {\n    stroke(0);\n    line(start.x, start.y, end.x, end.y);\n  }\n\n  void setup() {\n    size(600, 300);\n    lines = new ArrayList<KochSnowflake>();\n    PVector start = new PVector(0, 200);\n    PVector end = new PVector(width, 200);\n    lines.add(new KochSnowflake(start, end));\n  }\n\n  void draw() {\n    background(255);\n    for (KochSnowflake l : lines) {\n      l.display();\n    }\n  }\n\n  void generate() {\n    ArrayList<KochSnowflake> next = new ArrayList<KochSnowflake>();\n    for (KochSnowflake l : lines) {\n      PVector a = l.kochA();\n      PVector b = l.kochB();\n      PVector c = l.kochC();\n      PVector d = l.kochD();\n      PVector e = l.kochE();\n\n      next.add(new KochSnowflake(a, b));\n      next.add(new KochSnowflake(b, c));\n      next.add(new KochSnowflake(c, d));\n      next.add(new KochSnowflake(d, e));\n    }\n\n    lines = next;\n  }\n\n  PVector kochA() {\n    return start.get();\n  }\n\n  PVector kochB() {\n    PVector v = PVector.sub(end, start);\n    v.div(3);\n    v.add(start);\n    return v;\n  }\n\n  PVector kochC() {\n    PVector a = start.get();\n    PVector v = PVector.sub(end, start);\n    v.div(3);\n    v.rotate(-radians(60));\n    a.add(v);\n    return a;\n  }\n\n  PVector kochD() {\n    PVector v = PVector.sub(end, start);\n    v.mult(2f/3);\n    v.add(start);\n    return v;\n  }\n\n  PVector kochE() {\n    return end.get();\n  }\n}\n"},N:"Paste from noncoded source",{T:CwUo4=,P:0,L:"T",E:"\n\n\n"},{T:CwUps=,P:0,L:"T",E:"//"},{T:CwUxo=,P:2,L:"T",E:"ATtemo"},{T:CwUyI=,P:7,L:"T",E:"\b"},{T:CwUyM=,P:6,L:"T",E:"\b"},{T:CwUyQ=,P:5,L:"T",E:"\b"},{T:CwUyU=,P:4,L:"T",E:"\b"},{T:CwUyc=,P:3,L:"T",E:"\bttempted to utilize the USB "},{T:CwU1M=,P:30,L:"T",E:"\bm"},{T:CwU1g=,P:30,L:"T",E:"\b, but ened"},{T:CwU24=,P:39,L:"T",E:"\b"},{T:CwU24=,P:38,L:"T",E:"\bed"},{T:CwU3M=,P:39,L:"T",E:"\b"},{T:CwU3Q=,P:38,L:"T",E:"\bded up just downloading the IDE on my personal "},{T:CwU6o=,P:84,L:"T",E:"\b"},{T:CwU6s=,P:83,L:"T",E:"\b"},{T:CwU6w=,P:82,L:"T",E:"\b"},{T:CwU60=,P:81,L:"T",E:"\b"},{T:CwU64=,P:80,L:"T",E:"\b"},{T:CwU7A=,P:79,L:"T",E:"\b"},{T:CwU7E=,P:78,L:"T",E:"\b"},{T:CwU7I=,P:77,L:"T",E:"\b"},{T:CwU7M=,P:76,L:"T",E:"\b"},{T:CwU7U=,P:75,L:"T",E:"\b"},{T:CwU7Y=,P:74,L:"T",E:"\b"},{T:CwU7c=,P:73,L:"T",E:"\b"},{T:CwU7g=,P:72,L:"T",E:"\b"},{T:CwU7o=,P:71,L:"T",E:"\b"},{T:CwU7s=,P:70,L:"T",E:"\b"},{T:CwU7w=,P:69,L:"T",E:"\b. In order ot complete this\n"},{T:CwVLU=,P:1,L:"T",E:"\b*"},{T:CwVOM=,P:97,L:"T",E:"*/"},{T:CwVPs=,P:97,L:"T",E:"\n\n"},{T:CwVQc=,P:97,L:"T",E:"/"},{T:CwVRg=,P:98,L:"T",E:"/"},{T:CwVWA=,P:81,L:"T",E:"\b"},{T:CwVWE=,P:80,L:"T",E:"\bto "},{T:CwVWo=,P:82,L:"T",E:"\b"},{T:CwVXM=,P:96,L:"T",E:" assignment "},{T:CwVYM=,P:107,L:"T",E:"\b"},{T:CwVYQ=,P:106,L:"T",E:"\b"},{T:CwVYU=,P:105,L:"T",E:"\bent, I ha"},{T:CwVZc=,P:113,L:"T",E:"\b"},{T:CwVZg=,P:112,L:"T",E:"\bgt "},{T:CwVaM=,P:114,L:"T",E:"\b"},{T:CwVaQ=,P:113,L:"T",E:"\bot helped from my peers \n//"},{T:CwVdI=,P:139,L:"T",E:"\bI"},{T:CwVdw=,P:139,L:"T",E:"\b"},{T:CwVeo=,P:138,L:"T",E:"\b*I "},{T:CwVfk=,P:140,L:"T",E:"\b"},{T:CwVfo=,P:139,L:"T",E:"\b I h"},{T:CwVgU=,P:142,L:"T",E:"\balso had sere"},{T:CwVh4=,P:154,L:"T",E:"\b"},{T:CwVh8=,P:153,L:"T",E:"\bea"},{T:CwViM=,P:154,L:"T",E:"\b"},{T:CwViQ=,P:153,L:"T",E:"\barched up the solutions "},{T:CwVsU=,P:177,L:"T",E:"fro"},{T:CwVss=,P:179,L:"T",E:"\b"},{T:CwVsw=,P:178,L:"T",E:"\b"},{T:CwVs0=,P:177,L:"T",E:"\bfrom NatureOfCode.com and CH"},{T:CwVwg=,P:204,L:"T",E:"\bCH"},{T:CwVw4=,P:205,L:"T",E:"\b"},{T:CwVw8=,P:204,L:"T",E:"\bHAT GPT "},{T:CwVx8=,P:211,L:"T",E:"\b\n"},{T:CwVyo=,P:211,L:"T",E:"\b."},{T:CwV0I=,P:214,L:"T",E:"\b"},{T:CwV0M=,P:213,L:"T",E:"\b"},{T:CwV1o=,P:71,L:"T",E:"\n*"},{T:CwV3o=,P:216,L:"T",E:"\b"},{T:CwV3s=,P:215,L:"T",E:"\b"},{T:CwV30=,P:214,L:"T",E:"\b\n"},{T:CwV5U=,P:141,L:"T",E:"\b"},{T:CwV5Y=,P:140,L:"T",E:"\b"},{T:CwV6Y=,P:213-215,L:"C",E:"*/"},{T:CwV74=,P:140,L:"P",E:"*/"},{T:CwV80=,P:72,L:"T",E:"\b"},{T:CwV9c=,P:140,L:"T",E:"\b"},{T:CwV9g=,P:139,L:"T",E:"\b"},{T:CwW9Y=,P:72,L:"T",E:"*"},{T:CwW+M=,P:140,L:"T",E:"*"}]}
