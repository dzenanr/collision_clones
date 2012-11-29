library game_cars;

import 'dart:html';
import 'dart:isolate';
import 'dart:math';

import 'package:simple_audio/simple_audio.dart';

part 'color.dart';
part 'random.dart';

const int carCount = 8;

class Car {
  num x;
  num y;
  num width;
  num height;

  num dx;
  num dy;

  CanvasElement canvas;
  CanvasRenderingContext2D context;

  String colorCode;

  Car(this.canvas, this.context) {
    dx = randomDouble(4.0);
    dy = randomDouble(4.0);

    width = 80;
    height = 32;
    var diagramWidth = canvas.width.toDouble();
    var diagramHeight = canvas.height.toDouble();
    x = randomDouble(diagramWidth - width);
    y = randomDouble(diagramHeight - height);

    colorCode = randomColorCode();
  }

  draw() {
    context.beginPath();
    context.rect(x, y, width, height);
    context.fillStyle = colorCode;
    context.fill();
    context.lineWidth = 2;
    context.strokeStyle = 'black';
    context.closePath();
  }

  move(RedCar redCar) {
    x += dx;
    y += dy;
    redCar.collision(this);
    if (x > canvas.width || x < 0) dx = -dx;
    if (y > canvas.height || y < 0) dy = -dy;
  }

}

class RedCar extends Car {

  static const num okWidth = 120;
  static const num okHeight = 48;
  static const String okColorCode = '#ff0000';

  static const num nokWidth = 32;
  static const num nokHeight = 8;
  static const String nokColorCode = '#000000';
  
  AudioManager audioManager;
  bool accident = false;

  RedCar(canvas, context, this.audioManager) : super(canvas, context) {
    colorCode = okColorCode;
    width = okWidth;
    height = okHeight;
    x = canvas.width/2;
    y = canvas.height/2;
    canvas.document.on.mouseMove.add((MouseEvent e) {
      x = e.offsetX - 35;
      y = e.offsetY - 35;
      if (x > canvas.width || x < 0) {
        big();
      }
      if (y > canvas.height || y < 0) {
        big();
      }
    });
  }

  big() {
    colorCode = okColorCode;
    width = okWidth;
    height = okHeight;
    accident = false;
  }

  small() {
    //audioManager.playClipFromSource('game', 'collision');
    audioManager.playClipFromSourceIn(0.0, 'game', 'collision');
    colorCode = nokColorCode;
    width = nokWidth;
    height = nokHeight;
    accident = true;
  }

  collision(Car car) {
    if (car.x < x  && car.y < y) {
      if (car.x + car.width >= x && car.y + car.height >= y) {
        accident ?  null : small();
      }
    } else if (car.x < x  && car.y > y) {
      if (car.x + car.width >= x && car.y <= y + height) {
        accident ?  null : small();
      }
    } else if (car.x > x  && car.y < y) {
      if (car.x <= x + width && car.y + car.height >= y) {
        accident ?  null : small();
      }
    } else if (car.x > x  && car.y > y) {
      if (car.x <= x + width && car.y <= y + height) {
        accident ?  null : small();
      }
    }

  }
}

draw(CanvasRenderingContext2D context, List cars, RedCar redCar) {
  clear() {
    context.fillStyle = "#ffffff";
    context.fillRect(0, 0, context.canvas.width, context.canvas.height);
  }

  clear();
  var i;
  for (var i = 0; i <cars.length; i++) {
    cars[i].move(redCar);
    cars[i].draw();
  }
  redCar.draw();
}

printCars(cars) {
  for (var i = 0; i < cars.length; i++) {
    var car = cars[i];
    print('x: ${car.x}, y: ${car.y}, width: ${car.width}, height: ${car.height}');
  }
}

String getDemoBaseURL() {
  String location = window.location.href;
  int slashIndex = location.lastIndexOf('/');
  if (slashIndex < 0) {
    return '/';
  } else {
    return location.substring(0, slashIndex);
  }
}

main() {
  CanvasElement canvas = document.query('#canvas');
  CanvasRenderingContext2D context = canvas.getContext('2d');
  
  AudioManager audioManager = new AudioManager('${getDemoBaseURL()}/sound');
  AudioSource audioSource = audioManager.makeSource('game');
  audioSource.positional = false;
  //AudioClip collisionSound = audioManager.makeClip('collision', 'beep.mp3');
  AudioClip collisionSound = audioManager.makeClip('collision', 'collision.ogg');
  collisionSound.load();
 
  var cars = new List();
  for (var i = 0; i < carCount; i++) {
    var car = new Car(canvas, context);
    cars.add(car);
  }

  var redCar = new RedCar(canvas, context, audioManager);
  // Redraw every carCount ms.
  new Timer.repeating(carCount < 20 ? carCount : carCount - 16,
    (t) => draw(context, cars, redCar));
}

