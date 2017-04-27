import igeo.*;
import processing.opengl.*;

public static class config{
  //variable
  static int growthDuration = 800;
  static int growthInterval = 10;
  static int divisionInterval = 50;
  static double maxRadius = 5;
  static double growthSpeed = 0.1;
  static int deadNeighborCount = 6;
  static int originCellCount = 0;
  //constant
  static int fileNum = 0;
  static int[] loopCount;
  static int cellCount = 0;
  static double[] startPushTime;
  static boolean combined = false;
  static int allLoopCount = 0;
  static IText lcText;
}

void setup(){
  size(1920,1080,IG.GL);
  IG.top();
  IG.bg(255);
  IConfig.syncDrawAndDynamics=true;
  config.loopCount = new int[10];
  config.startPushTime = new double[10];
  new Cell(new IVec(-25,25,0), 5,0).clr(0,0,1.0);
  new Cell(new IVec(25,25,0), 5,10).clr(0,0,1.0);    //originCellCount
  new Cell(new IVec(-25,-25,0), 5,20).clr(0,0,1.0);
  new Cell(new IVec(25,-25,0), 5,30).clr(0,0,1.0);
  
  
  
  IVec attVec = new IVec(0,0,0);
  IVec attVec2 = new IVec(0,30,0);
  new MyAttractor(attVec,15.0);
  new MyAttractor(attVec2,10.0);
  
  new IPoint(0,80,0).clr( 0, 0, 0,0 );
  new IPoint(0,-80,0).clr( 0, 0, 0,0 );
  IG.focus();  
  
}


void draw(){
  //saveFrame("screen-####.jpg");
}



