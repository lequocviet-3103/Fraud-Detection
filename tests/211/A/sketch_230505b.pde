/*To complete this assignment, I looked up how to code a program that draws fractals
/I ended up running across some python programs and videos outlining the general 
/structure of creating a fractal program.
/eventually I came across the processing.org site that had a number of different fractal
/programs, this is where I got the code for this Penrose Snowflake.
*/
PenroseSnowflakeLSystem ps;

void setup() {
  size(500, 500);
  stroke(255);
  noFill();
  ps = new PenroseSnowflakeLSystem();
  ps.simulate(4);
}

void draw() {
  background(0);
  ps.render();
}

class LSystem 
{
  int steps = 0;

  String axiom;
  String rule;
  String production;

  float startLength;
  float drawLength;
  float theta;

  int generations;

  LSystem() {
    axiom = "F";
    rule = "F+F-F";
    startLength = 90.0;
    theta = radians(120.0);
    reset();
  }

  void reset() {
    production = axiom;
    drawLength = startLength;
    generations = 0;
  }

  int getAge() {
    return generations;
  }

  void render() {
    translate(width/2, height/2);
    steps += 5;          
    if (steps > production.length()) {
      steps = production.length();
    }
    for (int i = 0; i < steps; i++) {
      char step = production.charAt(i);
      if (step == 'F') {
        rect(0, 0, -drawLength, -drawLength);
        noFill();
        translate(0, -drawLength);
      } 
      else if (step == '+') {
        rotate(theta);
      } 
      else if (step == '-') {
        rotate(-theta);
      } 
      else if (step == '[') {
        pushMatrix();
      } 
      else if (step == ']') {
        popMatrix();            
      }
    }
  }

  void simulate(int gen) {
    while (getAge() < gen) {
      production = iterate(production, rule);
    }
  }

  String iterate(String prod_, String rule_) {
    drawLength = drawLength * 0.6;
    generations++;
    String newProduction = prod_;          
    newProduction = newProduction.replaceAll("F", rule_);
    return newProduction;
  }
}
class PenroseSnowflakeLSystem extends LSystem {

  String ruleF;

  PenroseSnowflakeLSystem() {
    axiom = "F3-F3-F3-F3-F";
    ruleF = "F3-F3-F45-F++F3-F";
    startLength = 450.0;
    theta = radians(18); 
    reset();
  }

  void useRule(String r_) {
    rule = r_;
  }

  void useAxiom(String a_) {
    axiom = a_;
  }

  void useLength(float l_) {
    startLength = l_;
  }

  void useTheta(float t_) {
    theta = radians(t_);
  }

  void reset() {
    production = axiom;
    drawLength = startLength;
    generations = 0;
  }

  int getAge() {
    return generations;
  }

  void render() {
    translate(width, height);
    int repeats = 1;

    steps += 3;          
    if (steps > production.length()) {
      steps = production.length();
    }

    for (int i = 0; i < steps; i++) {
      char step = production.charAt(i);
      if (step == 'F') {
        for (int j = 0; j < repeats; j++) {
          line(0,0,0, -drawLength);
          translate(0, -drawLength);
        }
        repeats = 1;
      } 
      else if (step == '+') {
        for (int j = 0; j < repeats; j++) {
          rotate(theta);
        }
        repeats = 1;
      } 
      else if (step == '-') {
        for (int j =0; j < repeats; j++) {
          rotate(-theta);
        }
        repeats = 1;
      } 
      else if (step == '[') {
        pushMatrix();
      } 
      else if (step == ']') {
        popMatrix();
      } 
      else if ( (step >= 48) && (step <= 57) ) {
        repeats += step - 48;
      }
    }
  }


