import processing.opengl.*;
import igeo.*;

public static class config{
  static int nPrey = 50;
  static int nPred = 5;
  static int nSymb = 20;
  static IBounds boundBox = new IBounds(0,0,0,150,150,20);
}

void setup(){
  size(480, 360, IG.GL);
  IG.duration(500);
  IG.bg(0);
  for(int i=0; i < config.nPrey; i++){
    MyBoid prey = new MyBoid(IRand.pt(100,100,20), 
               IRand.pt(-5,-5,0,20,20,0),1);
    //IVec p = new IVec((double)2*i,(double)0,(double)(Math.random()*(20)));
    //IVec v = new IVec(0,10,0);
    //MyBoid prey = new MyBoid(p,v,1);
    prey.clr(0,255,0,0.5).size(3);
  }
  for(int i=0; i < config.nPred; i++){
    MyBoid pred = new MyBoid(IRand.pt(100,100,20), 
               IRand.pt(-5,-5,0,20,20,0),2);
    //IVec p = new IVec((double)20*i,(double)0,(double)(Math.random()*(20)));
    //IVec v = new IVec(0,5,0);
    //MyBoid pred = new MyBoid(p,v,2);
    pred.clr(255,0,0,0.5).size(10);
  }
  for(int i=0; i < config.nSymb; i++){
    MyBoid symb = new MyBoid(IRand.pt(100,100,20), 
               IRand.pt(-5,-5,0,20,20,0),3);
    //IVec p = new IVec((double)5*i,(double)0,(double)(Math.random()*(20)));
    //IVec v = new IVec(0,5,0);
    //MyBoid symb = new MyBoid(p,v,3);
    symb.clr(0,0,255,0.5).size(6);
  }
}



class MyBoid extends IParticle{
  int ty;
  IVec prevPos;

  MyBoid(IVec p, IVec v, int ty){
    super(p,v); 
    this.ty = ty;
    
  }
  
  private ArrayList< IDynamics > getAgents(ArrayList< IDynamics > allAgents,int n){
    ArrayList< IDynamics > returnAgents = new ArrayList();
    if (n == 1){
      for (int i=0; i < config.nPrey; i++){
        returnAgents.add(allAgents.get(i));
      }
    }else if (n == 2){
      for (int i=config.nPrey; i < config.nPrey+config.nPred; i++){
        returnAgents.add(allAgents.get(i));
      }
    }else if(n == 3){
      for (int i=config.nPrey; i < config.nPrey+config.nPred+config.nSymb; i++){
        returnAgents.add(allAgents.get(i));
      }
    }
    return returnAgents;
  }
  
  
  void cohere(ArrayList agents1,ArrayList agents2,double cd,double cr){
    IVec center = new IVec(); //zero vector
    int count = 0;
    boolean flag = false;
    for (int i=0; i < agents1.size(); i++){
      if(agents1.get(i) == this){
        flag = true;
        break;
      }
    }
    if (flag){
      for(int i=0; i < agents2.size(); i++){
        if(agents2.get(i) instanceof MyBoid && agents2.get(i)!=this){
          MyBoid b = (MyBoid)agents2.get(i);
          if(b.pos().dist(pos()) < cd){
            center.add(b.pos());
            count++;
          }
        }
      }
    }

    if(count > 0){
      
      push(center.div(count).sub(pos()).mul(cr));
    }    
  }

  void separate(ArrayList agents1,ArrayList agents2,double sd,double sr){
    IVec separationForce = new IVec(); //zero vector
    int count = 0;
    boolean flag = false;
    for (int i=0; i < agents1.size(); i++){
      if(agents1.get(i) == this){
        flag = true;
        break;
      }
    }
    if(flag){
      for(int i=0; i < agents2.size(); i++){
        if(agents2.get(i) instanceof MyBoid && agents2.get(i)!=this){
          MyBoid b = (MyBoid)agents2.get(i);
          double dist = b.pos().dist(pos());
          if(dist < sd && dist!=0 ){
            separationForce.add(pos().dif(b.pos()).len(sd - dist));
            count++;
          }
        }
      }
    }

    if(count > 0){
      
      push(separationForce.mul(sr/count));
    }
  }

