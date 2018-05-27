
/******************************************************************************************************************************
 
 In this file all the building parts are defined as classes, along with corresponding methods and variables.
 Those contain: - cables with cableVertexies
 - lamps
 - collectors    
 
 ******************************************************************************************************************************/




import java.util.Scanner;
import java.util.Arrays;
import java.util.Formatter;

class cable {

  class cableVertex {

    float x, y, z;
    int lat, lon;
    String state;
    lamp l;
    collector c;
    cable pointer = null;

    cableVertex(float latitude, float longitude) {
      this.x = -earthRadius * cos(radians(latitude)) * cos(radians(longitude));
      this.y = -earthRadius * sin(radians(latitude));
      this.z = earthRadius * cos(radians(latitude)) * sin(radians(longitude));
    }
    
    cableVertex(int latitude, int longitude, String state) {
      this.lat = latitude;
      this.lon = longitude;
      this.x = -earthRadius * cos(radians(latitude)) * cos(radians(longitude));
      this.y = -earthRadius * sin(radians(latitude));
      this.z = earthRadius * cos(radians(latitude)) * sin(radians(longitude));
      this.setState(state);
    }

    /*cableVertex(float x, float y, float z, String state) {
      this.x = x;
      this.y = y;
      this.z = z;
      this.state = state;
      //for debugging:
      //println(state);
      this.setState(state);
    }*/

    void setCoordinates(int latitude, int longitude) {
      this.lat = latitude;
      this.lon = longitude;
      this.x = -earthRadius * cos(radians(latitude)) * cos(radians(longitude));
      this.y = -earthRadius * sin(radians(latitude));
      this.z = earthRadius * cos(radians(latitude)) * sin(radians(longitude));
    }

    void setState(String state) {
      this.state = state;
      if (state.equals("l")) {
        this.l = new lamp(-degrees(asin(y/earthRadius)), degrees(atan2(z, -x)));
      } else if (state.equals("c"))this.c = new collector(-degrees(asin(this.y/earthRadius)), degrees(atan2(this.z, -this.x)));
      else state = "n";
    }

    /*  In earlier versions, this function handled the displaying of the cableVertex' attached lamp or collector.
     In the current version, this process is more complex and has to be handled via the display functions of the corresponding attached building part.
     
     void display() {
       if (this.state != null) {
         if (this.state.equals("l"))this.l.display();
         else if (this.state.equals("c"))this.c.display();
       }
     }
     
     */

    void displayNob() {
      pushMatrix();
      translate(this.x, this.y, this.z);
      noStroke();
      fill(255);
      sphere(5);
      popMatrix();
    }
  }

  ArrayList<cableVertex> cvarr;
  int weight;
  int luminousFlux;
  int numOfLamps;

  /*  These constructors are currently not of any use...
  
  cable(cableVertex[] cvarr, int weight) {
    this.cvarr = new ArrayList<cableVertex>(Arrays.asList(cvarr));
    this.weight = weight;
  }

  cable(int weight) {
    this.cvarr = new ArrayList<cableVertex>();
    this.weight = weight;
  }
  
  */

  cable() {
    this.cvarr = new ArrayList<cableVertex>();
    this.weight = 5;
  }

  boolean fromFile(String fileStr) {
    try {
      File file = new File(fileStr);
      Scanner scanner = new Scanner(file);
      this.cvarr = new ArrayList<cableVertex>();
      this.weight = int(scanner.next());
      while (scanner.hasNextLine()) {
        this.addCableVertex(int(scanner.next()), int(scanner.next()), scanner.next());
      }
      scanner.close();
      return true;
    }
    catch(Exception e) {
      println("Error while trying to read a cable coordinates file: " + fileStr + ": " + e);
      return false;
    }
  }

  /* CHANGED 27.05.18
  boolean xyzFromFile(String fileStr) {
    try {
      File file = new File(fileStr);
      Scanner scanner = new Scanner(file);
      this.cvarr = new ArrayList<cableVertex>();
      this.weight = int(scanner.next());
      while (scanner.hasNextLine()) {
        this.addCableVertex(float(scanner.next()), float(scanner.next()), float(scanner.next()), scanner.next());
      }
      scanner.close();
      //for debugging:
      //println(this.cvarr.get(1).l.x + " state...");
      return true;
    }
    catch(Exception e) {
      println("Error while trying to read a cable xyz file " + fileStr + ": " + e);
      return false;
    }
  }*/

