library collision_clones;

import 'dart:html';
import 'dart:isolate';
import "dart:json";
import 'dart:math';

import 'package:simple_audio/simple_audio.dart';

part 'cars.dart';
part 'color.dart';
part 'git_commands.dart';
part 'random.dart';
part 'score.dart';

String demoBaseUrl() {
  String location = window.location.href;
  int slashIndex = location.lastIndexOf('/');
  if (slashIndex < 0) {
    return '/';
  } else {
    return location.substring(0, slashIndex);
  }
}

DivElement gitDiv(String gitCommand) {
  DivElement gitDiv = new Element.tag('div');
  gitDiv.id = '${gitCommand}';
  gitDiv.innerHTML = '${gitCommand}: ${gitMap()[gitCommand]}';
  return gitDiv;
}

String gitUl(List gitCommands) {
  var ul = '''
      <ul class="target">
    ''';
    for (String gitCommand in gitCommands) {
      ul = '''
        ${ul}
        <li>
          ${gitDiv(gitCommand).outerHTML}
        </li>
      ''';
    }
    ul = '''
      ${ul}
      </ul>
    ''';
  return ul;
}

displayCars(CanvasElement canvas, LabelElement carCountLabel,
            RedCar redCar, List<Car> cars, Score score) {
  clear(CanvasElement canvas) {
    CanvasRenderingContext2D context = canvas.getContext('2d');
    context.fillStyle = "#ffffff";
    context.fillRect(0, 0, context.canvas.width, context.canvas.height);
  }

  clear(canvas);
  var i;
  for (var i = 0; i <cars.length; i++) {
    cars[i].move(redCar, cars);
    cars[i].draw();
  }
  redCar.draw();
  if (redCar.collisionCount > 0 &&
      redCar.collisionCount != score.collisionCount) {
    num remainder = redCar.collisionCount % 6;
    if (remainder == 0) {
      var random = randomNum(score.currentTimeLimit * 60).round();
      if (random != 13.0 && random != score.minutes * 60 + score.seconds) {
        score.update(redCar.collisionCount, score.minutes, score.seconds,
            cars.length);
      }
      var car = new Car(canvas, score.currentSpeed);
      if (car.dx > 0) {
        car.dx++;
      } else {
        car.dx--;
      }
      if (car.dy > 0) {
        car.dy++;
      } else {
        car.dy--;
      }
      car.label = Car.gitClone;
      cars.add(car);
      redCar.addGitCommand(Car.gitClone);
    }
  }
  carCountLabel.text = cars.length.toString();
}

