// La clase Borde solamente se compone los cuatro bordes transparentes (no se dibujan) que se ponen alrededor de la ventana, para que las personas no se salgan.
class Borde {

  // Rectángulo con posición x e y, y tamaño w y h.
  float x;
  float y;
  float w;
  float h;
  
  // El cuerpo del borde
  Body b;

  Borde(float x_,float y_, float w_, float h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;

    // Se define el polígono
    PolygonShape sd = new PolygonShape();
    // De le ponen los tamaños
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // Y se genera la caja
    sd.setAsBox(box2dW, box2dH);


    // Creamos el cuertpo
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    b = box2d.createBody(bd);
    
    // Añadimos la caja al cuerpo
    b.createFixture(sd,1);
  }
}

