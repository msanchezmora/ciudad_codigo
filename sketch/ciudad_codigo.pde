// Librerías BOX2D para la física (inercia, rebotes, etc)
import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.dynamics.*;

//     _  _   __   ____  __   __   ____  __    ____  ____ 
//    / )( \ / _\ (  _ \(  ) / _\ (  _ \(  )  (  __)/ ___)
//    \ \/ //    \ )   / )( /    \ ) _ (/ (_/\ ) _) \___ \
//     \__/ \_/\_/(__\_)(__)\_/\_/(____/\____/(____)(____/
//

// CASAS
// Primero se generará una casa por barrio. Después se añadirán casas adosadas con el mismo ángulo.
int numeroMaximoCasas=120; //Numero de casas que se crearán
int numeroMaximoDeBarrios = 7; //Número de casas que se creará al inicio de forma aleatoria e independiente
float distaciaMinimaSeparacionCasasBarrio = 44.0; //Distancia mínima de separación para el resto de las casas
float distaciaMaximaSeparacionCasasBarrio = 50.0; //Distancia maxima de separación para el resto de las casas

// PERSONAS
int numeroMaximoPersonas=160; //Numero de personas que se crearán. Las que se mueran, volverán a nacer

// Bordes
int anchoBordeMarco=30;  //Separación entre el borde de la aplicación y la generación de contenidos. Las casas pueden sobresalir.

//Datos GPS, que nos servirán para obtener los colores de los elementos.
//Datos GPS de Córdoba
float gpsLongitud = -4.7666;
float gpsLatitud = 37.8833;
//Color calculado a traves de estos datos GPS
PVector colorLocal = new PVector(180.0+gpsLongitud, 180.0-(90.0+gpsLatitud), (90.0+gpsLatitud));
float contraste; //Tomaremos las nubes en ese momento para dar más o menos contraste. Varíará de 0 a 100
JSONObject json; //Para obtener valores externos de una web

// Iniciamos una instancia del motor de física Box2d
Box2DProcessing box2d;

//Creamos un listado de casas
ArrayList<Casa> casas;
//Un listado de personas
ArrayList<Persona> personas;
//Y un listado de border (Que evitarán que se salgan las personas)
ArrayList<Borde> bordes;


//     ____  ____  ____  _  _  ____ 
//    / ___)(  __)(_  _)/ )( \(  _ \
//    \___ \ ) _)   )(  ) \/ ( ) __/
//    (____/(____) (__) \____/(__)  
//

//Setup solo se ejecuta una vez al inicio.
void setup() {
  //Tamaño de la ventana y fotogramas por segundo (máximos, seguramente no llegue a tal velocidad, pero no es importante)
  size(768, 768);
  frameRate(300);
  colorMode(HSB, 360, 180, 180);

  //Iniciamos la instancia del motor de física, y lo configuramos con gravedad 0
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, 0);

  //Iniciamos el arrayList vacío de personas. Luego lo rellenaremos poco a poco
  personas = new ArrayList<Persona>();

  personas.add(new Persona());

  //Iniciamos el arrayList vacío de casas. Luego lo rellenaremos poco a poco
  casas = new ArrayList<Casa>();



  //Añade el borde, para que no se salgan las personas
  bordes = new ArrayList<Borde>();
  bordes.add(new Borde(width/2, height, width, anchoBordeMarco*2));
  bordes.add(new Borde(width/2, 0, width, anchoBordeMarco*2));
  bordes.add(new Borde(width, height/2, anchoBordeMarco*2, height));
  bordes.add(new Borde(0, height/2, anchoBordeMarco*2, height));


  //Obtenemos los datos meteorológicos de una web
  json = loadJSONObject("http://api.openweathermap.org/data/2.5/weather?lat="+gpsLatitud+"&lon="+gpsLongitud);
  JSONObject cloudsObj = json.getJSONObject("clouds");
  //Ponermos la nubosidad como variable de contraste a la inversa
  contraste = 100-cloudsObj.getInt("all");

  //Ponemos el fondo blanco, solo una vez
  background(0, 0, 180);
}


