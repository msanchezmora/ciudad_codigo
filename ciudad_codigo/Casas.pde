
//      ___   __   ____   __  
//     / __) / _\ / ___) / _\ 
//    ( (__ /    \\___ \/    \
//     \___)\_/\_/(____/\_/\_/
//

class Casa {
  Body body; //Cuerpo físico box2d
  float posX, posY, angulo; // Posicón y ángulo. Se asignan desde fuera
  float ancho, alto; // Ancho y alto de la caja
  float colorCasa; // Color que tomará la casa aleatorio
  int edad, edadMaxima; //Edad que va sumandose cada frame, y edad a la que re reiniciará la casa.
  
  Casa() {
    //Pon tamaño aleatorio
    ancho = random(anchoBordeMarco*0.5*0.3, anchoBordeMarco*0.5*1.1);
    alto = random(anchoBordeMarco*0.5*0.3, anchoBordeMarco*0.5*1.1);
    edad = int (random(3000)); //La edad incial es aleatoria
    //La edad máxima la hacemos aleatoria entre 5000 fotogramas y 60000 fotogramas
    edadMaxima = int (random(5000,60000));
  }
  
  //El inicio lo separamos para poder poner el angulo y posicion desde fuera antes de iniciar la persona
  void inicia(){
    //Añade el body al mundo Box2d
    makeBody(new Vec2(posX, posY), ancho, alto, angulo);
    body.setUserData(this);
  }
  
  // Funcion para que podamos actualizar la posición que cambiamos fuera cuando la casa muere y vuelve a nacer
  void actualizaPosicion(){
    body.setTransform(box2d.coordPixelsToWorld(posX, posY), angulo);
  }
  
  void draw(){
    //Cumple un frame
    edad++;

    // Obtenemos la posición dle objeto Box2D
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    
    //Dibujamos el objeto
    rectMode(PConstants.CENTER);
    pushMatrix(); //Se usa una matriz para controlar mejor cómo dibujamos el rectángulo.
    translate(pos.x, pos.y);
    rotate(-a);
    noStroke();
    fill(0,0,180);
    rect(0, 0, ancho, alto);
    popMatrix();
  }
  
  // Esta función añade el body en forma de rectángulo al mundo 2d
  void makeBody(Vec2 center, float w_, float h_, float angle_) {
    // Se define y crea el cuerpo
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    bd.angle = angle_;
    body = box2d.createBody(bd);

    // Se genera el rectángulo
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);

    // Se le asigna a la forma
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    
    // Le damos parámetros físicos
    fd.density = 1;
    fd.friction = 0.0;
    fd.restitution = 0.5;

    // Añadimos la forma al cuerpo 
    body.createFixture(fd);
  }
  
}
