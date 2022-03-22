import processing.video.*;
import cvimage.*;
import org.opencv.core.*;
import org.opencv.imgproc.Imgproc;

Capture cam;
CVImage img,pimg,auximg;

int col = 0;
int sum = 5;
int modo = 1;
void setup() {
  size(640, 480);
  //Cámara
  cam = new Capture(this, width, height);
  cam.start();

  //OpenCV
  //Carga biblioteca core de OpenCV
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);
  img = new CVImage(cam.width, cam.height);
  pimg = new CVImage(cam.width, cam.height);
  auximg=new CVImage(cam.width, cam.height);
  
  
}

void draw() { 
  
  if (cam.available()) {
    if(modo == 1){
      background(0);
      cam.read();
  
      //Obtiene la imagen de la cámara
      img.copy(cam, 0, 0, cam.width, cam.height,
      0, 0, img.width, img.height);
      img.copyTo();
  
      //Imagen de grises
      Mat gris = img.getGrey();
      Mat pgris = pimg.getGrey();
  
      //Calcula diferencias en tre el fotograma actual y el previo
      Core.absdiff(gris, pgris, gris);
  
      //Copia de Mat a CVImage
      cpMat2CVImage(gris,auximg);
  
      //Visualiza ambas imágenes
      image(auximg,0,0);
  
      //Copia actual en previa para próximo fotograma
      pimg.copy(img, 0, 0, img.width, img.height,
      0, 0, img.width, img.height);
      pimg.copyTo();
      
      if(Core.countNonZero(gris) > 250000){
        print(Core.countNonZero(gris) + "\n");
        print(col);
        
        col+= sum;
        if(col < 255){ sum *= -1;}
        if(col > 0){ sum *= -1;}
      }
      
      gris.release();
    } else{
      background(0);
      cam.read();
  
      //Obtiene la imagen de la cámara
      img.copy(cam, 0, 0, cam.width, cam.height,
      0, 0, img.width, img.height);
      img.copyTo();
  
      //Imagen de grises
      Mat gris = img.getGrey();
      Mat pgris = pimg.getGrey();
  
      //Calcula diferencias en tre el fotograma actual y el previo
      Core.absdiff(gris, pgris, gris);
  
      //Copia de Mat a CVImage
      cpMat2CVImage(gris,auximg);
  
      //Visualiza ambas imágenes
      image(img,0,0);
  
      //Copia actual en previa para próximo fotograma
      pimg.copy(img, 0, 0, img.width, img.height,
      0, 0, img.width, img.height);
      pimg.copyTo();
    }
    
    modo(modo);
  }
  
}

//Copia unsigned byte Mat a color CVImage
void  cpMat2CVImage(Mat in_mat,CVImage out_img)
{    
  byte[] data8 = new byte[cam.width*cam.height];

  out_img.loadPixels();
  in_mat.get(0, 0, data8);

  // Cada columna
  for (int x = 0; x < cam.width; x++) {
    // Cada fila
    for (int y = 0; y < cam.height; y++) {
      // Posición en el vector 1D
      int loc = x + y * cam.width;
      //Conversión del valor a unsigned
      int val = data8[loc] & 0xFF;
      //Copia a CVImage
      out_img.pixels[loc] = color(col, 0, 255-val);
    }
  }
  out_img.updatePixels();
}

void modo(int modo){
  switch(modo){
    case 1:
    //Modos
  
    textSize(24);
    textAlign(CENTER);
    text("Cambio de color por movimiento", width/2,30);
    break;
    case 2:
    text("Persiana", width/2,30);
    break;
  }
}

void mouseClicked(){
  modo++;
  if (modo > 2) modo = 1;
}
