class CellLink extends IAgent{
  Cell cell1, cell2;
  ICurve line;
  CellLink(Cell c1, Cell c2){
    cell1 = c1; cell2 = c2;
    cell1.links.add(this); // register this link to cells{
    cell2.links.add(this);
    line = new ICurve(c1.pos(), c2.pos()).clr(1.0,0,0);
  }
  
  void interact(ArrayList< IDynamics > agents){
    // spring force
    IVec dif = cell1.pos().dif(cell2.pos());
    double force = (dif.len()-(cell1.radius+cell2.radius))/(cell1.radius+cell2.radius)*200;
    dif.len(force);
    cell1.pull(dif);
    cell2.push(dif);
  }
  
  void del(){
    cell1.links.remove(this); // unregister from cells
    cell2.links.remove(this);
    line.del(); // delete line geometry
    super.del(); // stop agent
  }
  
  Cell oppositeCell(Cell c){ // find other cell on the link
    if(cell1==c) return cell2;
    if(cell2==c) return cell1;
    IG.err("Link does not contain the input cell");
    return null; 
  }
}
