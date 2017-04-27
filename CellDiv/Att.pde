static class MyAttractor extends IAgent{
  IVec pos;
  IPoint point;
  double rad;
  MyAttractor(IVec p, double r){
    pos = p;
    rad = r;
    point = new IPoint(pos).clr(255,0,0);
  }
  void update(){
  }
}
