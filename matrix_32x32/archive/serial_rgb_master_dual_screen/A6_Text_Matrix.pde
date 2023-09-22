/**
 * An example with a custom bitmap based font. 
 */
 
 class A6_Text_Matrix extends Anim {

  int gliph_w = 5;
  int gliph_h = 8;
  ArrayList<PImage> font_table;  

  public A6_Text_Matrix() {
    font_table = new ArrayList();
    PImage lcd = loadImage("lcd.png");
    for (int j=0; j<16; j++) {
      for (int i=0; i<8; i++) {
        PImage t = lcd.get(1 + i * (gliph_w + 1), 1 + j * (gliph_h + 1), gliph_w, gliph_h);
        font_table.add(t);
      }
    }
  }

  void render(PGraphics target, int t) {    
    target.background(0);
    String s = "MAMAMATRIX1234567890";

    int num_x = target.width / (gliph_w + 1) + 1;
    int num_y = target.height / (gliph_h) + 1;
    
    for (int j=0; j<num_y; j++) {
      for (int i=0; i<num_x; i++) {
        int offs = round(map(sin(t * 0.05 + (float) j / num_y * TAU / 4), -1, 1, 0, num_x*2));
        int pos = (i + j + offs) % s.length();
        int x = i * (gliph_w + 1);
        int y = j * (gliph_h);
        float f = 0.8;
        target.tint(255 * f, 192 * f, 203 * f);
        target.image(font_table.get((int)s.charAt(pos)), x, y);
      }
    }
  }
}
