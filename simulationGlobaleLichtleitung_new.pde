


/******************  The following part includes a bunch of variables which one may tweak to change the appearance of the simulation.  ******************/

// Change this variable's value to true, to adapt the point of view of an observer that is circling the earth in the latter's opposite turning direction.
boolean movingAroundEarth = false;

// This Variable defines how fast the earth is going to spin(rotate) in radians per frame.
final float rotSpeed = 0.01;

// This Variable defines the radius of the earth in Pixels.
final int earthRadius = 300;

// This variable defines whether the axes of the globe and a circle around the same should be displayed.
final boolean showAxes = true;

// These two variables define the beginning and end index of the cables that shall be loaded from xyzCableFiles (excluding the end index itself).
final int startIndex = 0;  
final int endIndex = 1;

/****************************************************************  End of tweaking part  ****************************************************************/





// Home Display: 1920 * 1080
// The proportions of the sun, the earth and their distance are not realistic...


// These are all the predefined cables
//cable nyld = new cable(40.7, -73.9, 51.5, -0.1);
//cable _45_000 = new cable(45, 0, 0, 0);
//cable sawa = new cable(4);
ArrayList<cable> cables = new ArrayList<cable>();
cable constructionCable;

// These are some lamps
lamp london = new lamp(51.5, -0.1);
lamp madagascar = new lamp(-19.0, 46.5);
//lamp capeOfGoodHope = new lamp(-34.4, 18.5);
//lamp kolkata = new lamp(22.6, 88.4);
lamp _00 = new lamp (0, 0);
lamp _45_0 = new lamp(45, 0);
lamp nyc = new lamp(40.7, -73.9);

// These are some collectors
collector capeOfGoodHope = new collector(-34.4, 18.5);
collector kolkata = new collector(22.6, 88.4);

// miscellanous
final float EARTH_TILT = radians(23.43693);
final int sunDist = 1300;
public PShape earth, sun;
PImage bg;
float rot;
boolean constructing = false;
boolean notMAE;
//String filePath = "C:\\Hausaufgaben\\Seminarfacharbeit[finaler Stand]\\simulationGlobaleLichtleitung_new\\data\\";

void setup() {
  size(1870, 1030, P3D);
  // Creating/loading textures of the sun and the earth
  bg = loadImage("stars.png");
  background(bg);
  earth = createShape(SPHERE, earthRadius);
  earth.setStroke(false);
  earth.setTexture(loadImage("blurredEarth2.jpg"));
  sun = createShape(SPHERE, 500);
  sun.setStroke(false);
  sun.setTexture(loadImage("sun.jpg"));
  //sawa.fromFile(filePath + "sawa.txt");
  cables = loadCables(startIndex, endIndex);
  textAlign(RIGHT, TOP);
  if (!movingAroundEarth)notMAE = true;
}

