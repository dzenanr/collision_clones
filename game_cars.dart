library game_cars;

import 'dart:html';
import 'dart:isolate';
import 'dart:math';

import 'package:simple_audio/simple_audio.dart';

part 'cars.dart';
part 'color.dart';
part 'random.dart';

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
  const int carCount = 8;
  const String play = 'Play';
  const String stop = 'Stop';
  const String restart = 'Restart';

  int timeInMinutes = 0;
  int timeInSeconds = 0;
  bool stopped = true;

  var audioManager = new AudioManager('${getDemoBaseURL()}/sound');
  AudioSource audioSource = audioManager.makeSource('game');
  audioSource.positional = false;
  //AudioClip collisionSound = audioManager.makeClip('collision', 'beep.mp3');
  AudioClip collisionSound = audioManager.makeClip('collision', 'collision.ogg');
  collisionSound.load();

  CanvasElement canvas = document.query('#canvas');
  CanvasRenderingContext2D context = canvas.getContext('2d');
  var redCar = new RedCar(canvas, audioManager);
  List<Car> cars;

  LabelElement collisionCountLabel = document.query('#collision');
  LabelElement timeMinSecLabel = document.query('#time');
  LabelElement lostLabel = document.query('#lost');
  lostLabel.text = ' ';
  InputElement speedInput = document.query('#speed');
  speedInput.valueAsNumber = Car.speed;
  speedInput.on.input.add((Event e) {
    for (Car car in cars) {
      car.dx = randomNum(speedInput.valueAsNumber);
      car.dy = randomNum(speedInput.valueAsNumber);
    }
  });
  ButtonElement stopButton = document.query('#stop');
  stopButton.on.click.add((MouseEvent e) {
    if (stopped) {
      stopped = false;
      if (stopButton.text == restart) {
        redCar.collisionCount = 0;
        timeInMinutes = 0;
        timeInSeconds = 0;
        lostLabel.text = ' ';
      }
      stopButton.text = stop;
    } else {
      stopped = true;
      stopButton.text = play;
    }
  });

  cars = new List();
  for (var i = 0; i < carCount; i++) {
    var car = new Car(canvas);
    cars.add(car);
  }

  displayCars() {
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

  displayCars();

  // Redraw every carCount ms.
  new Timer.repeating(carCount < 20 ? carCount : carCount - 16,
    (t) => stopped ? null : displayCars());

  // active time
  new Timer.repeating(1000, (t) {
    if (!stopped && redCar.big) {
      int collisionCount = redCar.collisionCount;
      collisionCountLabel.text = collisionCount.toString();
      timeInSeconds++;
      if (timeInSeconds == 60) {
        timeInSeconds = 0;
        timeInMinutes++;
      }
      if (collisionCount > timeInMinutes * 60 + timeInSeconds) {
        stopped = true;
        stopButton.text = 'Restart';
        lostLabel.text = 'You lost.';
      }
      timeMinSecLabel.text = '${timeInMinutes} : ${timeInSeconds}';
    }
  });

}

