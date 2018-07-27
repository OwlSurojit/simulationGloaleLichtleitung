

// THE LIGHT IS DEFINED TO BE FLOWING FROM EAST TO WEST.


/******************  The following part includes a bunch of variables which one may tweak to change the appearance of the simulation.  ******************/

// This Variable defines how fast the earth is going to spin(rotate) in radians per frame.
final float rotSpeed = 0.01;

// This Variable defines the radius of the earth in Pixels.
final int earthRadius = 300;

// This variable defines whether the axes of the globe and a circle around the same should be displayed.
final boolean showAxes = true;

// This is the name of the folder the constructed cables are stored and going to be stored in.
final String dataFolder = "worldCableSetup[0]";

// These two variables define the beginning and end index of the cables that shall be loaded from xyzCableFiles (excluding the end index itself).
final int startIndex = 0;  
final int endIndex = 30;

/****************************************************************  End of tweaking part  ****************************************************************/





// Home Display: 1920 * 1080
// The proportions of the sun, the earth and their distance are not realistic...


ArrayList<cable> cables = new ArrayList<cable>();
cable constructionCable;


// miscellanous
// This Variable defined which part of the year it is. It ranges from -1 for winter to 1 for summer on the nothern hemisphere.
//final float season = 1;
//final float EARTH_TILT = radians(23.43693);
final int sunDist = 1300;
public PShape earth, sun;
String dataFolderPath;
PImage bg;
float rot;
boolean constructing = false;

void setup() {
  size(1870, 1030, P3D);
  // Creating/loading textures of the sun and the earth.
  bg = loadImage("stars.png");
  background(bg);
  earth = createShape(SPHERE, earthRadius);
  earth.setStroke(false);
  earth.setTexture(loadImage("blurredEarth2.jpg"));
  sun = createShape(SPHERE, 500);
  sun.setStroke(false);
  sun.setTexture(loadImage("sun.jpg"));

  // Defines the path of the specified data Folder.
  dataFolderPath = dataPath("").substring(0, dataPath("").length() - 4) + dataFolder + "\\";

  // Loads all the cables.
  cables = loadCables(startIndex, endIndex);

  textAlign(RIGHT, TOP);
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
      "To remove the last set vertex, press BACKSPACE or DELETE.\n" +
      "To move around the cable Vertex by one degree(geographic coordinates), use the arrow keys.\n" +
      "To move around the cable Vertex by ten degrees(geographic coordinates), use 'WASD'.\n" +
      "To alter the cable thickness(stroke), press any number between 0 and 9(radius in pixels).\n" +
      "To escape the construction mode and therewith set and save the cable, press 'c'.", width, 0);
    text("If you mean to connect two cables, those need to have two vertices with equal coordinates. All the vertices are being visualized with little spheres.", width/2 + 300, 10);
    text("Also, it is impossible to connect several cables to one vertex.", width/2 + 100, 25);
  } else text("To start the construction mode, press 'c'.", width-20, 5);


  // The following part shapes the earth and the sun, applying all the necessary features.

  translate(width/2, height/2);
  rotateY(-HALF_PI);
  translate(0, 0, -sunDist);
  shape(sun);
  translate(0, 0, -3700);
  translate(0, 0, 5000);
  ambientLight(40, 40, 40);
  directionalLight(255, 255, 255, 0, 0, 1);
  rotateY(HALF_PI);
  if (constructing) {
    rotateX(-radians(constructionCable.lat));
    rotateY(HALF_PI-radians(constructionCable.lon));
    ambientLight(100, 100, 80);

    // Displays all the set and current cableVertices in contruction mode.
    // (02.06.18) + all the other vertices 
    for (cable.cableVertex cvCur : constructionCable.cvarr) {
      cvCur.displayNob(5);
    }
    constructionCable.displayCableVertex(constructionCable.cvTemp, color(255, 150, 150));
    //println(constructionCable.cvTemp.x, constructionCable.cvTemp.y, constructionCable.cvTemp.z, constructionCable.cvTemp.lat, constructionCable.cvTemp.lon);
    for (cable c : cables) {
      for (cable.cableVertex cv : c.cvarr) {
        cv.displayNob(3);
      }
    }
    
  } else {
    //rotateZ(season * EARTH_TILT);
    rotateY(rot);
    rot += rotSpeed;
  }

  // Displays all the newly constructed and all the xyzFile cables.
  for (cable cabCur : cables) {
    cabCur.display();
  }
  for (cable c : cables) {
    c.luminousFlux = 0;
  }




  shape(earth);

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
}


// The keyPressed() part is needed for the control of the construction mode. For further information, see the top right corner of the simulation in construction mode.

void keyPressed() {
  if (key == 'c') {
    constructing = !constructing;
    if (constructing) {
      println("cable construction mode enabled");
      try {
        int pLat = constructionCable.lat;
        int pLon = constructionCable.lon;
        constructionCable = new cable(pLat, pLon);
      }
      catch(Exception e) {
        constructionCable = new cable();
      }
    } else {
      println("cable construction mode disabled");
      if (constructionCable.cvarr.size()>=2) {
        constructionCable.sort();
        cables.add(constructionCable);
        constructionCable.connect(cables);
        constructionCable.save();
      }
    }
  }
  if (constructing) {
    if (keyCode == ENTER)constructionCable.setCableVertex("n");
    else if (key == 'l')constructionCable.setCableVertex("l");
    else if (key == 'k')constructionCable.setCableVertex("c");
    else if (keyCode == BACKSPACE || keyCode == DELETE)constructionCable.deleteLastCableVertex();
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



int[] searchCables(int lat, int lon, ArrayList<cable> cableArray) {
  for (int i = 0; i < cableArray.size()-1; i++) {
    for (int j = 0; j < cableArray.get(i).cvarr.size(); j++) {
      if (cableArray.get(i).cvarr.get(j).lat == lat && cableArray.get(i).cvarr.get(j).lon == lon)return new int[]{i, j};
    }
  }
  return null;
}
