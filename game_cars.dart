library game_cars;

import 'dart:html';
import 'dart:isolate';
import 'dart:math';

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

  RedCar(canvas, context) : super(canvas, context) {
    colorCode = okColorCode;
    width = okWidth;
    height = okHeight;
    x = canvas.width/2;
    y = canvas.height/2;
    canvas.document.on.mouseMove.add((MouseEvent e) {
      x = e.offsetX - 35;
      y = e.offsetY - 35;
      if (x > canvas.width || x < 0) {
        colorCode = okColorCode;
        width = okWidth;
        height = okHeight;
      }
      if (y > canvas.height || y < 0) {
        colorCode = okColorCode;
        width = okWidth;
        height = okHeight;
      }
    });
  }

  collision(Car car) {
    if (car.x >= x && car.x <= x + width) {
      if (car.y >= y && car.y <= y + height) {
        colorCode = nokColorCode;
        width = nokWidth;
        height = nokHeight;
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

main() {
  CanvasElement canvas = document.query('#canvas');
  CanvasRenderingContext2D context = canvas.getContext('2d');
  var cars = new List();
  for (var i = 0; i < carCount; i++) {
    var car = new Car(canvas, context);
    cars.add(car);
  }
  var redCar = new RedCar(canvas, context);
  for (var i = 0; i < cars.length; i++) {
    var car = cars[i];
    print('x: ${car.x}, y: ${car.y}, width: ${car.width}, height: ${car.height}');
  }
  // Redraw every carCount ms.
  new Timer.repeating(carCount < 20 ? carCount : carCount - 16,
    (t) => draw(context, cars, redCar));
}