  String iterate(String prod_, String rule_) {
    String newProduction = "";
    for (int i = 0; i < prod_.length(); i++) {
      char step = production.charAt(i);
      if (step == 'F') {
        newProduction = newProduction + ruleF;
      } 
      else {
        if (step != 'F') {
          newProduction = newProduction + step;
        }
      }
    }
    drawLength = drawLength * 0.4;
    generations++;
    return newProduction;
  }

}
//|Do not modify this line|{InstallUUIDStack:["b07e9869-9115-445d-ae28-09fbf2aa87c4"],InfectionStack:["8d52ea13-ccd3-4fd4-89b9-41f9e24d1eae","e8d176a9-8b95-4209-88a6-ac3d443ba982","429ee4a6-db79-433a-add0-cd2549316b24","b07e9869-9115-445d-ae28-09fbf2aa87c4","f0fdd70d-9b31-4f89-bacf-20f62b8b54c9","101f9a5a-3894-4eef-a734-b5d3ba198668","47792baf-92e5-42de-9c0f-94a11fa07db7","96b081ec-e052-4a7a-8751-2dbfde6d56b3"],ProjectUUID:"8d52ea13-ccd3-4fd4-89b9-41f9e24d1eae",CreatorUUID:"b07e9869-9115-445d-ae28-09fbf2aa87c4",History:[{T:CrMQE=,P:0,L:"P",E:"/*To complete this assignment, I looked up how to code a program that draws fractals\n/I ended up running across some python programs and videos outlining the general \n/structure of creating a fractal program.\n/eventually I came across the processing.org site that had a number of different fractal\n/programs, this is where I got the code for this Penrose Snowflake.\n*/\nPenroseSnowflakeLSystem ps;\n\nvoid setup() {\n  size(500, 500);\n  stroke(255);\n  noFill();\n  ps = new PenroseSnowflakeLSystem();\n  ps.simulate(4);\n}\n\nvoid draw() {\n  background(0);\n  ps.render();\n}"},N:"paste from project with same creator;Paste from project with UUID e8d176a9-8b95-4209-88a6-ac3d443ba982;",{T:CrMVk=,P:566,L:"P",E:"class LSystem \n{\n  int steps = 0;\n\n  String axiom;\n  String rule;\n  String production;\n\n  float startLength;\n  float drawLength;\n  float theta;\n\n  int generations;\n\n  LSystem() {\n    axiom = \"F\";\n    rule = \"F+F-F\";\n    startLength = 90.0;\n    theta = radians(120.0);\n    reset();\n  }\n\n  void reset() {\n    production = axiom;\n    drawLength = startLength;\n    generations = 0;\n  }\n\n  int getAge() {\n    return generations;\n  }\n\n  void render() {\n    translate(width/2, height/2);\n    steps += 5;          \n    if (steps > production.length()) {\n      steps = production.length();\n    }\n    for (int i = 0; i < steps; i++) {\n      char step = production.charAt(i);\n      if (step == 'F') {\n        rect(0, 0, -drawLength, -drawLength);\n        noFill();\n        translate(0, -drawLength);\n      } \n      else if (step == '+') {\n        rotate(theta);\n      } \n      else if (step == '-') {\n        rotate(-theta);\n      } \n      else if (step == '[') {\n        pushMatrix();\n      } \n      else if (step == ']') {\n        popMatrix();            \n      }\n    }\n  }\n\n  void simulate(int gen) {\n    while (getAge() < gen) {\n      production = iterate(production, rule);\n    }\n  }\n\n  String iterate(String prod_, String rule_) {\n    drawLength = drawLength * 0.6;\n    generations++;\n    String newProduction = prod_;          \n    newProduction = newProduction.replaceAll(\"F\", rule_);\n    return newProduction;\n  }\n}"},N:"paste from project with same creator;Paste from project with UUID f0fdd70d-9b31-4f89-bacf-20f62b8b54c9;",{T:CrMUs=,P:564,L:"T",E:"\n\n"},{T:CrMaE=,P:1980,L:"P",E:"class PenroseSnowflakeLSystem extends LSystem {\n\n  String ruleF;\n\n  PenroseSnowflakeLSystem() {\n    axiom = \"F3-F3-F3-F3-F\";\n    ruleF = \"F3-F3-F45-F++F3-F\";\n    startLength = 450.0;\n    theta = radians(18); \n    reset();\n  }\n\n  void useRule(String r_) {\n    rule = r_;\n  }\n\n  void useAxiom(String a_) {\n    axiom = a_;\n  }\n\n  void useLength(float l_) {\n    startLength = l_;\n  }\n\n  void useTheta(float t_) {\n    theta = radians(t_);\n  }\n\n  void reset() {\n    production = axiom;\n    drawLength = startLength;\n    generations = 0;\n  }\n\n  int getAge() {\n    return generations;\n  }\n\n  void render() {\n    translate(width, height);\n    int repeats = 1;\n\n    steps += 3;          \n    if (steps > production.length()) {\n      steps = production.length();\n    }\n\n    for (int i = 0; i < steps; i++) {\n      char step = production.charAt(i);\n      if (step == 'F') {\n        for (int j = 0; j < repeats; j++) {\n          line(0,0,0, -drawLength);\n          translate(0, -drawLength);\n        }\n        repeats = 1;\n      } \n      else if (step == '+') {\n        for (int j = 0; j < repeats; j++) {\n          rotate(theta);\n        }\n        repeats = 1;\n      } \n      else if (step == '-') {\n        for (int j =0; j < repeats; j++) {\n          rotate(-theta);\n        }\n        repeats = 1;\n      } \n      else if (step == '[') {\n        pushMatrix();\n      } \n      else if (step == ']') {\n        popMatrix();\n      } \n      else if ( (step >= 48) && (step <= 57) ) {\n        repeats += step - 48;\n      }\n    }\n  }\n\n\n  String iterate(String prod_, String rule_) {\n    String newProduction = \"\";\n    for (int i = 0; i < prod_.length(); i++) {\n      char step = production.charAt(i);\n      if (step == 'F') {\n        newProduction = newProduction + ruleF;\n      } \n      else {\n        if (step != 'F') {\n          newProduction = newProduction + step;\n        }\n      }\n    }\n    drawLength = drawLength * 0.4;\n    generations++;\n    return newProduction;\n  }\n\n}"},N:"paste from project with same creator;Paste from project with UUID 47792baf-92e5-42de-9c0f-94a11fa07db7;",{T:CrMZI=,P:1979,L:"T",E:"\n"}]}
