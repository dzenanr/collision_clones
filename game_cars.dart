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

  CanvasElement canvas;
  CanvasRenderingContext2D context;

  String colorCode;

  Car(this.canvas, this.context) {
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

}

class RedCar extends Car {

  RedCar(canvas, context) : super(canvas, context) {
    colorCode = '#ff0000';
    width = 120;
    height = 48;
    x = canvas.width/2;
    y = canvas.height/2;
  }
}

draw(context, cars) {
  clear() {
    context.fillStyle = "#ffffff";
    context.fillRect(0, 0, context.canvas.width, context.canvas.height);
  }

  clear();
  var i;
  for (var i = 0; i <cars.length; i++) {
    cars[i].draw();
  }
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
  cars.add(redCar);
  for (var i = 0; i < cars.length; i++) {
    var car = cars[i];
    print('x: ${car.x}, y: ${car.y}, width: ${car.width}, height: ${car.height}');
  }
  draw(context, cars);
  // Redraw every carCount ms.
  //new Timer.repeating(carCount < 20 ? carCount : carCount - 8,
  //    (t) => draw(context, cars));
}