  void addCableVertex(int lat, int lon, String state) {
    this.cvarr.add(new cableVertex(lat, lon, state));
  }

  void addCableVertex(cableVertex cv) {
    this.cvarr.add(cv);
  }
  
  /* CHANGED 27.05.18
  void addCableVertex(float x, float y, float z, String state){
    this.cvarr.add(new cableVertex(x, y, z, state));
    if(state.equals("l"))this.numOfLamps++;
  }*/

  //construction {

  int lat, lon = 0;
  cableVertex cvTemp = new cableVertex(lat, lon);

  void right() {
    this.lon++;
    this.lon = ((this.lon + 540) % 360) - 180;
    this.cvTemp.setCoordinates(lat, lon);
  }

  void left() {
    this.lon--;
    this.lon = ((this.lon + 540) % 360) - 180;
    this.cvTemp.setCoordinates(lat, lon);
  }

  void up() {
    if (this.lat < 90)this.lat++;
    //if(this.lat == 91)this.lat = 89;
    this.cvTemp.setCoordinates(lat, lon);
  }

  void down() {
    if (this.lat > -90)this.lat--;
    //if(this.lat == -91)this.lat = -89;
    this.cvTemp.setCoordinates(lat, lon);
  }

  void setCableVertex(String state) {
    cvTemp.setState(state);
    this.addCableVertex(this.cvTemp);
    cvTemp = new cableVertex(lat, lon);
    println("cableVertex set");
  }

  void save() {
    try {
      //File file = new File(filePath + "cableNmb.txt");
      File file = new File(dataPath("cableNmb.txt"));
      Scanner scanner = new Scanner(file);
      int cableNmb = scanner.nextInt();
      scanner.close();
      Formatter formatterForNmb = new Formatter(file);
      formatterForNmb.format("%s", cableNmb+1);
      formatterForNmb.close();

      //Formatter formatter = new Formatter(filePath + "cable[" + cableNmb + "].txt");
      Formatter formatter = new Formatter(dataPath("cable[" + cableNmb + "].txt"));
      formatter.format("%s", this.weight);
      for (cableVertex cvCur : this.cvarr) {
        formatter.format("%s %s %s", "\r\n" + cvCur.lat, cvCur.lon, cvCur.state);
      }
      formatter.close();
    }
    catch(Exception e) {
      println("Error while trying to save the current cable: " + e);
    }
  }
  
  //}

  void displayCableVertex(cableVertex cv, color colour) {
    pushMatrix();
    translate(cv.x, cv.y, cv.z);
    noStroke();
    fill(colour);
    sphere(5);
    popMatrix();
  }

float numOfLampsOff, numOfLampsOn;

  void display() {
    this.numOfLampsOn = this.numOfLamps - this.numOfLampsOff;
    this.numOfLampsOff = 0;
    pushMatrix();
    noFill();
    stroke(255);
    strokeWeight(this.weight);
    //println(this.weight);
    this.luminousFlux = 0;
    beginShape();
    for (cableVertex cv : this.cvarr) {
      //curveVertex(cv.x, cv.y, cv.z);
      vertex(cv.x, cv.y, cv.z);
    }
    endShape();
    strokeWeight(1);
    popMatrix();
    float maxFluxPerLamp = 0;
    for (cableVertex cv : this.cvarr) {
      if (cv.state.equals("c")) {
        this.luminousFlux += cv.c.calcIlluminance() * cv.c.area;
        cv.c.display();
        println(this.luminousFlux);
        //WHAT IF THERE ARE NO LAMPS?↓
        maxFluxPerLamp = this.luminousFlux/this.numOfLampsOn;
      } else if (cv.state.equals("l")) {
        if(cv.l.calcIlluminance() < 300)//turn on the lamp with brightness = maxFluxPerLamp / cv.l.numOfLanterns
        cv.l.display(constrain(maxFluxPerLamp/cv.l.numOfLanterns, 0, 255));
        else numOfLampsOff++;
        //this.luminousFlux -= cv.l.numOfLanterns * 370.4/*lm per lantern (= 9.625 lx * (7/2)²π m²)*/;
      }
    }
  }
}