main() {
  const num carCount = 8;
  const String play = 'Play';
  const String stop = 'Stop';
  const String restart = 'Restart';

  bool stopped = true;
  var score = new Score();
  var bestScore = new Score();

  var audioManager = new AudioManager('${demoBaseUrl()}/sound');
  AudioSource audioSource = audioManager.makeSource('game');
  audioSource.positional = false;
  AudioClip collisionSound = audioManager.makeClip('collision', 'collision.ogg');
  collisionSound.load();

  CanvasElement canvas = document.query('#canvas');

  var redCar = new RedCar(canvas, audioManager);
  List<Car> cars;

  LabelElement bestSpeedLabel = document.query('#best-speed');
  LabelElement bestCollisionCountLabel = document.query('#best-collision-count');
  LabelElement bestTimeLabel = document.query('#best-time');
  LabelElement bestCarCountLabel = document.query('#best-car-count');

  showBest() {
    bestSpeedLabel.text = bestScore.currentSpeed;
    bestCollisionCountLabel.text = bestScore.collisionCount.toString();
    bestTimeLabel.text = '${bestScore.minutes} : ${bestScore.seconds}';
    bestCarCountLabel.text = bestScore.carCount.toString();
  }

  InputElement speedInput = document.query('#speed');
  speedInput.width = 2;
  speedInput.value = score.currentSpeed;
  speedInput.on.input.add((Event e) {
    score.currentSpeed = speedInput.value;
    bestScore.currentSpeed = speedInput.value;
    bestScore.load();
    showBest();
    redCar.collisionCount = 0;
    redCar.movable = false;
    for (Car car in cars) {
      car.dx = randomNum(speedInput.valueAsNumber);
      car.dy = randomNum(speedInput.valueAsNumber);
    }
  });
  LabelElement collisionCountLabel = document.query('#collision-count');
  LabelElement timeLabel = document.query('#time');
  InputElement timeLimitInput = document.query('#time-limit');
  timeLimitInput.width = 2;
  timeLimitInput.valueAsNumber = Score.timeLimit;
  timeLimitInput.on.input.add((Event e) {
    score.currentTimeLimit = timeLimitInput.valueAsNumber;
    bestScore.load();
    showBest();
    redCar.collisionCount = 0;
    redCar.movable = false;
    for (Car car in cars) {
      car.dx = randomNum(timeLimitInput.valueAsNumber);
      car.dy = randomNum(timeLimitInput.valueAsNumber);
    }
  });
  LabelElement carCountLabel = document.query('#car-count');

  LabelElement msgLabel = document.query('#msg');
  msgLabel.text = ' ';
  ButtonElement stopButton = document.query('#stop');
  stopButton.on.click.add((MouseEvent e) {
    if (stopped) {
      stopped = false;
      if (stopButton.text == restart) {
        score.zero();
        redCar.collisionCount = 0;
        redCar.movable = true;
        msgLabel.text = ' ';
        redCar.clearGitCommands();
      }
      stopButton.text = stop;
    } else {
      stopped = true;
      stopButton.text = play;
      showBest();
    }
  });

  Element gitSection = document.query('#git');

  if (bestScore.load()) {
    showBest();
  }

  cars = new List();
  for (var i = 0; i < carCount; i++) {
    var car = new Car(canvas, score.currentSpeed);
    cars.add(car);
  }
  displayCars(canvas, carCountLabel, redCar, cars, score);

  // Redraw every carCount ms.
  new Timer.repeating(carCount < 20 ? carCount : carCount - 16,
    (t) => stopped ? null :
      displayCars(canvas, carCountLabel, redCar, cars, score));

  // active time
  new Timer.repeating(1000, (t) {
    if (!stopped && redCar.big) {
      gitSection.innerHTML = gitUl(redCar.gitCommands);

      var collisionCount = redCar.collisionCount;
      var minutes = score.minutes;
      var seconds = score.seconds;
      if (seconds + 1 == 60) {
        seconds = 0;
        minutes++;
      } else {
        seconds++;
      }
      score.update(collisionCount, minutes, seconds, cars.length);
      collisionCountLabel.text = score.collisionCount.toString();
      timeLabel.text = '${score.minutes} : ${score.seconds}';
      if (collisionCount > minutes * 60 + seconds) {
        stopped = true;
        stopButton.text = 'Restart';
        msgLabel.text = 'You lost.';
        if (score.betterTimeThan(bestScore)) {
          bestScore.update(collisionCount, minutes, seconds, cars.length);
          bestScore.save();
          showBest();
        }
      } else if (minutes == score.currentTimeLimit) {
        stopped = true;
        stopButton.text = 'Restart';
        msgLabel.text = 'You won.';
        if (score.betterTimeThan(bestScore)) {
          bestScore.update(collisionCount, minutes, seconds, cars.length);
          bestScore.save();
          showBest();
        } else if (score.equalTime(bestScore)) {
          if (score.betterCollisionCountThan(bestScore)) {
            bestScore.update(collisionCount, minutes, seconds, cars.length);
            bestScore.save();
            showBest();
          } else if (score.equalTime(bestScore) &&
              score.betterCarCountThan(bestScore)) {
            bestScore.update(collisionCount, minutes, seconds, cars.length);
            bestScore.save();
            showBest();
          }
        }
      }
    }
  });

}

