import controlP5.*;
import processing.pdf.*;


color colorHL = color(255, 204, 153);
Table airData = new Table();

int rectWidth = 5, rectHeight = 5;
int newX = 0, newY = -rectHeight, spacerRow = 0, spacerCol = 0;
int norm = 280;

boolean isDrawn = false, isLoaded = false;
color rectColor;
String fPath = "";
String fName = "";
PGraphics preview;
ControlP5 cp5;
Textlabel txtLab;
Textfield normFld, timeFld;



public void setup(){
    size(800, 450, P2D);
    noStroke();
    colorMode(HSB, 360, 100, 100);
    preview = createGraphics(displayWidth, 300);
    
    cp5 = new ControlP5(this);
  
    // create a new button with name 'buttonA'
    cp5.addButton("loadFile")
       //.setValue(0)
       .setPosition(100,100)
       .setSize(200,19)
       ;
       
    txtLab = cp5.addTextlabel("label")
                    .setText("No data loaded")
                    .setPosition(310,107)
                    .setColorValue(0xffffff00)
                    ;
    
    cp5.addButton("generate")
       //.setValue(0)
       .setPosition(100,130)
       .setSize(200,19)
       ;
       
    timeFld = cp5.addTextfield("timePeriod")
       .setText("48")
       .setPosition(220,220)
       .setSize(100,20)
       .setAutoClear(true)
       ;
       
    normFld = cp5.addTextfield("norm")
       .setText("280")
       .setPosition(100,220)
       .setSize(100,20)
       .setAutoClear(true)
       ;
}

public void draw(){
  background(0);
  //norm = int(cp5.get(Textfield.class,"norm").getText());
  norm = int(normFld.getText());
  //timePeriod = int(timeFld.getText());
  
}

public void keyReleased() {
  switch(key){            
    case'L':
    case'l':
      selectInput("Select a file to process:", "fileSelected");
    break;
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    fPath = selection.getAbsolutePath();
    println("User selected" + fPath);
    if (loadData(fPath)) {
      fName = selection.getName();
      txtLab.setText("Data loaded: " + fName);
    }
  }
}


boolean loadData(String fPath){
    airData = loadTable(fPath);
    return true;
}


public void drawData2(PGraphics output, Table airData)
{
  output.noStroke();
  output.colorMode(HSB, 360, 100, 100);
  for(int i=0; i<airData.getRowCount(); i++){
    for (int j=0; j<airData.getColumnCount(); j++){
      int probe = airData.getInt(i, j);
      newX = j%airData.getColumnCount() * (rectWidth + spacerCol);
      if(j%airData.getColumnCount() == 0){
        newY += rectHeight + spacerRow;
        newX = 0;
      }
      println(i + ": " + probe + " " + newX + "|" + newY);
      //print(newY + ", " + newX + "; ");

      if (probe < 1){
        rectColor = color(360, 0, 100, 0.5);
      } else if (probe > 1 && probe < norm){
        rectColor = color(200, 50, map(probe, 1, norm, 100, 0));
      } else if (probe > norm){
        rectColor = color(360, 100, map(probe, 1, norm*3, 0, 100));
      }
      output.fill(rectColor);
      output.rect(newX, newY-rectHeight, rectWidth, rectHeight);
    }
  }
}


public void drawDataDiagonal(PGraphics output, Table airData)
{
  output.noStroke();
  output.colorMode(HSB, 360, 100, 100);
  for(int i=0; i<airData.getRowCount(); i++){
    for (int j=0; j<airData.getColumnCount(); j++){
      int probe = airData.getInt(i, j);
      newX = j%airData.getColumnCount() * (rectWidth + spacerCol);
      if(j%airData.getColumnCount() == 0){
        newY += rectHeight + spacerRow;
        newX = 0;
      }
      println(i + ": " + probe + " " + newX + "|" + newY);
      
      //print(newY + ", " + newX + "; ");

      if (probe < 1){
        rectColor = color(360, 0, 100, 0.5);
      } else if (probe > 1 && probe < norm){
        rectColor = color(200, 50, map(probe, 1, norm, 100, 0));
      } else if (probe > norm){
        rectColor = color(360, 100, map(probe, 1, norm*3, 0, 100));
      }
      println("proble: " + probe);
      //float coverage = random(100)/100;
      
      float coverage = probe/150.0;
      println("cov: " + coverage);
      output.fill(0);
      drawDiagonalCell(newX, newY, rectHeight, coverage, output);
      //output.fill(rectColor);
      //output.rect(newX, newY-rectHeight, rectWidth, rectHeight);
    }
  }
}

public void drawDiagonalCell(int xx, int yy, int rectHeight, float coverage, PGraphics output){
  float P = coverage * rectHeight*rectHeight;
  float m = rectHeight;
  float a = m - sqrt(m*m - P);
  output.pushMatrix();
  output.translate(xx, yy - m);
    output.beginShape();
    output.vertex(0, 0);
    output.vertex(a, 0);
    output.vertex(m, m-a);
    output.vertex(m, m);
    output.vertex(m-a, m);
    output.vertex(0, a);
    output.endShape(CLOSE);
  output.popMatrix();
}

public void loadFile(int theValue) {
   selectInput("Select a file to process:", "fileSelected");
}

public void generate(int theValue) {
   if (airData.getRowCount() > 0) {
     newX = 0;
     newY = 0;
     savePdf(airData);
     println("\ndone: " + fName);
   }
}

public void savePdf(Table airData){
  int pdfWidth = ceil(airData.getColumnCount()) * (rectWidth + spacerCol);
  int pdfHeight = ceil(airData.getRowCount()) * (rectHeight + spacerRow);
  PGraphics pdf = createGraphics(pdfWidth, pdfHeight, PDF, split(fName, '.')[0] + ".pdf");
  pdf.beginDraw();
  //drawData2(pdf, airData);
  drawDataDiagonal(pdf, airData);
  pdf.dispose();
  pdf.endDraw();
}