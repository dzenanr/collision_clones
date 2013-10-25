part of collision_clones;

class BestScoreSection {

  LabelElement bestSpeedLimitLabel = document.querySelector('#best-speed-limit');
  LabelElement bestCollisionCountLabel = document.querySelector('#best-collision-count');
  LabelElement bestTimeLabel = document.querySelector('#best-time');
  LabelElement bestCarCountLabel = document.querySelector('#best-car-count');

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
  static const num CAR_COUNT = 8;
  static const String PLAY = 'Play';
  static const String STOP = 'Stop';
  static const String RESTART = 'Restart';

  CanvasElement canvas = document.querySelector('#canvas');
  LabelElement carCountLabel = document.querySelector('#car-count');

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
    for (var i = 0; i < CAR_COUNT; i++) {
      var car = new Car(canvas, score.currentSpeedLimit);
      cars.add(car);
    }
    displayCars();

    InputElement speedLimitInput = document.querySelector('#speed-limit');
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
    LabelElement collisionCountLabel = document.querySelector('#collision-count');
    LabelElement timeLabel = document.querySelector('#time');
    InputElement timeLimitInput = document.querySelector('#time-limit');
    timeLimitInput.width = 2;
    timeLimitInput.valueAsNumber = Score.TIME_LIMIT;
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

    LabelElement msgLabel = document.querySelector('#msg');
    msgLabel.text = ' ';
    ButtonElement pauseButton = document.querySelector('#pause');
    pauseButton.onClick.listen((MouseEvent e) {
      if (stopped) {
        stopped = false;
        if (pauseButton.text == RESTART) {
          score.zero();
          redCar.collisionCount = 0;
          redCar.movable = true;
          msgLabel.text = ' ';
          redCar.clearGitCommands();
        }
        pauseButton.text = STOP;
      } else {
        stopped = true;
        pauseButton.text = PLAY;
        bestScoreSection.display();
        redCar.movable = false;
      }
    });

    Element gitSection = document.querySelector('#git');

    // active play time
    new Timer.periodic(const Duration(milliseconds: 1000), (t) {
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

    window.animationFrame.then(gameLoop);
  }

  gameLoop(num delta) {
    stopped ? null : displayCars();
    window.animationFrame.then(gameLoop);
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
