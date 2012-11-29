library game_cars;

import 'dart:html';
import 'dart:isolate';
import 'dart:math';

import 'package:simple_audio/simple_audio.dart';

part 'color.dart';
part 'random.dart';

const int carCount = 8;
int timeInMinutes = 0;
int timeInSeconds = 0;

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

    width = 75;
    height = 30;
    var diagramWidth = canvas.width.toDouble();
    var diagramHeight = canvas.height.toDouble();
    x = randomDouble(diagramWidth - width);
    y = randomDouble(diagramHeight - height);

    colorCode = randomColorCode();
  }

  draw() {
    context.beginPath();
    context.fillStyle = colorCode;
    context.strokeStyle = 'black';
    context.lineWidth = 2;
    context.rect(x, y, width, height);
    context.fill();
    context.stroke();
    context.closePath();
    // wheels
    context.beginPath();
    context.fillStyle = '#000000';
    context.rect(x + 10, y - 2, 10, 6); 
    context.rect(x + width - 20, y - 2, 10, 4);
    context.rect(x + 10, y + height - 2, 10, 4);
    context.rect(x + width - 20, y + height - 2, 10, 4);
    context.fill();
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

  static const num okWidth = 90;
  static const num okHeight = 36;
  static const String okColorCode = '#ff0000';

  static const num nokWidth = 35;
  static const num nokHeight = 14;
  static const String nokColorCode = '#000000';
  
  AudioManager audioManager;
  LabelElement score;
  
  bool accident = false;
  int accidentCount = 0;

  RedCar(canvas, context, this.audioManager, this.score) : super(canvas, context) {
    colorCode = okColorCode;
    width = okWidth;
    height = okHeight;
    x = canvas.width/2;
    y = canvas.height/2;
    canvas.document.on.mouseMove.add((MouseEvent e) {
      x = e.offsetX - 35;
      y = e.offsetY - 35;
      if (x > canvas.width) {
        big();
        x = canvas.width - 20;
      }
      if (x < 0) {
        big();
        x = 20 - width;
      }
      if (y > canvas.height) {
        big();
        y = canvas.height - 20;
      }
      if (y < 0) {
        big();
        y = 20 - height;
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
    accidentCount++;
    score.text = accidentCount.toString();
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

_printCars(cars) {
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

displayTime(LabelElement time) {
  timeInSeconds++;
  if (timeInSeconds == 60) {
    timeInSeconds = 0;
    timeInMinutes++;
  }
  time.text = '${timeInMinutes} : ${timeInSeconds}';
}

main() {
  LabelElement score = document.query('#score');
  LabelElement time = document.query('#time');
  
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

  var redCar = new RedCar(canvas, context, audioManager, score);
  // Redraw every carCount ms.
  new Timer.repeating(carCount < 20 ? carCount : carCount - 16,
    (t) => draw(context, cars, redCar));
  
  new Timer.repeating(1000, (t) => displayTime(time));
}

