/**
 * Test sketch!
 */
 
 class A0_Test extends Anim {
    
  public A0_Test() {
  }

  void render(PGraphics target, int t) {
    for (int j=0; j<target.width; j++) {
      for (int i=0; i<target.height; i++) {
        float r = float(i) / target.width * 255.0;
        float g = float(j) / target.height * 255.0;
        float b = map(sin(t*0.004), -1, 1, 0, 255);
        color c = color(r,g,b);
        target.set(i, j, c);
      }
    }
  }
}