  void align(ArrayList agents1,ArrayList agents2,double ad,double ar){
    IVec averageVelocity = new IVec(); //zero vector
    int count = 0;
    boolean flag = false;
    for (int i=0; i < agents1.size(); i++){
      if(agents1.get(i) == this){
        flag = true;
        break;
      }
    }
    if(flag){
      for(int i=0; i < agents2.size(); i++){
        if(agents2.get(i) instanceof MyBoid && agents2.get(i) != this){
          MyBoid b = (MyBoid)agents2.get(i);
          if(b.pos().dist(pos()) < ad){
            averageVelocity.add(b.vel());
            count++;
          }
        }
      }
    }
    
          
    
    
    
    if(count > 0){
      
      push(averageVelocity.div(count).sub(vel()).mul(ar));
    }
  }
  
  void interact(ArrayList< IDynamics > agents){
    ArrayList preyAgents = getAgents(agents,1);
    ArrayList predAgents = getAgents(agents,2);
    ArrayList symbAgents = getAgents(agents,3);
    
    cohere(preyAgents,preyAgents,15,1);
    separate(preyAgents,preyAgents,10,3);
    align(preyAgents,preyAgents,4,2);
    
    cohere(predAgents,predAgents,80,3);
    separate(predAgents,predAgents,60,10);
    align(predAgents,predAgents,80,2);
    
    //cohere(symbAgents,symbAgents,20,5);
    separate(symbAgents,symbAgents,15,5);
    //align(symbAgents,symbAgents,15,5);
    
    cohere(symbAgents,predAgents,10,10);
    separate(symbAgents,predAgents,5,10);
    align(symbAgents,predAgents,8,10);
    
    cohere(predAgents,preyAgents,20,3);
    separate(preyAgents,predAgents,10,3);
    //align(predAgents,preyAgents,10,2);
    
    separate(predAgents,preyAgents,5,10);
    separate(predAgents,preyAgents,5,10);
    
    
    int xFlip = 1;
      int yFlip = 1;
      int zFlip = 1;
      if (this.pos().x > config.boundBox.maxX() || this.pos().x < config.boundBox.minX()){
        xFlip = -1;
      }
      if (this.pos().y > config.boundBox.maxY() || this.pos().y < config.boundBox.minY()){
        yFlip = -1;
      }
      if (this.pos().z > config.boundBox.maxZ() || this.pos().z < config.boundBox.minZ()){
        zFlip = -1;
      }
      IVec vFlip = new IVec();
      vFlip.x = this.vel().x*xFlip;
      vFlip.y = this.vel().y*yFlip;
      vFlip.z = this.vel().z*zFlip;
      this.velocity(vFlip);
    
  }

  void update(){ //drawing line
    //IVec curPos = pos().cp();
    //if(prevPos!=null){ IG.crv(prevPos, curPos).clr(clr()); }
    //prevPos = curPos;
    
    if(time()%20 == 0){
      new Anchor(pos().cp(),this.ty);
    }
  }
}

class Anchor extends IAgent{
  IVec pos;
  IPoint point;
  int type;
  int count;
  Anchor(IVec p,int aty){
    pos = p;
    type = aty;
    point = new IPoint(pos).clr(1.0,0,0,0.5).size(2);
    count = 0;
  }
  
  void interact(ArrayList < IDynamics > agents){
    if(time()==0){ // only when the first time
      for(int i=0; i < agents.size(); i++){
        if(agents.get(i) instanceof Anchor){
          Anchor a = (Anchor)agents.get(i);
          if(a!=this && a.time() > 0){ // exclude anchors just created
            if(a.pos.dist(pos) < 10 && a.pos.dist(pos) > 0){
              int ty1 = this.type;
              int ty2 = a.type;
              if (ty1 == 3){
                ty1 = 2;
              }else if (ty1 ==2){
                ty1 =3;
              }
              if (ty2 == 3){
                ty2 = 2;
              }else if (ty2 ==2){
                ty2 =3;
              }
              float hHSB = (6-ty1-ty2)*0.25;
              if (a.count < 8){ //max curves per knot
                new ICurve(a.pos, pos).hsb(hHSB,60,100,0.3);
                //new ICurve(a.pos, pos).clr(255,0.1);
                a.count ++;
                this.count ++;
              }
              
              //IG.meshRoundStick(a.pos, pos,0.2).clr(1.0,0.1);
            }
          }
        }
      }
      /*
      if(this.count>1){
        new IBox(pos,(double)this.count);
      }
      */
    }
  }
  void update(){
    if(time()==80){ // delete after ? time frame
      point.del();
      del();
      
    }
  }
}
