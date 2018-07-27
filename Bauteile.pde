
/******************************************************************************************************************************
 
 In this file all the building parts are defined as classes, along with corresponding methods and variables.
 Those contain: - cables with cableVertices
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
    int[] pointer = null;

    cableVertex(int latitude, int longitude) {
      this.lat = latitude;
      this.lon = longitude;
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
        this.l = new lamp(round(-degrees(asin(y/earthRadius))), round(degrees(atan2(z, -x))));
      } else if (state.equals("c"))this.c = new collector(round(-degrees(asin(this.y/earthRadius))), round(degrees(atan2(this.z, -this.x))));
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

    void displayNob(int radius) {
      pushMatrix();
      translate(this.x, this.y, this.z);
      noStroke();
      fill(255);
      sphere(radius);
      popMatrix();
    }
  }

  ArrayList<cableVertex> cvarr;
  int weight;
  int luminousFlux;
  int numOfLamps;

  // For construction
  int lat, lon;
  cableVertex cvTemp = new cableVertex(this.lat, this.lon);

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

  cable(int latitude, int longitude) {
    this.cvarr = new ArrayList<cableVertex>();
    this.weight = 5;
    this.lat = latitude;
    this.lon = longitude;
    this.cvTemp = new cableVertex(this.lat, this.lon);
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

  /* REMOVED 27.05.18
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
   return true;
   }
   catch(Exception e) {
   println("Error while trying to read a cable xyz file " + fileStr + ": " + e);
   return false;
   }
   }*/

  void addCableVertex(int lat, int lon, String state) {
    this.cvarr.add(new cableVertex(lat, lon, state));
    if (state.equals("l"))this.numOfLamps++;
  }

  void addCableVertex(cableVertex cv) {
    this.cvarr.add(cv);
    if (cv.state.equals("l"))this.numOfLamps++;
  }

  /* CHANGED 27.05.18
   void addCableVertex(float x, float y, float z, String state){
   this.cvarr.add(new cableVertex(x, y, z, state));
   if(state.equals("l"))this.numOfLamps++;
   }*/



  //construction {

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

  void deleteLastCableVertex() {
    this.cvarr.remove(this.cvarr.size() - 1);
    println("cableVertex removed");
  }

  void setCableVertex(String state) {
    cvTemp.setState(state);
    this.addCableVertex(this.cvTemp);
    cvTemp = new cableVertex(lat, lon);
    println("cableVertex set");
  }

  boolean crossingLon180() {
    for (int i = 1; i < this.cvarr.size(); i++) {
      if ((this.cvarr.get(i-1).lon < -90 && this.cvarr.get(i).lon > 90) || (this.cvarr.get(i).lon < -90 && this.cvarr.get(i-1).lon > 90))return true;
    }
    return false;
  }

  void sort() {
    if ((this.cvarr.get(this.cvarr.size()-1).lon > this.cvarr.get(0).lon) ^ crossingLon180()) {
      //reverse cvarr
      println("sort");
      ArrayList<cableVertex> temp = new ArrayList<cableVertex>(this.cvarr.size());
      for (int i = 0; i < this.cvarr.size(); i++) {
        temp.add(this.cvarr.get(this.cvarr.size()-i-1));
      }
      this.cvarr = temp;
    }
  }

  void save() {
    try {
      //File file = new File(filePath + "cableNmb.txt");
      File file = new File(dataFolderPath + "cableNmb.txt");
      Scanner scanner = new Scanner(file);
      int cableNmb = scanner.nextInt();
      scanner.close();
      Formatter formatterForNmb = new Formatter(file);
      formatterForNmb.format("%s", cableNmb+1);
      formatterForNmb.close();

      //Formatter formatter = new Formatter(filePath + "cable[" + cableNmb + "].txt");
      Formatter formatter = new Formatter(dataFolderPath + "cable[" + cableNmb + "].txt");
      formatter.format("%s", this.weight);
      for (cableVertex cvCur : this.cvarr) {
        formatter.format("%s %s %s", "\r\n" + cvCur.lat, cvCur.lon, cvCur.state);
      }
      formatter.close();
    }
    catch(Exception e) {
      try {
        File f = new File(dataFolderPath + "cableNmb.txt");
        f.getParentFile().mkdirs();
        f.createNewFile();
        Formatter formatterForNmb = new Formatter(f);
        formatterForNmb.format("%s", 0);
        formatterForNmb.close();
        this.save();
      }
      catch(Exception e_) {
        println("Error while trying to save the current cable: " + e + " and " + e_);
      }
    }
  }

  void connect(ArrayList<cable> cableArray) { //connection always happens after appension...
    for (int i = 0; i < this.cvarr.size(); i++) {
      int[] conCVIndex = searchCables(this.cvarr.get(i).lat, this.cvarr.get(i).lon, cableArray);
      if (conCVIndex != null) {
        cableVertex conCV = cableArray.get(conCVIndex[0]).cvarr.get(conCVIndex[1]);
        if (i == 0 || i == (this.cvarr.size()-1))conCV.pointer = new int[]{cableArray.size()-1, i};
        else if (conCVIndex[1] == 0 || conCVIndex[1] == (cableArray.get(conCVIndex[0]).cvarr.size() - 1))this.cvarr.get(i).pointer = conCVIndex;
      }
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

  int numOfLampsOff, numOfLampsOn, numOfConnectedLampsOn;
  float maxFluxPerLamp = 0;

  void setMaxFluxPerLamp() {
    try {
      this.maxFluxPerLamp = this.luminousFlux/(this.numOfLampsOn + this.numOfConnectedLampsOn);
    }
    catch (ArithmeticException e) {
    }
  }

  void display() {
    this.numOfLampsOn = this.numOfLamps - this.numOfLampsOff;
    this.numOfLampsOff = 0;
    this.numOfConnectedLampsOn = 0;
    pushMatrix();
    noFill();
    stroke(170);
    strokeWeight(this.weight);
    beginShape();
    for (cableVertex cv : this.cvarr) {
      //curveVertex(cv.x, cv.y, cv.z);
      vertex(cv.x, cv.y, cv.z);
    }
    endShape();
    strokeWeight(1);
    popMatrix();

    for (cableVertex cv : this.cvarr) {
      if (cv.pointer != null) {
        cable pointTo = cables.get(cv.pointer[0]);
        if (cv.pointer[1] == 0) {
          this.numOfConnectedLampsOn += pointTo.numOfLampsOn;
        }
      }
    }

    for (cableVertex cv : this.cvarr) {

      if (cv.state.equals("c")) {
        this.luminousFlux += cv.c.calcIlluminance() * cv.c.area;
        cv.c.display();
        this.setMaxFluxPerLamp();
      } else if (cv.state.equals("l")) {
        if (cv.l.calcIlluminance() < 300) {
          //turn on the lamp with brightness = maxFluxPerLamp / cv.l.numOfLanterns
          try {
            float brightness = constrain(this.maxFluxPerLamp / cv.l.numOfLanterns, 0, 255);
            cv.l.display(brightness);
            this.luminousFlux -= (brightness*cv.l.numOfLanterns);
          }
          catch(ArithmeticException e) {
          }
        } else numOfLampsOff++;
      }

      if (cv.pointer != null) {
        cable pointTo = cables.get(cv.pointer[0]);
        if (cv.pointer[1] == 0) {
          try {
            int ptFlux = (int) (this.maxFluxPerLamp * pointTo.numOfLampsOn);
            pointTo.luminousFlux = ptFlux;
            pointTo.setMaxFluxPerLamp();
            this.luminousFlux -= ptFlux;
          }
          catch(ArithmeticException e) {
          }
        } else {
          this.luminousFlux += pointTo.luminousFlux;
          this.setMaxFluxPerLamp();
        }
      }
    }
  }
}

// CHANGED 30.05.18
ArrayList<cable> loadCables(int start, int end) {
  ArrayList<cable> res = new ArrayList<cable>();
  for (int i = 0; i < end-start; i++) {
    res.add(new cable());
    res.get(i).fromFile(dataFolderPath + "cable[" + (start + i) + "].txt");
    res.get(i).connect(res);
  }
  return res;
}

class lamp {
  float x, y, z;
  int lat, lon;
  int numOfLanterns = 20000;

  lamp(int latitude, int longitude) {
    this.x = -(earthRadius + 5) * cos(radians(latitude)) * cos(radians(longitude));
    this.y = -(earthRadius + 5) * sin(radians(latitude));
    this.z = (earthRadius + 5) * cos(radians(latitude)) * sin(radians(longitude));
    this.lat = latitude;
    this.lon = longitude;
  }

  public void display(float brightness) {
    pushMatrix();
    translate(this.x, this.y, this.z);
    noStroke();
    fill(brightness/10);
    sphere(brightness/10);
    popMatrix();
  }

  int calcIlluminance() {
    float imX = -earthRadius * cos(radians(this.lat)) * cos(radians(this.lon)+rot+HALF_PI);
    float imY = -earthRadius * sin(radians(this.lat));
    float imZ = earthRadius * cos(radians(this.lat)) * sin(radians(this.lon)+rot+HALF_PI);

    float sunHeight = acos((pow(earthRadius, 2) + imX*imX + imY*imY + imZ*imZ + 2*imZ*sunDist) / (2*earthRadius*sqrt(imX*imX + imY*imY + pow(imZ+sunDist, 2)))) - HALF_PI;
    int illuminance;
    if (sunHeight > 0)illuminance = int(300 + 21000 * sin(sunHeight));
    else illuminance = 0;
    return illuminance;
  }
}

class collector {
  float x, y, z;
  int lat, lon;
  int area = 500;//m²

  collector(int latitude, int longitude) {
    this.lat = latitude;
    this.lon = longitude;
    this.x = -(earthRadius + 3) * cos(radians(latitude)) * cos(radians(longitude));
    this.y = -(earthRadius + 3) * sin(radians(latitude));
    this.z = (earthRadius + 3) * cos(radians(latitude)) * sin(radians(longitude));
  }

  void display() {
    pushMatrix();
    rectMode(CENTER);
    translate(this.x, this.y, this.z);
    rotateY(HALF_PI+radians(this.lon));
    rotateX(radians(-this.lat));
    noStroke();
    fill(255);
    rect(0, 0, 10, 10);
    popMatrix();
  }

  int calcIlluminance() {
    float imX = -earthRadius * cos(radians(this.lat)) * cos(radians(this.lon)+rot+HALF_PI);
    float imY = -earthRadius * sin(radians(this.lat));
    float imZ = earthRadius * cos(radians(this.lat)) * sin(radians(this.lon)+rot+HALF_PI);

    float sunHeight = acos((pow(earthRadius, 2) + imX*imX + imY*imY + imZ*imZ + 2*imZ*sunDist) / (2*earthRadius*sqrt(imX*imX + imY*imY + pow(imZ+sunDist, 2)))) - HALF_PI;
    int illuminance;
    if (sunHeight > 0)illuminance = int(300 + 21000 * sin(sunHeight));//lx
    else illuminance = 0;
    return illuminance;
  }
}