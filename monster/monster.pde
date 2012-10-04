
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

import processing.serial.*;
import cc.arduino.*;

Arduino arduino;
Serial myPort;

PImage phase1;
PImage phase2;
PImage phase3;
PImage back;

import ddf.minim.*;
Minim minim;
AudioSample punch;

boolean attack = false;

boolean buttonDown = false;

boolean dead = false;

float monsterX = 600;
float monsterY = 300;

int monsterWidth = 1200;
int monsterHeight = 600;

int score = 100;

int mode = 0;

int button;

void setup() {

  size(1200, 600);

  back= loadImage("background.jpg");
  phase1 = loadImage("still1.png");
  phase2 = loadImage("a_hits_b1.png");
  phase3 = loadImage("b_hits_a1.png");

  minim = new Minim(this);
  punch = minim.loadSample("punch.wav", 3000);

  arduino = new Arduino (this, Arduino.list()[0], 57600);

  oscP5 = new OscP5(this, 7777);
  myRemoteLocation = new NetAddress("10.10.37.10", 8888);
}

void draw() {


  background(0);
 if (mode == 0){
  startScreen(); 
} else if (mode == 1){
 playGame(); 
}
}

void startScreen(){
  
  textAlign(CENTER);
  
  textSize(30);
  text("YOU ARE THE BLUE",600,200);
  
  textSize(40);
  text("CLICK TO START",600,400);
}

void playGame(){
  
  attack();
  drawmonster();
  

  
  OscMessage myMessage = new OscMessage("/button");

  if (arduino.analogRead(0)>450) {
    if(score>0){
    myMessage.add(1);
    image (phase2, monsterX, monsterY, monsterWidth, monsterHeight);
    punch.trigger();
    }
  }
  else {
    myMessage.add(0);
  }

  oscP5.send(myMessage, myRemoteLocation);
  

if (score<=0) {
  death();
  score=0;
}

fill(255);
textSize(30);
text (score, 40, 40); 


if (score>=100) {
  arduino.digitalWrite(10, Arduino.HIGH);
  arduino.digitalWrite(8, Arduino.HIGH);
  arduino.digitalWrite(6, Arduino.HIGH);
  arduino.digitalWrite(4, Arduino.HIGH);
  arduino.digitalWrite(2, Arduino.HIGH);
}
else if (score>=70) {
  arduino.digitalWrite(10, Arduino.LOW);
  arduino.digitalWrite(8, Arduino.HIGH);
  arduino.digitalWrite(6, Arduino.HIGH);
  arduino.digitalWrite(4, Arduino.HIGH);
  arduino.digitalWrite(2, Arduino.HIGH);
}
else if (score>=50) {
  arduino.digitalWrite(10, Arduino.LOW);
  arduino.digitalWrite(8, Arduino.LOW);
  arduino.digitalWrite(6, Arduino.HIGH);
  arduino.digitalWrite(4, Arduino.HIGH);
  arduino.digitalWrite(2, Arduino.HIGH);
}
else if (score>=30) {
  arduino.digitalWrite(10, Arduino.LOW);
  arduino.digitalWrite(8, Arduino.LOW);
  arduino.digitalWrite(6, Arduino.LOW);
  arduino.digitalWrite(4, Arduino.HIGH);
  arduino.digitalWrite(2, Arduino.HIGH);
}
else if (score>=20) {
  arduino.digitalWrite(10, Arduino.LOW);
  arduino.digitalWrite(8, Arduino.LOW);
  arduino.digitalWrite(6, Arduino.LOW);
  arduino.digitalWrite(4, Arduino.LOW);
  arduino.digitalWrite(2, Arduino.HIGH);
}
else if (score>=0) {
  arduino.digitalWrite(10, Arduino.LOW);
  arduino.digitalWrite(8, Arduino.LOW);
  arduino.digitalWrite(6, Arduino.LOW);
  arduino.digitalWrite(4, Arduino.LOW);
  arduino.digitalWrite(2, Arduino.LOW);
}

if (button==2) {
  resetGame();
}
}


void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/button")) {
    println("button: " + theOscMessage.get(0).intValue());
    button = theOscMessage.get(0).intValue();
  }
}

void attack() {
  if (button==1) {
    if (!buttonDown) {
      score-=random(1, 5);
      buttonDown = true;
    }
    punch.trigger();
    attack = true;
  }
  else {
    attack = false;
    buttonDown = false;
  }
}




void death() {
  dead = true;
  fill(255);
  textAlign(CENTER);
  textSize(40);
  text("GAME OVER", width/2, 100);
  textSize(15);
  text("Your health is", width/2, 200);
  textSize(30);
  text(score, width/2, height/2);
  textSize(13);
  text("Press Space to restart", width/2, 450);
}


void keyPressed() {
  if (key==' ') {
    if (dead==true) {
      dead = false;
      resetGame();
    
    OscMessage myMessage = new OscMessage("/button");
    myMessage.add(2);
    oscP5.send(myMessage, myRemoteLocation);
    }
  }
}

void mousePressed(){
 if (mode ==0){
  mode = 1;
 } 
}

void resetGame() {
  score = 100;
}

