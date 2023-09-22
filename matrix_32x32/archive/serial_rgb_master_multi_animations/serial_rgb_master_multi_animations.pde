import processing.serial.*;

final int MATRIX_WIDTH  = 32;
final int MATRIX_HEIGHT = 32;
final int NUM_CHANNELS = 3;

Serial serial;
PGraphics tex;
byte[]buffer;

Anim anim;
int current_anim_id;
ArrayList <Class> anim_classes;

void setup() {
  size(810, 600);

  textFont(loadFont("mono.vlw"));

  int buffer_length =  MATRIX_WIDTH * MATRIX_HEIGHT * NUM_CHANNELS;
  buffer = new byte[buffer_length];
  tex = createGraphics(MATRIX_WIDTH, MATRIX_HEIGHT, JAVA2D);

  anim = new A0_Test();

  printArray(Serial.list());
  serial = new Serial(this, "/dev/cu.usbmodem64571801");
}

void draw() {

  int time = millis();

  tex.beginDraw();
  anim.pre(tex);
  anim.render(tex, time);
  anim.post(tex);
  tex.endDraw();
  tex.loadPixels();


  // Write to the serial port (if open)
  if (serial != null) {
    int idx = 0;
    for (color c : tex.pixels) {
      buffer[idx++] = (byte)(c >> 16 & 0xFF);
      buffer[idx++] = (byte)(c >> 8 & 0xFF);
      buffer[idx++] = (byte)(c & 0xFF);
    }
    serial.write('*');      // The 'data' command
    serial.write(buffer);  // ...and the pixel values
  }

  // -- Preview ---------------------------------------
  background(80);

  // Offset and size of the preview
  int preview_size = 14;
  int ox = 20;
  int oy = 140;

  // Grid background
  fill(0);
  noStroke();
  rect(ox-1, oy-1, tex.width * preview_size + 1, tex.height * preview_size + 1);

  // LEDs preview
  for (int j=0; j<tex.height; j++) {
    for (int i=0; i<tex.width; i++) {
      int idx = i + j * tex.width;
      color c = tex.pixels[idx];
      fill(c);
      int x = ox + i * preview_size;
      int y = oy + j * preview_size;
      rect(x, y, preview_size-1, preview_size-1);
    }
  }

  // Some info
  String txt = "";
  txt += "FPS           : " + round(frameRate) + "\n";
  txt += "MATRIX_WIDTH  : " + MATRIX_WIDTH + "\n";
  txt += "MATRIX_HEIGHT : " + MATRIX_HEIGHT + "\n";
  txt += "NUM_CHANNELS  : " + NUM_CHANNELS + "\n";
  txt += "Serial        : " + (serial != null ? "connected" : "disconnected") + "\n";
  txt += "<Anim>        : [" + current_anim_id  +"] " + anim.getClass().getSimpleName() + "\n";

  fill(255);
  textAlign(LEFT, TOP);
  text(txt, ox, 15);
}

void keyPressed() {
  // Forward the keyPress to the current anim
  anim.keyPressed(key, keyCode);
}

void mousePressed() {
  // Forward the mousePress to the current anim
  anim.mousePressed(mouseX, mouseY);
}