// CHANGED 27.05.18
ArrayList<cable> loadCables(int start, int end) {
  ArrayList<cable> res = new ArrayList<cable>();
  for (int i = 0; i < end-start; i++) {
    res.add(new cable());
    //res.get(i).fromFile(filePath + "cable[" + (start + i) + "].txt");
    res.get(i).fromFile(dataPath("cable[" + (start + i) + "].txt"));
    //for debugging
    /*for(cable c : res){
     println("x: " + c.cvarr.get(0).l.x + "\ny: " + c.cvarr.get(0).l.y + "\nz: " + c.cvarr.get(0).l.z);
     }*/
  }
  return res;
}

class lamp {
  float x, y, z, lat, lon;
  int numOfLanterns = 20000;

  lamp(float latitude, float longitude) {
    this.x = -(earthRadius + 5) * cos(radians(latitude)) * cos(radians(longitude));
    this.y = -(earthRadius + 5) * sin(radians(latitude));
    this.z = (earthRadius + 5) * cos(radians(latitude)) * sin(radians(longitude));
    this.lat = latitude;
    this.lon = longitude;
  }

  public void display(float brightness) {
    //pushMatrix();
    /*rotateZ(this.latitude);
     rotateY(-this.longitude);*/
    /*translate(this.x, this.y, this.z);
    noStroke();
    fill(brightness);
    sphere(brightness);
    popMatrix();*/
    //println("bri:" + brightness);
    pointLight(brightness, brightness, brightness, this.x, this.y, this.z);
  }

  int calcIlluminance() {
    // TO BE GENERALIZED
    float x = -earthRadius * cos(radians(this.lat)) * cos(radians(this.lon)+rot+HALF_PI);
    float y = -earthRadius * sin(radians(this.lat));
    float z = earthRadius * cos(radians(this.lat)) * sin(radians(this.lon)+rot+HALF_PI);

    float sunHeight = acos((pow(earthRadius, 2) + x*x + y*y + z*z + 2*z*sunDist) / (2*earthRadius*sqrt(x*x + y*y + pow(z+sunDist, 2)))) - HALF_PI;
    int illuminance;
    if (sunHeight > 0)illuminance = int(300 + 21000 * sin(sunHeight));
    else illuminance = 0;
    //println(degrees(sunHeight)); 
    //println(illuminance);
    return illuminance;
  }
}

class collector {
  float x, y, z, lat, lon;
  int area = 500;//m²

  collector(float latitude, float longitude) {
    this.lat = radians(latitude);
    this.lon = radians(longitude);
    this.x = -(earthRadius + 3) * cos(radians(latitude)) * cos(radians(longitude));
    this.y = -(earthRadius + 3) * sin(radians(latitude));
    this.z = (earthRadius + 3) * cos(radians(latitude)) * sin(radians(longitude));
  }

  void display() {
    pushMatrix();
    rectMode(CENTER);
    translate(this.x, this.y, this.z);
    rotateY(HALF_PI+this.lon);
    rotateX(-this.lat);
    noStroke();
    fill(255);
    rect(0, 0, 10, 10);
    popMatrix();
  }

  int calcIlluminance() {
    // TO BE GENERALIZED
    float x = -earthRadius * cos(radians(this.lat)) * cos(radians(this.lon)+rot+HALF_PI);
    float y = -earthRadius * sin(radians(this.lat));
    float z = earthRadius * cos(radians(this.lat)) * sin(radians(this.lon)+rot+HALF_PI);

    float sunHeight = acos((pow(earthRadius, 2) + x*x + y*y + z*z + 2*z*sunDist) / (2*earthRadius*sqrt(x*x + y*y + pow(z+sunDist, 2)))) - HALF_PI;
    int illuminance;
    if (sunHeight > 0)illuminance = int(300 + 21000 * sin(sunHeight));//lx
    else illuminance = 0;
    //println(degrees(sunHeight)); 
    return illuminance;
  }
}



//https://vvvv.org/blog/polar-spherical-and-geographic-coordinates