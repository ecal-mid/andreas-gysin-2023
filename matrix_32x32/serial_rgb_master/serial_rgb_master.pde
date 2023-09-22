import processing.serial.*;
// jssc fix for M1 https://notes.osteele.com/courses/interaction-lab/using-serial-with-processing-4-on-apple-silicon
PGraphics output;
final int MATRIX_WIDTH = 32;
final int MATRIX_HEIGHT = 32;
final int NUM_CHANNELS = 3;
Serial serial;
byte[]buffer;

boolean preview = true;

void setup() {

  size(200, 200);
  
  // PGraphics 
  output = createGraphics(MATRIX_WIDTH, MATRIX_HEIGHT);

  // Init du buffer 
  int buffer_length =  MATRIX_WIDTH * MATRIX_HEIGHT * NUM_CHANNELS;
  buffer = new byte[buffer_length];

  // Affichage des portes serielles disponibiles 
  printArray(Serial.list());
  
  // Pour testing local:
  serial = null;
  
  // Pour MacOS (la porte peut changer)
  serial = new Serial(this, "/dev/cu.usbmodem131734901");
  
  // Pour Windows (la porte peut changer)
  // serial = new Serial(this, "COM3");                     
}

void draw() {  
  
  // Mini animation
  output.beginDraw();
  output.background(0);
  output.fill(255,0,0);
  float d = map(sin(frameCount*0.03), -1, 1, 3, 30);
  output.noStroke();
  output.ellipse(output.width/2, output.height/2, d, d);
  output.endDraw();
  
  // Envoy des donnes sur la matrice
  if (serial != null) {
    int idx = 0;
    for (color c : output.pixels) {
      buffer[idx++] = (byte)(c >> 16 & 0xFF);
      buffer[idx++] = (byte)(c >> 8 & 0xFF);
      buffer[idx++] = (byte)(c & 0xFF);
    }
    serial.write('*');      // The 'data' command
    serial.write(buffer);  // ...and the pixel values
  }
  
  // Preview
  background(100);
  image(output, 10, 10);
  
}