void draw() {
  background(bg);
  fill(255);

  // This part handles the text displayed on the screen.

  text(int(frameRate) + " fps", 40, 5);
  if (constructing) {
    text("To set a simple cable vertex(one with neither lamp nor collector), press ENTER.\n" +
      "To set a cable vertex with a lamp attached, press 'l'.\n" +
      "To set a cable vertex with a collector attached, press 'k'.\n" +
      "To move around the cable Vertex by one degree(geographic coordinates), use the arrow keys.\n" +
      "To move around the cable Vertex by ten degrees(geographic coordinates), use 'WASD'.\n" +
      "To alter the cable thickness(stroke), press any number between 0 and 9(radius in pixels).\n" +
      "To escape the construction mode and therewith set and save the cable, press 'c'.", width, 0);
    text("Please construct all cables in the same direction (east -> west or vv), otherwise the lamps won't function correctly...", width/2 + 250, 10);
  } else text("To start the construction mode, press 'c'.", width-20, 5);


  // The following part shapes the earth and the sun, applying all the necessary features.

  translate(width/2, height/2);
  if (movingAroundEarth) {
    rotateY(-2*rot);
    translate(0, 0, -5000);
    shape(sun);
  } else {
    rotateY(-HALF_PI);
    translate(0, 0, -sunDist);
    shape(sun);
    translate(0, 0, -3700);
  }
  translate(0, 0, 5000);
  ambientLight(20, 20, 20);
  directionalLight(255, 255, 255, 0, 0, 1);
  if (!movingAroundEarth)rotateY(HALF_PI);
  if (constructing) {
    rotateX(-radians(constructionCable.lat));
    rotateY(HALF_PI-radians(constructionCable.lon));
    ambientLight(100, 100, 80);
  } else {
    rotateZ(-EARTH_TILT);
    rotateY(rot);
    //rotateX(sin(rot)*0.6);
    rot += rotSpeed;
  }
  // Displays all the newly constructed and all the xyzFile cables.
  for (cable cabCur : cables) {
    cabCur.display();
  }
  shape(earth);


  // This part was for custom lamps and collectors. Since these are no longer of need, so is this part...

  /*
  
   //LAMPS
   nyc.display();
   //london.display();
   madagascar.display();
   //kolkata.display();
   //_00.display();
   _45_0.display();
   
   //COLLECTORS 
   capeOfGoodHope.display();
   kolkata.display();
   
   */

  // A circle around- and the axes of the globe; for a better orientation; only if the variable 'showAxes' has been set to true in tweaking part.

  if (showAxes) {
    fill(200);
    stroke(255);
    //rotateX(HALF_PI);
    ellipse(0, 0, 2*earthRadius+20, 2*earthRadius+20);
    //X-Axis: gulf of Guinea(south of Ghana)(0,0) --> somewhere in the pacific...(0,180)
    line(-(earthRadius + 40), 0, 0, (earthRadius + 40), 0, 0);
    //Y-Axis: north --> south pole, apparently...
    line(0, -(earthRadius + 40), 0, 0, (earthRadius + 40), 0);
    //Z-Axis: souh-east of India(0,90) --> Galapagos isles (nw of South America)(0,-90)
    line(0, 0, -(earthRadius + 40), 0, 0, (earthRadius + 40));
  }

  //CABLES
  //_45_000.display();
  //sawa.display();

  //// Displays all the newly constructed and all the xyzFile cables.
  //for (cable cabCur : cables) {
  //  cabCur.display();
  //}

  // Displays all the set and current cableVertexies in contruction mode.
  if (constructing) {
    for (cable.cableVertex cvCur : constructionCable.cvarr) {
      cvCur.displayNob();
    }
    constructionCable.displayCableVertex(constructionCable.cvTemp, color(255, 150, 150));
  }
  //cables.get(0).cvarr.get(2).c.calcIlluminance();
}


// The keyPressed() part is needed for the control of the construction mode. For further information, see the top right corner of the simulation in construction mode.

void keyPressed() {
  if (key == 'c') {
    constructing = !constructing;
    if (constructing) {
      println("cable construction mode enabled");
      //cables.add(new cable());
      constructionCable = new cable();
      if (!notMAE)movingAroundEarth = false;
    } else {
      println("cable construction mode disabled");
      if (constructionCable.cvarr.size()>0) {
        cables.add(constructionCable);
        constructionCable.save();
      }
      if (!notMAE)movingAroundEarth = true;
    }
  }
  if (constructing) {
    if (keyCode == ENTER)constructionCable.setCableVertex("n");
    else if (key == 'l')constructionCable.setCableVertex("l");
    else if (key == 'k')constructionCable.setCableVertex("c");
    else if (keyCode == RIGHT)constructionCable.right();
    else if (keyCode == LEFT)constructionCable.left();
    else if (keyCode == UP)constructionCable.up();
    else if (keyCode == DOWN)constructionCable.down();
    else if (key == 'd')for (int i=0; i<10; i++)constructionCable.right();
    else if (key == 'a')for (int i=0; i<10; i++)constructionCable.left();
    else if (key == 'w')for (int i=0; i<10; i++)constructionCable.up();
    else if (key == 's')for (int i=0; i<10; i++)constructionCable.down();
    else if (key == '0' || key == '1' || key == '2' || key == '3' || key == '4' || key == '5' || key == '6' || key == '7' || key == '8' || key == '9') {
      constructionCable.weight = int(key) - 48; 
      println("cable weight set to " + key);
    }
  }
}



/*void searchCables(int lat, int lon){
  for(cable c : cables){
    for(cable.cableVertex cv : c.cvarr){
      if(
    }
  }
}*/