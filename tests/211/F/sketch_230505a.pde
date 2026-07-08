/**
 * I used a resource that was shared in an ICS discord
 * processing.org/examples/mandelbrot.html
**/
void setup(){
    size(640,360);
}

void draw(){
    background(255,255,255);
    
    float w = 4;
    float h = (w * height) / width;
    float xmin = -w/2;
    float ymin = -h/2;
    loadPixels();
    int maxiterations = 100;
    float xmax = xmin + w;
    float ymax = ymin + h;
    float dx = (xmax - xmin) / (width);
	float dy = (ymax - ymin) / (height);
	float y = ymin;
	for (int j = 0; j < height; j++) {
  		float x = xmin;
 		for (int i = 0; i < width; i++) {

    		// Now we test, as we iterate z = z^2 + c does z tend towards infinity?
    		float a = x;
    		float b = y;
    		int n = 0;
    		float max = 4.0;  // Infinity in our finite world is simple, let's just consider it 4
    		float absOld = 0.0;
    		float convergeNumber = maxiterations; // this will change if the while loop breaks due to non-convergence
    		while (n < maxiterations) {
     	     // We suppose z = a+ib
      			float aa = a * a;
            	float bb = b * b;
    	    	float abs = sqrt(aa + bb);
    	    	if (abs > max) { // |z| = sqrt(a^2+b^2)
    	       // Now measure how much we exceeded the maximum: 
    	    	float diffToLast = (float) (abs - absOld);
    	    	float diffToMax  = (float) (max - absOld);
    	    	convergeNumber = n + diffToMax/diffToLast;
    	    	break;  // Bail
    	      }
      		  float twoab = 2.0 * a * b;
      		  a = aa - bb + x; // this operation corresponds to z -> z^2+c where z=a+ib c=(x,y)
      		  b = twoab + y;
      		  n++;
      		  absOld = abs;
      		 }

      		 // We color each pixel based on how long it takes to get to infinity
      		 // If we never got there, let's pick the color black
      		 if (n == maxiterations) {
      		 	pixels[i+j*width] = color(0);
      		 } else {
      		 // Gosh, we could make fancy colors here if we wanted
      		 float norm = map(convergeNumber, 0, maxiterations, 0, 1);
      		 pixels[i+j*width] = color(map(sqrt(norm), 0, 1, 0, 255));
      		}
      		x += dx;
      	   }
		  y += dy;
		}
		updatePixels();
}
//|Do not modify this line|{InstallUUIDStack:["d4684576-09c1-4409-a446-d364e75b640c"],InfectionStack:["847de5dc-0ca2-487a-9bde-2803134e4155","984b2744-40a9-4d40-b4d6-5b548dcab945","847de5dc-0ca2-487a-9bde-2803134e4155","984b2744-40a9-4d40-b4d6-5b548dcab945"],ProjectUUID:"984b2744-40a9-4d40-b4d6-5b548dcab945",CreatorUUID:"d4684576-09c1-4409-a446-d364e75b640c",History:[{T:Cv9uE=,P:0,L:"T",E:"void setip()"},{T:Cv9wI=,P:11,L:"T",E:"\b"},{T:Cv9wM=,P:10,L:"T",E:"\b"},{T:Cv9wQ=,P:9,L:"T",E:"\b"},{T:Cv9wY=,P:8,L:"T",E:"\bup(){\n    "},{T:Cv90k=,P:18,L:"T",E:"\n    "},{T:Cv91A=,P:22,L:"T",E:"\b"},{T:Cv91M=,P:21,L:"T",E:"\b"},{T:Cv91U=,P:20,L:"T",E:"\b"},{T:Cv91Y=,P:19,L:"T",E:"\b"},{T:Cv91g=,P:18,L:"T",E:"\b"},{T:Cv91k=,P:17,L:"T",E:"\b"},{T:Cv914=,P:16,L:"T",E:"\b"},{T:Cv914=,P:15,L:"T",E:"\b"},{T:Cv918=,P:14,L:"T",E:"\b"},{T:Cv92I=,P:13,L:"T",E:"\b"},{T:Cv92I=,P:12,L:"T",E:"\b"},{T:Cv92M=,P:11,L:"T",E:"\b"},{T:Cv92M=,P:10,L:"T",E:"\b"},{T:Cv92M=,P:9,L:"T",E:"\b"},{T:Cv92Q=,P:8,L:"T",E:"\b"},{T:Cv92Q=,P:7,L:"T",E:"\b"},{T:Cv92Q=,P:6,L:"T",E:"\b"},{T:Cv92U=,P:5,L:"T",E:"\b"},{T:Cv92U=,P:4,L:"T",E:"\b"},{T:Cv92U=,P:3,L:"T",E:"\b"},{T:Cv92Y=,P:2,L:"T",E:"\b"},{T:Cv92Y=,P:1,L:"T",E:"\b"},{T:Cv92Y=,P:0,L:"T",E:"\bvoid sewt"},{T:Cv93k=,P:8,L:"T",E:"\b"},{T:Cv93o=,P:7,L:"T",E:"\btup{"},{T:Cv94w=,P:10,L:"T",E:"\b(){\n    \n    "},{T:Cv97s=,P:22,L:"T",E:"\b"},{T:Cv98A=,P:19-22,L:"T",E:"\\b[19-22]}\n\nvoid draw"},{T:Cv+AQ=,P:31,L:"T",E:"(){\n    \n    "},{T:Cv+B0=,P:43,L:"T",E:"\b"},{T:Cv+CE=,P:42,L:"T",E:"\b"},{T:Cv+CU=,P:41,L:"T",E:"\b"},{T:Cv+Co=,P:40,L:"T",E:"\b\\b[40-40]}"},{T:Cv+FE=,P:18,L:"T",E:"size(500,500_"},{T:Cv+II=,P:30,L:"T",E:"\b);"},{T:Cv+k0=,P:53,L:"T",E:"baackgroun"},{T:Cv+l4=,P:62,L:"T",E:"\b"},{T:Cv+l8=,P:61,L:"T",E:"\b"},{T:Cv+mE=,P:60,L:"T",E:"\b"},{T:Cv+mM=,P:59,L:"T",E:"\b"},{T:Cv+mU=,P:58,L:"T",E:"\b"},{T:Cv+mY=,P:57,L:"T",E:"\b"},{T:Cv+mg=,P:56,L:"T",E:"\b"},{T:Cv+mo=,P:55,L:"T",E:"\bckground("},{T:Cv+qk=,P:64,L:"T",E:"255,0,0);"},{T:Cv+xk=,P:68,L:"T",E:"\b255"},{T:Cv+0s=,P:72,L:"T",E:"\b255"},{T:CwA3E=,P:87,L:"P",E:"float w = 4;\nfloat h = (w * height) / width;",N:"Paste from noncoded source"},{T:CwA2Q=,P:77,L:"T",E:"\n    \n    "},{T:CwA5o=,P:100,L:"T",E:"	"},{T:CwBBk=,P:94,L:"T",E:"idth"},{T:CwBDc=,P:112,L:"T",E:"eight"},{T:CwBGU=,P:122,L:"T",E:"idth"},{T:CwBM4=,P:87-145,L:"T",E:"\\b[87-145]"},{T:CwBms=,P:87,L:"T",E:"float "},{T:CwBq8=,P:92,L:"T",E:"\b"},{T:CwBrA=,P:91,L:"T",E:"\b"},{T:CwBrI=,P:90,L:"T",E:"\b"},{T:CwBrM=,P:89,L:"T",E:"\b"},{T:CwBrU=,P:88,L:"T",E:"\b"},{T:CwBrc=,P:87,L:"T",E:"\b"},{T:CwB4I=,P:87,L:"T",E:"float w;"},{T:CwB9Q=,P:94,L:"T",E:"\b = 4;\n    "},{T:CwCBk=,P:104,L:"T",E:"float h = "},{T:CwCF4=,P:114,L:"T",E:"(w*height"},{T:CwCKM=,P:123,L:"T",E:")/width;"},{T:CwCM8=,P:131,L:"T",E:"\n    "},{T:CwCQo=,P:136,L:"T",E:"float"},{T:CwCR8=,P:140,L:"T",E:"\bx"},{T:CwCSY=,P:140,L:"T",E:"\bt xmin = "},{T:CwCWI=,P:149,L:"T",E:"-w/2;\n    "},{T:CwFaM=,P:24,L:"T",E:"\b"},{T:CwFaU=,P:23,L:"T",E:"\b64"},{T:CwFdI=,P:28,L:"T",E:"\b"},{T:CwFdQ=,P:27,L:"T",E:"\b36"},{T:CwFm0=,P:159,L:"T",E:"float ymin = -h/2;\n    "},{T:CwFxU=,P:182,L:"T",E:"loadPixels();\n    "},{T:CwF1o=,P:200,L:"T",E:"int maxiet"},{T:CwF3c=,P:209,L:"T",E:"\bt"},{T:CwF3k=,P:209,L:"T",E:"\b"},{T:CwF3s=,P:208,L:"T",E:"\bterations = 100;\n    fo"},{T:CwF78=,P:230,L:"T",E:"\bloat xmax = xmin + w;\n    float"},{T:CwGD4=,P:116,L:"T",E:" "},{T:CwGEM=,P:118,L:"T",E:" "},{T:CwGFc=,P:126,L:"T",E:" "},{T:CwGFw=,P:128,L:"T",E:" "},{T:CwGKM=,P:265,L:"T",E:" ymax = ymin + h;\n    float dy"},{T:CwGQI=,P:294,L:"T",E:"\bx = (xman"},{T:CwGZ0=,P:300-303,L:"P",E:"float dx = (xmax - xmin) / (width);\nfloat dy = (ymax - ymin) / (height);\n\n// Start y\nfloat y = ymin;\nfor (int j = 0; j < height; j++) {\n  // Start x\n  float x = xmin;\n  for (int i = 0; i < width; i++) {\n\n    // Now we test, as we iterate z = z^2 + c does z tend towards infinity?\n    float a = x;\n    float b = y;\n    int n = 0;\n    float max = 4.0;  // Infinity in our finite world is simple, let's just consider it 4\n    float absOld = 0.0;\n    float convergeNumber = maxiterations; // this will change if the while loop breaks due to non-convergence\n    while (n < maxiterations) {\n      // We suppose z = a+ib\n      float aa = a * a;\n      float bb = b * b;\n      float abs = sqrt(aa + bb);\n      if (abs > max) { // |z| = sqrt(a^2+b^2)\n        // Now measure how much we exceeded the maximum: \n        float diffToLast = (float) (abs - absOld);\n        float diffToMax  = (float) (max - absOld);\n        convergeNumber = n + diffToMax/diffToLast;\n        break;  // Bail\n      }\n      float twoab = 2.0 * a * b;\n      a = aa - bb + x; // this operation corresponds to z -> z^2+c where z=a+ib c=(x,y)\n      b = twoab + y;\n      n++;\n      absOld = abs;\n    }\n\n    // We color each pixel based on how long it takes to get to infinity\n    // If we never got there, let's pick the color black\n    if (n == maxiterations) {\n      pixels[i+j*width] = color(0);\n    } else {\n      // Gosh, we could make fancy colors here if we wanted\n      float norm = map(convergeNumber, 0, maxiterations, 0, 1);\n      pixels[i+j*width] = color(map(sqrt(norm), 0, 1, 0, 255));\n    }\n    x += dx;\n  }\n  y += dy;\n}\nupdatePixels();",N:"Paste from noncoded source"},{T:CwGcE=,P:1912,L:"T",E:"c"},{T:CwGcg=,P:1912,L:"T",E:"\b"},{T:CwGho=,P:299,L:"T",E:"\b"},{T:CwGh8=,P:298,L:"T",E:"\b"},{T:CwGh8=,P:297,L:"T",E:"\b"},{T:CwGh8=,P:296,L:"T",E:"\b"},{T:CwGiA=,P:295,L:"T",E:"\b"},{T:CwGiA=,P:294,L:"T",E:"\b"},{T:CwGiA=,P:293,L:"T",E:"\b"},{T:CwGiA=,P:292,L:"T",E:"\b"},{T:CwGiE=,P:291,L:"T",E:"\b"},{T:CwGiE=,P:290,L:"T",E:"\b"},{T:CwGiM=,P:289,L:"T",E:"\b"},{T:CwGiY=,P:288,L:"T",E:"\b"},{T:CwGik=,P:287,L:"T",E:"\b"},{T:CwGkU=,P:323,L:"T",E:"	"},{T:CwGmU=,P:361-372,L:"T",E:"\\b[361-372]"},{T:CwGms=,P:360,L:"T",E:"\b"},{T:CwGqg=,P:361,L:"T",E:"	"},{T:CwGsw=,P:378,L:"T",E:"	"},{T:CwGvU=,P:413-426,L:"T",E:"\\b[413-426]"},{T:CwGwc=,P:416,L:"T",E:"		"},{T:CwGxY=,P:435,L:"T",E:"		"},{T:CwG0Q=,P:437,L:"T",E:"\b"},{T:CwG4g=,P:476,L:"T",E:"	"},{T:CwG5c=,P:553,L:"T",E:"	"},{T:CwG7w=,P:476,L:"T",E:"	"},{T:CwG8Q=,P:555,L:"T",E:"	"},{T:CwG9c=,P:573,L:"T",E:"		"},{T:CwG+o=,P:592,L:"T",E:"		"},{T:CwHCk=,P:588-594,L:"C",E:"    		"},{T:CwHD8=,P:605-609,L:"P",E:"    		"},{T:CwHHA=,P:697-701,L:"P",E:"    		"},{T:CwHJk=,P:723-727,L:"P",E:"    		"},{T:CwHK0=,P:835-839,L:"P",E:"    		"},{T:CwHNw=,P:870,L:"P",E:"    		"},{T:CwHO0=,P:875,L:"T",E:"\b"},{T:CwHQ8=,P:905,L:"P",E:"    		"},{T:CwHRM=,P:910,L:"T",E:"\b"},{T:CwHTc=,P:910,L:"T",E:"	"},{T:CwHWg=,P:914,L:"T",E:"\b"},{T:CwHa4=,P:938,L:"P",E:"    		"},{T:CwHbQ=,P:943,L:"T",E:"\b"},{T:CwHdc=,P:942,L:"P",E:"    		"},{T:CwHdA=,P:942,L:"T",E:"\b"},{T:CwHd4=,P:947,L:"T",E:"\b"},{T:CwHeQ=,P:946,L:"T",E:"\b"},{T:CwHeo=,P:945,L:"T",E:"\b"},{T:CwHe0=,P:944,L:"T",E:"\b"},{T:CwHfA=,P:943,L:"T",E:"\b"},{T:CwHfg=,P:942,L:"P",E:"    		"},{T:CwHfI=,P:942,L:"T",E:"\b"},{T:CwHf0=,P:947,L:"T",E:"\b"},{T:CwHgo=,P:946,L:"T",E:"\b "},{T:CwHkE=,P:965,L:"P",E:"    		"},{T:CwHkg=,P:970,L:"T",E:"\b"},{T:CwHlw=,P:970,L:"T",E:" "},{T:CwHqg=,P:965-977,L:"C",E:"    	       "},{T:CwHuM=,P:1004-1010,L:"P",E:"    	       ",N:"Paste from noncoded source"},{T:CwHy8=,P:1056-1064,L:"P",E:"    	       ",N:"Paste from noncoded source"},{T:CwH+k=,P:1118-1126,L:"P",E:"    	       ",N:"Paste from noncoded source"},{T:CwIAo=,P:1173-1181,L:"P",E:"    	       ",N:"Paste from noncoded source"},{T:CwICw=,P:1228-1236,L:"P",E:"    	       ",N:"Paste from noncoded source"},{T:CwIF0=,P:1283-1291,L:"P",E:"    	       ",N:"Paste from noncoded source"},{T:CwIPU=,P:1311-1317,L:"P",E:"    	       ",N:"Paste from noncoded source"},{T:CwIQc=,P:1322,L:"T",E:"\b"},{T:CwIS4=,P:1330,L:"T",E:"			"},{T:CwIT8=,P:1332,L:"T",E:"\b  "},{T:CwIZ8=,P:1324-1334,L:"C",E:"      		  "},{T:CwIbw=,P:1361-1367,L:"P",E:"      		  ",N:"Paste from noncoded source"},{T:CwIdo=,P:1453-1459,L:"P",E:"      		  ",N:"Paste from noncoded source"},{T:CwIfM=,P:1478-1484,L:"P",E:"      		  ",N:"Paste from noncoded source"},{T:CwIg4=,P:1493-1499,L:"P",E:"      		  ",N:"Paste from noncoded source"},{T:CwIpY=,P:1517-1521,L:"P",E:"      		  ",N:"Paste from noncoded source"},{T:CwIqY=,P:1526,L:"T",E:"\b"},{T:CwI1U=,P:1529-1533,L:"P",E:"      		  ",N:"Paste from noncoded source"},{T:CwI2Y=,P:1538,L:"T",E:"\b"},{T:CwI4Y=,P:1529-1538,L:"C",E:"      		 "},{T:CwI6c=,P:1607-1611,L:"P",E:"      		 ",N:"Paste from noncoded source"},{T:CwI70=,P:1669-1673,L:"P",E:"      		 ",N:"Paste from noncoded source"},{T:CwI9w=,P:1704-1710,L:"P",E:"      		 ",N:"Paste from noncoded source"},{T:CwI/8=,P:1713,L:"T",E:"	"},{T:CwJE8=,P:913,L:"T",E:"\b"},{T:CwJFM=,P:912,L:"T",E:"\b"},{T:CwJFc=,P:911,L:"T",E:"\b	"},{T:CwJJA=,P:944,L:"T",E:"\b"},{T:CwJJI=,P:943,L:"T",E:"\b"},{T:CwJJU=,P:942,L:"T",E:"\b	"},{T:CwJNA=,P:972,L:"T",E:"\b"},{T:CwJNM=,P:971,L:"T",E:"\b"},{T:CwJNU=,P:970,L:"T",E:"\b	"},{T:CwJQI=,P:1009,L:"T",E:"\b"},{T:CwJQU=,P:1008,L:"T",E:"\b"},{T:CwJQc=,P:1007,L:"T",E:"\b	"},{T:CwJVQ=,P:1121,L:"T",E:"\b"},{T:CwJVY=,P:1120,L:"T",E:"\b"},{T:CwJVk=,P:1119,L:"T",E:"\b	"},{T:CwJYE=,P:1174,L:"T",E:"\b"},{T:CwJYM=,P:1173,L:"T",E:"\b"},{T:CwJYY=,P:1172,L:"T",E:"\b	"},{T:CwJZ4=,P:1227,L:"T",E:"\b"},{T:CwJaI=,P:1226,L:"T",E:"\b"},{T:CwJaY=,P:1225,L:"T",E:"\b	"},{T:CwJbs=,P:1280,L:"T",E:"\b"},{T:CwJb4=,P:1279,L:"T",E:"\b"},{T:CwJcE=,P:1278,L:"T",E:"\b	"},{T:CwJmc=,P:1728-1732,L:"P",E:"      		 ",N:"Paste from noncoded source"},{T:CwJrM=,P:1746-1752,L:"P",E:"      		 ",N:"Paste from noncoded source"},{T:CwJsg=,P:1809-1815,L:"P",E:"      		 ",N:"Paste from noncoded source"},{T:CwJyc=,P:1876-1882,L:"P",E:"      		 ",N:"Paste from noncoded source"},{T:CwJ0U=,P:1943-1947,L:"P",E:"      		 ",N:"Paste from noncoded source"},{T:CwJ5g=,P:1951,L:"T",E:"\b"},{T:CwJ9I=,P:1953-1957,L:"P",E:"      		 ",N:"Paste from noncoded source"},{T:CwJ9c=,P:1961,L:"T",E:"\b"},{T:CwJ/o=,P:1970-1972,L:"P",E:"      		 ",N:"Paste from noncoded source"},{T:CwKAA=,P:1978,L:"T",E:"\b"},{T:CwKAM=,P:1977,L:"T",E:"\b	"},{T:CwKB4=,P:1977,L:"T",E:"\b   "},{T:CwKFQ=,P:1982,L:"T",E:"		"},{T:CwKH0=,P:1984,L:"T",E:"	"},{T:CwKIc=,P:1984,L:"T",E:"\b"},{T:CwKJI=,P:1995,L:"T",E:"		"},{T:CwKMA=,P:1999,L:"T",E:"		"},{T:CwLXA=,P:0,L:"T",E:"\n\n"},{T:CwLYs=,P:0,L:"T",E:"/*\n*"},{T:CwLbQ=,P:5,L:"T",E:"/"},{T:CwLbg=,P:5,L:"T",E:"\b*/"},{T:CwLek=,P:3,L:"T",E:"	"},{T:CwLmk=,P:2,L:"T",E:"*"},{T:CwLn0=,P:7,L:"T",E:"*"},{T:CwLsM=,P:7,L:"T",E:"\b"},{T:CwLuA=,P:4,L:"T",E:"\b`"},{T:CwLvI=,P:4,L:"T",E:"\b "},{T:CwLw0=,P:6,L:"T",E:" "},{T:CwL1k=,P:8,L:"T",E:" "},{T:CwL4Y=,P:8,L:"T",E:"\b*"},{T:CwMCY=,P:7,L:"T",E:"I used a "},{T:CwMHY=,P:16,L:"T",E:"resource that was shared in a "},{T:CwMVg=,P:45,L:"T",E:"\bn ICS discord\n "},{T:CwMak=,P:60,L:"T",E:"* "},{T:CwMfs=,P:62,L:"T",E:"processing.org/exm"},{T:CwMik=,P:79,L:"T",E:"\bamples/mandelbrot.html"}]}
