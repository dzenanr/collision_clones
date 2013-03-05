part of collision_clones;

class BestScoreSection {

  LabelElement bestSpeedLimitLabel = document.query('#best-speed-limit');
  LabelElement bestCollisionCountLabel = document.query('#best-collision-count');
  LabelElement bestTimeLabel = document.query('#best-time');
  LabelElement bestCarCountLabel = document.query('#best-car-count');

  Score bestScore;

  BestScoreSection(this.bestScore);

  display() {
    bestSpeedLimitLabel.text = bestScore.currentSpeedLimit;
    bestCollisionCountLabel.text = bestScore.collisionCount.toString();
    bestTimeLabel.text = '${bestScore.minutes} : ${bestScore.seconds}';
    bestCarCountLabel.text = bestScore.carCount.toString();
  }

}

class Board {
  const num carCount = 8;
  const String play = 'Play';
  const String stop = 'Stop';
  const String restart = 'Restart';

  CanvasElement canvas = document.query('#canvas');
  LabelElement carCountLabel = document.query('#car-count');

  List<Car> cars;
  var redCar;
  var score = new Score();
  bool stopped = true;

  Board() {
    var bestScore = new Score();
    var bestScoreSection = new BestScoreSection(bestScore);
    if (bestScore.load()) {
      bestScoreSection.display();
    }

    redCar = new RedCar(canvas);
    cars = new List();
    for (var i = 0; i < carCount; i++) {
      var car = new Car(canvas, score.currentSpeedLimit);
      cars.add(car);
    }
    displayCars();

    InputElement speedLimitInput = document.query('#speed-limit');
    speedLimitInput.width = 2;
    speedLimitInput.value = score.currentSpeedLimit;
    speedLimitInput.onInput.listen((Event e) {
      score.currentSpeedLimit = speedLimitInput.value;
      bestScore.currentSpeedLimit = speedLimitInput.value;
      bestScore.load();
      bestScoreSection.display();
      redCar.collisionCount = 0;
      redCar.movable = false;
      for (Car car in cars) {
        car.dx = randomNum(speedLimitInput.valueAsNumber);
        car.dy = randomNum(speedLimitInput.valueAsNumber);
      }
    });
    LabelElement collisionCountLabel = document.query('#collision-count');
    LabelElement timeLabel = document.query('#time');
    InputElement timeLimitInput = document.query('#time-limit');
    timeLimitInput.width = 2;
    timeLimitInput.valueAsNumber = Score.timeLimit;
    timeLimitInput.onInput.listen((Event e) {
      score.currentTimeLimit = timeLimitInput.valueAsNumber;
      bestScore.load();
      bestScoreSection.display();
      redCar.collisionCount = 0;
      redCar.movable = false;
      for (Car car in cars) {
        car.dx = randomNum(timeLimitInput.valueAsNumber);
        car.dy = randomNum(timeLimitInput.valueAsNumber);
      }
    });

    LabelElement msgLabel = document.query('#msg');
    msgLabel.text = ' ';
    ButtonElement pauseButton = document.query('#pause');
    pauseButton.onClick.listen((MouseEvent e) {
      if (stopped) {
        stopped = false;
        if (pauseButton.text == restart) {
          score.zero();
          redCar.collisionCount = 0;
          redCar.movable = true;
          msgLabel.text = ' ';
          redCar.clearGitCommands();
        }
        pauseButton.text = stop;
      } else {
        stopped = true;
        pauseButton.text = play;
        bestScoreSection.display();
        redCar.movable = false;
      }
    });

    Element gitSection = document.query('#git');

    // Redraw every carCount ms.
    new Timer.repeating(const Duration(milliseconds: 10),
        (t) => stopped ? null : displayCars());

    // active time
    new Timer.repeating(const Duration(milliseconds: 1000), (t) {
      if (!stopped && redCar.big) {
        gitSection.innerHtml = gitUl(redCar.gitCommands);

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
          pauseButton.text = 'Restart';
          msgLabel.text = 'You lost.';
          if (score.betterTimeThan(bestScore)) {
            bestScore.update(collisionCount, minutes, seconds, cars.length);
            bestScore.save();
            bestScoreSection.display();
          }
        } else if (minutes == score.currentTimeLimit) {
          stopped = true;
          pauseButton.text = 'Restart';
          msgLabel.text = 'You won.';
          if (score.betterTimeThan(bestScore)) {
            bestScore.update(collisionCount, minutes, seconds, cars.length);
            bestScore.save();
            bestScoreSection.display();
          } else if (score.equalTime(bestScore)) {
            if (score.betterCollisionCountThan(bestScore)) {
              bestScore.update(collisionCount, minutes, seconds, cars.length);
              bestScore.save();
              bestScoreSection.display();
            } else if (score.equalCollisionCount(bestScore) &&
                score.betterCarCountThan(bestScore)) {
              bestScore.update(collisionCount, minutes, seconds, cars.length);
              bestScore.save();
              bestScoreSection.display();
            }
          }
        }
      }
    });

  }

  displayCars() {
    clear() {
      CanvasRenderingContext2D context = canvas.getContext('2d');
      context.fillStyle = "#ffffff";
      context.fillRect(0, 0, context.canvas.width, context.canvas.height);
    }

    clear();
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
        // update skipped rarely; when skipped, many cars created
        if (random != 13.0 && random != score.minutes * 60 + score.seconds) {
          score.update(redCar.collisionCount, score.minutes, score.seconds,
              cars.length);
        }
        var car = new Car(canvas, score.currentSpeedLimit);
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

}
