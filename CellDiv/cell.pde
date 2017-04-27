class Cell extends IParticle{
  int growthDuration = config.growthDuration;
  int growthInterval = config.growthInterval;
  int divisionInterval = config.divisionInterval;
  double maxRadius = config.maxRadius;
  double growthSpeed = config.growthSpeed;
  IColor cHSB;
  
  ArrayList< CellLink > links; //store links
  double radius;
  ICircle circle;
  boolean active = false;
  boolean live = true;
  int groupNum;
  //Attractor
  MyAttractor attractor = null;
  double minDist = -1;
  
  Cell(IVec pos, double rad, int gnum){
    super(pos, new IVec(0,0,0));
    radius = rad;
    links = new ArrayList< CellLink >();
    fric(0.1);
    groupNum = gnum;
  }
  
  
  int[] getAdDead(Cell[] agents1,Cell[] agents2){//return adjacent dead cells
  
    ArrayList< Cell > deadCells1 = new ArrayList();
    ArrayList<Integer> deadCellSort1 = new ArrayList<Integer>();
    ArrayList< Cell > deadCells2 = new ArrayList();
    ArrayList<Integer> deadCellSort2 = new ArrayList<Integer>();
    int[] returnDead;
    returnDead = new int[2];
    int realAgentsLength1 = 0;
    int realAgentsLength2 = 0;
    for(int i = 0; i<agents1.length; i++){
      if(agents1[i] != null){
        if(!agents1[i].live){
          deadCells1.add(agents1[i]);
          deadCellSort1.add(i);
        }
        realAgentsLength1 ++;
      }
    }
    for(int i = 0; i<agents2.length; i++){
      if(agents2[i] != null){
        if(!agents2[i].live){
          deadCells2.add(agents2[i]);
          deadCellSort2.add(i);
        }
        realAgentsLength2 ++;
      }
    }
    
    if(deadCells1.size() > 2 && deadCells2.size() > 2){
      lableA:
      for(int i = 0; i < deadCells1.size();i ++){
        for(int j = 0; j < deadCells2.size();j ++){
          if(deadCells1.get(i).clr().eq(0,0,1.0) || deadCells2.get(j).clr().eq(0,0,1.0)){continue;}
          if(deadCells1.get(i) != deadCells2.get(j)){
            double deadDist = deadCells1.get(i).pos().dist(deadCells2.get(j).pos());
            if(agents1[0] == agents2[0]){
              if(deadDist<(deadCells1.get(i).radius+deadCells2.get(j).radius)*1.8){//separate
                int deadInterval = min(abs(deadCellSort1.get(i)-deadCellSort1.get(j)),realAgentsLength1-abs(deadCellSort1.get(i)-deadCellSort1.get(j)));
                if(deadInterval>0.3*realAgentsLength1){
                  returnDead[0] = min(deadCellSort1.get(i),deadCellSort1.get(j));
                  returnDead[1] = max(deadCellSort1.get(i),deadCellSort1.get(j));
                  break lableA;
                }
              }
            }else{
              if(deadDist<(deadCells1.get(i).radius+deadCells2.get(j).radius)*1.1){
                returnDead[0] = deadCellSort1.get(i);
                returnDead[1] = deadCellSort2.get(j);
                break lableA;
              }
              
            }
          }
        }
      }
    }
    return returnDead;
  }
  
  
  
  void pushGroups(Cell[] g1,Cell[] g2,int f){
    IVec g1Center = new IVec(0,0,0);
    IVec g2Center = new IVec(0,0,0);
    int a = 0;//g1 length
    int b = 0;//g2 length
    for (int i = 0; i < g1.length; i ++){
      if(g1[i] != null){
        g1Center.add(g1[i].pos);
        a++;
      }else{break;}
    }
    for (int i = 0; i < g1.length; i ++){
      if(g2[i] != null){
        g2Center.add(g2[i].pos);
        b++;
      }else{break;}
    }
    Cell[] group1 = new Cell[a];
    Cell[] group2 = new Cell[b];
    System.arraycopy(g1, 0, group1, 0, a); 
    System.arraycopy(g2, 0, group2, 0, b); 
    g1Center.div(a);
    g2Center.div(b);
    //IVec dif = g1Center.dif(g2Center).len(f);
    if(g1Center.len()>g2Center.len()){
      IVec dif = g2Center.len(f);
      for (int i = 0; i < group2.length; i ++){group2[i].pull(dif);}
    }else{
      IVec dif = g1Center.len(f);
      for (int i = 0; i < group1.length; i ++){group1[i].pull(dif);}
    }
    
    //for (int i = 0; i < group1.length; i ++){group1[i].push(dif);}
    //for (int i = 0; i < group2.length; i ++){group2[i].pull(dif);}
  }
  
  
  void breakCombine(ArrayList< Cell > allCells,Cell[][] hierarchy){
    boolean startCombine = true;
    for (int o = 0; o < config.originCellCount; o ++){
      if(config.loopCount[o] == 1){startCombine = false;}
      int jParentNum = 0;
      if(config.combined == false){
        for(int j = 0;j < config.loopCount[o];j ++){
          for(int i = 1;i < allCells.size();i ++){
            if (allCells.get(i).groupNum == o*10+1 && jParentNum==0){jParentNum=i;hierarchy[o*10+1][0] = allCells.get(i);}
            if (allCells.size()>10 && allCells.get(i).links.size() > 0){
              
              if(hierarchy[o*10+j][i-1] == null){println("last is null");println("o = ",o, "j= ",j,"i = ",i);break;}
              Cell op = hierarchy[o*10+j][i-1].links.get(0).oppositeCell(hierarchy[o*10+j][i-1]);
              if(i>1){
                if(op == hierarchy[o*10+j][i-2]){
                  op = hierarchy[o*10+j][i-1].links.get(1).oppositeCell(hierarchy[o*10+j][i-1]);
                }
                if(op == hierarchy[o*10+j][0]){//loop end
                  break;
                }
              }
              hierarchy[o*10+j][i] = op;
            }
          }
        }
      }
        
//repel loop
      if(config.loopCount[o]>1){
        //println("start pushing o=",o);
        if(config.startPushTime[o] == 0){
          config.startPushTime[o] = time();
          pushGroups(hierarchy[o*10],hierarchy[o*10+1],450);
        }else if(time() - config.startPushTime[o] <15){
          pushGroups(hierarchy[o*10],hierarchy[o*10+1],450);
        }else if(time() - config.startPushTime[o] <30){
          pushGroups(hierarchy[o*10],hierarchy[o*10+1],250);
        }
      }
        
        
//break loop
        if(allCells.size() > 50 && time()<700 && config.loopCount[o]<2 && config.combined == false){
          int adDead[] = new int[2];
          adDead = getAdDead(hierarchy[o*10],hierarchy[o*10]);
          if(adDead[0]!=0 && adDead[1]!=0){
            println("time:",time(),"loop break","o=",o);
            println(adDead[0],adDead[1]);
            for (int i = 0; i<2; i++){
              hierarchy[o*10][adDead[i]].links.get(1).del();
              hierarchy[o*10][adDead[i]].links.get(0).del();
              hierarchy[o*10][adDead[i]].circle.del();
              hierarchy[o*10][adDead[i]].del();
            }
            new CellLink(hierarchy[o*10][adDead[0]-1], hierarchy[o*10][adDead[1]+1]);
            new CellLink(hierarchy[o*10][adDead[0]+1], hierarchy[o*10][adDead[1]-1]);
            
            if(config.fileNum < 12){
              String fileName = Integer.toString(config.fileNum)+"separate.3dm";
              //IG.save(fileName);
              config.fileNum ++;
            }
            config.loopCount[o] ++;
            for (int i = min(adDead[0],adDead[1])+1;i<max(adDead[0],adDead[1]);i++){
              hierarchy[o*10][i].groupNum = o*10+1;
            }
            config.allLoopCount ++;
          }
        }
      }//o loop
          
          
          
//combine loop            
          
    if(allCells.size() > 50 && time()>750 && startCombine == true && config.combined == false){
      int adDead1[] = new int[2];
      int adDead2[] = new int[2];
      int adDead3[] = new int[2];
      int adDead4[] = new int[2];
      int adDead5[] = new int[2];
      adDead1 = getAdDead(hierarchy[20],hierarchy[21]);
      hierarchy[20][adDead1[0]-1].live = true;hierarchy[20][adDead1[0]+1].live = true;
      hierarchy[21][adDead1[1]-1].live = true;hierarchy[20][adDead1[1]+1].live = true;
      adDead2 = getAdDead(hierarchy[30],hierarchy[31]);
      hierarchy[30][adDead2[0]-1].live = true;hierarchy[30][adDead2[0]+1].live = true;
      hierarchy[31][adDead2[1]-1].live = true;hierarchy[31][adDead2[1]+1].live = true;
      adDead3 = getAdDead(hierarchy[0],hierarchy[20]);
      hierarchy[0][adDead3[0]-1].live = true;hierarchy[0][adDead3[0]+1].live = true;
      hierarchy[20][adDead3[1]-1].live = true;hierarchy[20][adDead3[1]+1].live = true;
      adDead4 = getAdDead(hierarchy[10],hierarchy[31]);
      hierarchy[10][adDead4[0]-1].live = true;hierarchy[10][adDead4[0]+1].live = true;
      hierarchy[31][adDead4[1]-1].live = true;hierarchy[31][adDead4[1]+1].live = true;
      adDead5 = getAdDead(hierarchy[20],hierarchy[30]);
      boolean flag = true;
      for (int i = 0; i < 2;i++){
        if(adDead1[i]==0 ||adDead2[i]==0 ||adDead3[i]==0 ||adDead4[i]==0 ||adDead5[i]==0){
          flag = false;
          IG.err("combine too early!");
        }
      }
      if(flag && config.combined == false){
        config.allLoopCount -= 5;
        Cell[] cellsToDelete = new Cell[10];
        cellsToDelete[0] = hierarchy[20][adDead1[0]];
        cellsToDelete[1] = hierarchy[21][adDead1[1]];
        cellsToDelete[2] = hierarchy[30][adDead2[0]];
        cellsToDelete[3] = hierarchy[31][adDead2[1]];
        cellsToDelete[4] = hierarchy[0][adDead3[0]];
        cellsToDelete[5] = hierarchy[20][adDead3[1]];
        cellsToDelete[6] = hierarchy[10][adDead4[0]];
        cellsToDelete[7] = hierarchy[31][adDead4[1]];
        cellsToDelete[8] = hierarchy[20][adDead5[0]];
        cellsToDelete[9] = hierarchy[30][adDead5[1]];
        for (int i = 0; i<2; i++){
          println(i);
//          hierarchy[20][adDead1[0]].links.get(0).del();
//          hierarchy[21][adDead1[1]].links.get(0).del();
//          hierarchy[30][adDead2[0]].links.get(0).del();
//          hierarchy[31][adDead2[1]].links.get(0).del();
//          hierarchy[0][adDead3[0]].links.get(0).del();
//          hierarchy[20][adDead3[1]].links.get(0).del();
//          hierarchy[10][adDead4[0]].links.get(0).del();
//          hierarchy[31][adDead4[1]].links.get(0).del();
//          hierarchy[20][adDead5[0]].links.get(0).del();
//          hierarchy[30][adDead5[1]].links.get(0).del();
            for (int j = 0;j<10;j++){
              if(true/*cellsToDelete[j].links.size() > 0*/){cellsToDelete[j].links.get(0).del();}
            }
        }
        for(int i = 0; i<10; i ++){
          cellsToDelete[i].circle.del();
          cellsToDelete[i].del();
        }
        
        
        
        if (hierarchy[20][adDead1[0]-1].pos().dist(hierarchy[21][adDead1[1]+1].pos()) < hierarchy[20][adDead1[0]-1].pos().dist(hierarchy[21][adDead1[1]-1].pos())){
          new CellLink(hierarchy[20][adDead1[0]-1], hierarchy[21][adDead1[1]+1]);
          new CellLink(hierarchy[20][adDead1[0]+1], hierarchy[21][adDead1[1]-1]);
        }else{
          new CellLink(hierarchy[20][adDead1[0]-1], hierarchy[21][adDead1[1]-1]);
          new CellLink(hierarchy[20][adDead1[0]+1], hierarchy[21][adDead1[1]+1]);
        }
        if (hierarchy[30][adDead2[0]-1].pos().dist(hierarchy[31][adDead2[1]+1].pos()) < hierarchy[30][adDead2[0]-1].pos().dist(hierarchy[31][adDead2[1]-1].pos())){
          new CellLink(hierarchy[30][adDead2[0]-1], hierarchy[31][adDead2[1]+1]);
          new CellLink(hierarchy[30][adDead2[0]+1], hierarchy[31][adDead2[1]-1]);
        }else{
          new CellLink(hierarchy[30][adDead2[0]-1], hierarchy[31][adDead2[1]-1]);
          new CellLink(hierarchy[30][adDead2[0]+1], hierarchy[31][adDead2[1]+1]);
        }
        if (hierarchy[0][adDead3[0]-1].pos().dist(hierarchy[20][adDead3[1]+1].pos()) < hierarchy[0][adDead3[0]-1].pos().dist(hierarchy[20][adDead3[1]-1].pos())){
          new CellLink(hierarchy[0][adDead3[0]-1], hierarchy[20][adDead3[1]+1]);
          new CellLink(hierarchy[0][adDead3[0]+1], hierarchy[20][adDead3[1]-1]);
        }else{
          new CellLink(hierarchy[0][adDead3[0]-1], hierarchy[20][adDead3[1]-1]);
          new CellLink(hierarchy[0][adDead3[0]+1], hierarchy[20][adDead3[1]+1]);
        }
        if (hierarchy[10][adDead4[0]-1].pos().dist(hierarchy[31][adDead4[1]+1].pos()) > hierarchy[10][adDead4[0]-1].pos().dist(hierarchy[31][adDead4[1]-1].pos())){
          new CellLink(hierarchy[10][adDead4[0]-1], hierarchy[31][adDead4[1]+1]);
          new CellLink(hierarchy[10][adDead4[0]+1], hierarchy[31][adDead4[1]-1]);
        }else{
          new CellLink(hierarchy[10][adDead4[0]-1], hierarchy[31][adDead4[1]-1]);
          new CellLink(hierarchy[10][adDead4[0]+1], hierarchy[31][adDead4[1]+1]);
        }
        if (hierarchy[20][adDead5[0]-1].pos().dist(hierarchy[30][adDead5[1]+1].pos()) > hierarchy[20][adDead5[0]-1].pos().dist(hierarchy[30][adDead5[1]-1].pos())){
          new CellLink(hierarchy[20][adDead5[0]-1], hierarchy[30][adDead5[1]+1]);
          new CellLink(hierarchy[20][adDead5[0]+1], hierarchy[30][adDead5[1]-1]);
        }else{
          new CellLink(hierarchy[20][adDead5[0]-1], hierarchy[30][adDead5[1]-1]);
          new CellLink(hierarchy[20][adDead5[0]+1], hierarchy[30][adDead5[1]+1]);
        }
        String fileName = Integer.toString(config.fileNum)+"combine.3dm";
        //IG.save(fileName);
        config.fileNum ++;
        config.combined = true;
      }
    }
          
  }
  
  
  
  
  
  void interact(ArrayList< IDynamics > agents){
    if(config.lcText == null){
      config.lcText = new IText("Loop Count = "+String.valueOf(config.allLoopCount), 6, 90, -70, 0).clr(0); 
    }else{
      try{config.lcText.del();}
      finally{}
      config.lcText = new IText("Loop Count = "+String.valueOf(config.allLoopCount), 6, 90, -70, 0).clr(0); 
    }    
    if((this == agents.get(0)) && time()==0 && config.originCellCount == 0){config.originCellCount = agents.size();}
    if((this == agents.get(0)) && time()%10==0){
        if(agents.size() > 60){//??
          
          if(time()%50 == 0 && time() >= 250 && time() < 1000){
            String fileName = Integer.toString(config.fileNum)+".3dm";
            //IG.save(fileName);
            config.fileNum ++;
          }
//set hierarchy
          //println("set hierarchy");
          ArrayList< Cell > allCells = new ArrayList();
          allCells = getAllCells(agents,-1);
          Cell[][] hierarchy ;
          hierarchy = new Cell[config.originCellCount*10][allCells.size()];
          
          hierarchy[0][0] = (Cell)agents.get(0);
          hierarchy[10][0] = (Cell)agents.get(1);
          hierarchy[20][0] = (Cell)agents.get(2);
          hierarchy[30][0] = (Cell)agents.get(3);
          
          breakCombine(allCells,hierarchy);
          
        }//cellsize>20
      }//run at first cell
                
      
    IVec neighborCenter = new IVec(0,0,0);
    int neighborCount=0;
    for(int i=0; i < agents.size(); i++){
      if(agents.get(i) instanceof Cell){
        Cell c = (Cell)agents.get(i);//!!!!!!
        if(c != this){
          // push if closer than two radii
          if(c.pos().dist(pos()) < c.radius+radius){
            IVec dif = c.pos().dif(pos());
            dif.len(((c.radius+radius)-dif.len())*100+80); // the closer the harder to push
            c.push(dif);
          }
          // count neighbors and calculate their center
          if(c.pos().dist(pos()) < c.radius+radius + radius*1.5){
            neighborCenter.add(c.pos());
            neighborCount++;
          }
        }
      }else if(agents.get(i) instanceof MyAttractor){//Attractor select
        MyAttractor attr = (MyAttractor)agents.get(i);
        double dist = attr.pos.dist(pos);
        if(attractor == null && dist<attr.rad){
          attractor = attr;
          minDist = dist;
        }
        else if(dist < minDist){
          attractor = attr;
          minDist = dist;
        }
      }
    }
    
    if(neighborCount > 0){ // push from center of neighbors
      //println(neighborCount);
      if(neighborCount > config.deadNeighborCount && this.circle != null && this != agents.get(0) && this != agents.get(1)){
        this.live = false;
        if(!this.clr().eq(0,0,1.0)){this.clr(10,10,10);}
      }else{
        this.live = true;
        if(this.cHSB == null){
          this.cHSB = new IColor(this.clr());
        }
        if(!this.clr().eq(0,0,1.0)){this.clr(0,1.0,0);}
      }
      neighborCenter.div(neighborCount);
      double deadMul = 1;
      double attMul = 1;
      if(!live){deadMul = 0.8;}
      if(attractor!=null){attMul = 1.4;}
      IVec dif = pos().dif(neighborCenter).len(14*deadMul*attMul); // constant force
      push(dif);
    }
    
    
    
  }
  
  void update(){
    
    if(IG.time() < growthDuration){
      if(time() > 0 && time()%divisionInterval==0){
        double deadMul = 1;
        double attMul = 1;
        if(!live){deadMul = 0.4;}
        if(attractor!=null){attMul = 1.6;}
        if(IRand.pct(50*deadMul*attMul)){ // random division                                //To do
          active = true;
        }
        if(active){ // divide when active flag is on
          divide();
        }
      }
      if(time()%growthInterval==0){
        grow();
      }
      
      
    }
    // update geometry
    if(circle==null){circle = new ICircle(pos(), radius).clr(this);}
    else{circle.center(pos()).radius(radius).clr(this);}     //radius??????
    //Attractor
    if(attractor!=null){
      //IVec dif = attractor.pos.dif(pos);
      //dif.len(dif.len()*0.2);
      //this.push(dif);
      attractor = null;
      minDist = -1;
    }
  }
  
  private ArrayList< Cell > getAllCells(ArrayList< IDynamics > allAgents, int gNum){
    ArrayList< Cell > returnAgents = new ArrayList();
    for(int i=0; i < allAgents.size(); i++){
      if(allAgents.get(i) instanceof Cell){
          Cell c = (Cell)allAgents.get(i);
          if(gNum == -1){returnAgents.add(c);}else if(c.groupNum == gNum){returnAgents.add(c);}
      }
    }
    return returnAgents;
  }
  
  
  void divide(){ // cell division
    if(links.size()==0){ // dot state
      Cell child = createChild(IRand.dir(IG.zaxis));
      config.loopCount[this.groupNum/10] ++;
      //println(this.groupNum,"config.loopCount ++");
      new CellLink(this, child);
    }
    else if(links.size()==1){ // line state
      Cell child = createChild(IRand.dir(IG.zaxis));
      new CellLink(child, links.get(0).cell1); // making a triangle loop
      new CellLink(child, links.get(0).cell2);
      config.allLoopCount ++;
    }
    else if(links.size()==2){ // string state
      CellLink dividingLink = links.get(IRand.getInt(0,1)); // pick one link out of two
      Cell c = dividingLink.oppositeCell(this); // other cell on the link
      IVec dir = c.pos().dif(pos()); // dividing direction is link direction
      Cell child = createChild(dir);
      dividingLink.del(); // delete picked link
      new CellLink(this, child); // create two new links
      new CellLink(child, c);
    }
  }
  
  void grow(){ // growing cell size
    if(radius < maxRadius){
      if(this.live){radius += growthSpeed;}else{radius += growthSpeed*0.3;}      
    }
  }
  
  Cell createChild(IVec dir){
    radius *= 0.5; //make both cell size half
    dir.len(radius);
    Cell child = new Cell(pos().cp().add(dir), radius,this.groupNum);
    child.clr(0,1.0,0);
    //child.hsb(hue()+IRand.get(-.1,.1),saturation()+IRand.get(-.1,.1),brightness()+IRand.get(-.1,.1));
    pos().sub(dir);//?????
    active = false; //reset activation
    return child;
  }
}
