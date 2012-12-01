part of collision_clones;

abstract class Rectangle {
  num x;
  num y;
  num width;
  num height;

  String colorCode;
  String label = '';

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  num fontSize = 12;

  Rectangle(this.canvas) {
    context = canvas.getContext('2d');

    width = 75;
    height = 30;
    var diagramWidth = canvas.width.toDouble();
    var diagramHeight = canvas.height.toDouble();
    x = randomNum(diagramWidth - width);
    y = randomNum(diagramHeight - height);

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
    // label
    context.beginPath();
    context.font = 'bold ${fontSize}px sans-serif';
    context.textAlign = 'start';
    context.textBaseline = 'top';
    context.fillText(label, x + 4, y + 4, width - label.length - 4);
    context.closePath();
  }

}

class Car extends Rectangle {
  num speed;
  num dx;
  num dy;

  Car(canvas, this.speed) : super(canvas) {
    dx = randomNum(speed);
    dy = randomNum(speed);
  }

  move(RedCar redCar) {
    x += dx;
    y += dy;
    if (redCar.big) {
      redCar.collision(this);
    }
    if (x > canvas.width || x < 0) dx = -dx;
    if (y > canvas.height || y < 0) dy = -dy;
  }

}

class RedCar extends Rectangle {
  static const num bigWidth = 90;
  static const num bigHeight = 36;
  static const String bigColorCode = '#ff0000';

  static const num smallWidth = 35;
  static const num smallHeight = 14;
  static const String smallColorCode = '#000000';

  AudioManager audioManager;
  num collisionCount = 0;

  bool small = false;
  bool get big => !small;

  var _gitCommands = new List<String>();

  RedCar(canvas, this.audioManager) : super(canvas) {
    colorCode = bigColorCode;
    width = bigWidth;
    height = bigHeight;
    label = 'GitHub';
    canvas.document.on.mouseMove.add((MouseEvent e) {
      x = e.offsetX - 35;
      y = e.offsetY - 35;
      if (x > canvas.width) {
        bigger();
        x = canvas.width - 20;
      }
      if (x < 0) {
        bigger();
        x = 20 - width;
      }
      if (y > canvas.height) {
        bigger();
        y = canvas.height - 20;
      }
      if (y < 0) {
        bigger();
        y = 20 - height;
      }
    });
  }

  List<String> get gitCommands => _gitCommands;

  addGitCommand(String gitCommand) {
    if (!_gitCommands.contains(gitCommand)) {
      _gitCommands.add(gitCommand);
    }
  }

  clearGitCommands() {
    _gitCommands.clear();
  }

  bigger() {
    if (small) {
      small = false;
      colorCode = bigColorCode;
      width = bigWidth;
      height = bigHeight;
    }
  }

  smaller(Car car) {
    if (big) {
      small = true;
      audioManager.playClipFromSourceIn(0.0, 'game', 'collision');
      colorCode = smallColorCode;
      width = smallWidth;
      height = smallHeight;
      collisionCount++;

      String gitCommand = randomGit();
      car.label = gitCommand;
      addGitCommand(gitCommand);
    }
  }

  collision(Car car) {
    if (big) {
      if (car.x < x  && car.y < y) {
        if (car.x + car.width >= x && car.y + car.height >= y) {
          smaller(car);
        }
      } else if (car.x > x  && car.y < y) {
        if (car.x <= x + width && car.y + car.height >= y) {
          smaller(car);
        }
      } else if (car.x < x  && car.y > y) {
        if (car.x + car.width >= x && car.y <= y + height) {
          smaller(car);
        }
      } else if (car.x > x  && car.y > y) {
        if (car.x <= x + width && car.y <= y + height) {
          smaller(car);
        }
      }
    }
  }

}
