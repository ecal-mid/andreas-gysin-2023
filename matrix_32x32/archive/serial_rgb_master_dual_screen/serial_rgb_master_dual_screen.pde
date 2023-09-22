/**
 *
 */

import processing.serial.*;
import java.lang.reflect.*;

final int MATRIX_A_WIDTH  = 64;
final int MATRIX_A_HEIGHT = 64;
final int MATRIX_B_WIDTH  = 32;
final int MATRIX_B_HEIGHT = 32;
final int NUM_CHANNELS = 3;

Serial[] serial = new Serial[2];
PGraphics[] tex = new PGraphics[2];
byte[][]buffer = new byte[2][];

Anim[] anim = new Anim[2];
int current_anim_id;
ArrayList <Class> anim_classes;

void setup() {
  size(810, 600);

  textFont(loadFont("mono.vlw"));

  int buffer_0_length =  MATRIX_A_WIDTH * MATRIX_A_HEIGHT * NUM_CHANNELS;
  buffer[0] = new byte[buffer_0_length];
  tex[0] = createGraphics(MATRIX_A_WIDTH, MATRIX_A_HEIGHT, JAVA2D);

  int buffer_1_length = MATRIX_B_WIDTH * MATRIX_B_HEIGHT * NUM_CHANNELS;
  buffer[1] = new byte[buffer_1_length];
  tex[1] = createGraphics(MATRIX_B_WIDTH, MATRIX_B_HEIGHT, JAVA2D);

  // Intit anims
  String superClassName = "Anim";
  anim_classes = new ArrayList<Class>();
  for (Class c : this.getClass().getDeclaredClasses()) {
    if (c.getSuperclass() != null && (c.getSuperclass().getSimpleName().equals(superClassName) )) {
      println("<" + superClassName + ">: [" + anim_classes.size() + "] " + c.getSimpleName());
      anim_classes.add(c);
    }
  }

  // Create the first instance
  current_anim_id = 0;
  anim[0] = createInstance(current_anim_id);
  anim[1] = createInstance(current_anim_id);

  printArray(Serial.list());
  serial[0] = new Serial(this, "/dev/tty.usbmodem61791201"); // 64x64
  serial[1] = new Serial(this, "/dev/tty.usbmodem64571801"); // 32x32
}

void draw() {

  // Animate and render the current animation to a texture

  int t = frameCount;//millis() / 2;

  for (int i=0; i<2; i++) {
    tex[i].beginDraw();
    anim[i].pre(tex[i]);
    anim[i].render(tex[i], t);
    anim[i].post(tex[i]);
    tex[i].endDraw();
    tex[i].loadPixels();
  }

  for (int i=0; i<2; i++) {
    // Write to the serial port (if open)
    if (serial != null) {
      int idx = 0;
      
      for (color c : tex[i].pixels) {
        buffer[i][idx++] = (byte)(c >> 16 & 0xFF);
        buffer[i][idx++] = (byte)(c >> 8 & 0xFF);
        buffer[i][idx++] = (byte)(c & 0xFF);
      }
      serial[i].write('*');        // The 'data' command
      serial[i].write(buffer[i]);  // ...and the pixel values
    }
  }
  
  // Preview
  background(80);

  // Offset and size of the preview
  int preview_size = 6;
  int ox = 20;
  int oy = 160;
  /*
  // Grid background
  fill(0);
  noStroke();
  rect(ox, oy, tex.width * preview_size, tex.height * preview_size);

  // LEDs
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

  // Matrix outline
  noFill();
  stroke(255);
  for (int j=0; j<NUM_TILES_Y; j++) {
    for (int i=0; i<NUM_TILES_X; i++) {
      int x = i * MATRIX_WIDTH * preview_size + ox;
      int y = j * MATRIX_HEIGHT * preview_size + oy;
      rect(x, y, MATRIX_WIDTH * preview_size, MATRIX_HEIGHT * preview_size);
    }
  }

  // Some info
  String txt = "";
  txt += "FPS           : " + round(frameRate) + "\n";
  txt += "NUM_TILES_X   : " + NUM_TILES_X + "\n";
  txt += "NUM_TILES_Y   : " + NUM_TILES_Y + "\n";
  txt += "MATRIX_A_WIDTH  : " + MATRIX_A_WIDTH + "\n";
  txt += "MATRIX_A_HEIGHT : " + MATRIX_A_HEIGHT + "\n";
  txt += "NUM_CHANNELS  : " + NUM_CHANNELS + "\n";
  txt += "Serial        : " + (serial != null ? "connected" : "disconnected") + "\n";
  txt += "<Anim>        : [" + current_anim_id  +"] " + anim.getClass().getSimpleName() + "\n";

  fill(255);
  textAlign(LEFT, TOP);
  text(txt, ox, 15);
  */
}

/**
 * Creates an instance of the super Anim classes
 *
 * @return An Anim object
 */
Anim createInstance(int id) {
  try {
    Class c = anim_classes.get(id);
    Constructor[] constructors = c.getConstructors();
    Anim instance = (Anim) constructors[0].newInstance(this);
    return instance;
  }
  catch (Exception e) {
    println(e);
  }
  return null;
}

void keyPressed() {
  if (keyCode == RIGHT) {
    current_anim_id = min(current_anim_id + 1, anim_classes.size()-1);
    anim[0] = createInstance(current_anim_id);
    anim[1] = createInstance(current_anim_id);
  } else if (keyCode == LEFT) {
    current_anim_id = max(current_anim_id - 1, 0);
    anim[0] = createInstance(current_anim_id);
    anim[1] = createInstance(current_anim_id);
  }

  // Forward the keyPress to the current anim
  anim[0].keyPressed(key, keyCode);
  anim[1].keyPressed(key, keyCode);
}

void mousePressed() {
  // Forward the mousePress to the current anim
  anim[0].mousePressed(mouseX, mouseY);
  anim[1].mousePressed(mouseX, mouseY);
}
