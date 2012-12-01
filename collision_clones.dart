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

var score = new Score();

String getDemoBaseURL() {
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

bestScore(LabelElement speedLabel, LabelElement collisionCountLabel,
          LabelElement timeLabel) {
  var bestScore;
  String bestScoreString = window.localStorage['ccbs'];
  if (bestScoreString != null) {
    if (score.collisionCount > 0) {
      Map<num, Map<String, num>> bestScoreMap = JSON.parse(bestScoreString);
      bestScore = new Score.fromMap(bestScoreMap);
      bestScore.currentSpeed = score.currentSpeed;
      num bestSeconds = bestScore.minutes * 60 + bestScore.seconds;
      num best = bestScore.collisionCount / bestSeconds;
      num currentSeconds = score.minutes * 60 + score.seconds;
      num current = score.collisionCount / currentSeconds;
      if (current < best) {
        bestScore.update(score.collisionCount, score.minutes, score.seconds);
        window.localStorage['ccbs'] =
            JSON.stringify(bestScore);
      }
    }
  } else {
    bestScore = new Score.fromScore(score);
    bestScore.display();
    window.localStorage['ccbs'] =
        JSON.stringify(bestScore);
  }
  speedLabel.text = bestScore.currentSpeed.toString();
  collisionCountLabel.text = bestScore.collisionCount.toString();
  timeLabel.text = '${bestScore.minutes} : ${bestScore.seconds}';
}

main() {
  const num carCount = 8;
  const String play = 'Play';
  const String stop = 'Stop';
  const String restart = 'Restart';
  const String gitClone = 'git clone';

  bool stopped = true;

  var audioManager = new AudioManager('${getDemoBaseURL()}/sound');
  AudioSource audioSource = audioManager.makeSource('game');
  audioSource.positional = false;
  AudioClip collisionSound = audioManager.makeClip('collision', 'collision.ogg');
  collisionSound.load();

  CanvasElement canvas = document.query('#canvas');
  CanvasRenderingContext2D context = canvas.getContext('2d');
  var redCar = new RedCar(canvas, audioManager);
  List<Car> cars;

  /*
  LabelElement bestSpeedLabel = document.query('#best-speed');
  LabelElement bestCollisionCountLabel = document.query('#best-collision-count');
  LabelElement bestTimeLabel = document.query('#best-time');
  */

  InputElement speedInput = document.query('#speed');
  speedInput.valueAsNumber = score.currentSpeed;
  speedInput.on.input.add((Event e) {
    score.currentSpeed = speedInput.valueAsNumber;
    redCar.collisionCount = 0;
    //bestScore(bestSpeedLabel, bestCollisionCountLabel, bestTimeLabel);
    for (Car car in cars) {
      car.dx = randomNum(speedInput.valueAsNumber);
      car.dy = randomNum(speedInput.valueAsNumber);
    }
  });
  LabelElement collisionCountLabel = document.query('#collision-count');
  LabelElement timeLabel = document.query('#time');
  LabelElement lostLabel = document.query('#lost');
  lostLabel.text = ' ';
  ButtonElement stopButton = document.query('#stop');
  stopButton.on.click.add((MouseEvent e) {
    if (stopped) {
      stopped = false;
      if (stopButton.text == restart) {
        score.zero();
        redCar.collisionCount = 0;
        lostLabel.text = ' ';
        redCar.clearGitCommands();
      }
      stopButton.text = stop;
    } else {
      stopped = true;
      stopButton.text = play;
    }
  });

  Element gitSection = document.query('#git');

  cars = new List();
  for (var i = 0; i < carCount; i++) {
    var car = new Car(canvas, score.currentSpeed);
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
    if (redCar.collisionCount > 0 &&
        redCar.collisionCount != score.collisionCount) {
      num remainder = redCar.collisionCount % 6;
      if (remainder == 0) {
        score.update(redCar.collisionCount, score.minutes, score.seconds);
        var car = new Car(canvas, score.currentSpeed);
        car.label = gitClone;
        cars.add(car);
        redCar.addGitCommand(gitClone);
      }
    }
  }

  displayCars();

  // Redraw every carCount ms.
  new Timer.repeating(carCount < 20 ? carCount : carCount - 16,
    (t) => stopped ? null : displayCars());

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
      score.update(collisionCount, minutes, seconds);
      collisionCountLabel.text = score.collisionCount.toString();
      timeLabel.text = '${score.minutes} : ${score.seconds}';
      if (collisionCount > minutes * 60 + seconds) {
        stopped = true;
        stopButton.text = 'Restart';
        lostLabel.text = 'You lost.';
        //bestScore(bestSpeedLabel, bestCollisionCountLabel, bestTimeLabel);
      }
    }
  });

}