//     ____  ____   __   _  _ 
//    (    \(  _ \ / _\ / )( \
//     ) D ( )   //    \\ /\ /
//    (____/(__\_)\_/\_/(_/\_)
//

//Esta función se ejecuta cada fotograma
void draw() {
  
  //Actualiza el mundo físico. Cs un comando de la libreria que estamos obligados a ejecutar cada fotograma
  box2d.step();

  // PERSONAS
  //Cada 10 frames, aproximadamente, creamos una nueva persona
  if (random(10)<1 && personas.size()<numeroMaximoPersonas) {
    // Creamos una nueva persona añadiéndola a la lista
    personas.add(new Persona());
  }

  // Recorremos todas las personas creadas y las dibujamos
  for (int i = 0; i < personas.size (); i++) {
    personas.get(i).draw();
  }

  // CASAS
  // Cada 10 frames, aproximadamente, creamos una nueva casa
  if (random(10)<1 && casas.size()<numeroMaximoCasas) {
    // Creamos la instancia de nuestra casa
    casas.add(new Casa());
    //Le asignamos una posición
    //Esta función la dejamos fuera, para que podamos crear una casa en cualquier lugar.
    asignaPosicion(casas.size()-1);
    //Iniciamos la casa con los datos que tenemos
    casas.get(casas.size()-1).inicia();
  }

  // CASAS
  // En el siguiente bucle, recorremos todas las casas y las dibujamos
  for (int i = 0; i < casas.size (); i++) {
    casas.get(i).draw();
    //Mira si ha muerto
    if (casas.get(i).edad>casas.get(i).edadMaxima) {
      casas.get(i).edad=0;
      asignaPosicion(i);
      casas.get(i).actualizaPosicion();
    }
  }
}



//Funciones especiales
void asignaPosicion(int n) {
  /// Si es una de las X primeras casas, ponemos posiciones y angulos completamente aleatorios de forma independiente para que formen los barrios
  if (casas.size()<=numeroMaximoDeBarrios) {
    casas.get(n).posX = anchoBordeMarco+random(width-anchoBordeMarco*2);
    casas.get(n).posY = anchoBordeMarco+random(height-anchoBordeMarco*2);
    casas.get(n).angulo = random(360);
    // Si no es de las primeras casas seguimos
  } else {
    //Iniciamos unas variables temporales que nos servirán después
    float posAleatoriaX;
    float posAleatoriaY;
    float angulo = 0.0;
    boolean tieneCasasCerca;
    boolean tieneCasasDemasiadoCerca;

    // En el siguiente bucle generamos una posicion aleatoria y miramos
    // si está en una posición suficiente mente cerca de alguna otra casa
    // y no está demasiado pegada al resto de casas
    do
    {
      tieneCasasCerca = false;
      tieneCasasDemasiadoCerca = false;
      // Ponemos una posición aleatoria
      posAleatoriaX = anchoBordeMarco+random(width-anchoBordeMarco*2);
      posAleatoriaY = anchoBordeMarco+random(height-anchoBordeMarco*2);
      // Recorremos todas las casa para ver si está a la distancia que queremos
      for (int i = 0; i < casas.size (); i++) {
        float distanciaActual=dist(posAleatoriaX, posAleatoriaY, casas.get(i).posX, casas.get(i).posY);
        if (distanciaActual<distaciaMaximaSeparacionCasasBarrio) {
          tieneCasasCerca = true;
          //Si esta casa esta cerca, cojemos el mismo ángulo y se lo asignaremos después
          angulo=casas.get(i).angulo;
        }
        if (distanciaActual<distaciaMinimaSeparacionCasasBarrio) {
          tieneCasasDemasiadoCerca = true;
        }
      }
      //Una vez que confirmamos que está cerca de alguna, pero no demasiado cerca de ninguna, seguimos
    } 
    while (!tieneCasasCerca || tieneCasasDemasiadoCerca);

    //Ya que tenemos las variables que nos gustan, se la asignamos a la casauqe hemos creado
    casas.get(n).posX=posAleatoriaX;
    casas.get(n).posY=posAleatoriaY;
    casas.get(n).angulo = angulo;
  }
}

