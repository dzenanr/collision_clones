part of collision_clones;

abstract class RoundedCornerRectangle {
  num x;
  num y;
  num width;
  num height;

  String colorCode;
  String label = '';

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  num fontSize = 12;

  RoundedCornerRectangle(this.canvas) {
    context = canvas.getContext('2d');

    width = 75;
    height = 30;
    var diagramWidth = canvas.width.toDouble();
    var diagramHeight = canvas.height.toDouble();
    x = randomNum(diagramWidth - width);
    y = randomNum(diagramHeight - height);

    colorCode = randomColorCode();
  }

  roundedCorners(context, sx, sy, ex, ey, r) {
    // based on
    // http://stackoverflow.com/questions/1255512/how-to-draw-a-rounded-rectangle-on-html-canvas
    var r2d = PI/180;
    //ensure that the radius isn't too large for x
    if ((ex - sx) - (2 * r) < 0) {r = (( ex - sx ) / 2);}
    //ensure that the radius isn't too large for y
    if ((ey - sy) - (2 * r) < 0 ) {r = ((ey - sy) / 2 );}
    context.moveTo(sx + r, sy);
    context.lineTo(ex - r, sy);
    context.arc(ex - r, sy + r, r, r2d * 270, r2d * 360, false);
    context.lineTo(ex, ey - r);
    context.arc(ex - r, ey - r, r, r2d * 0, r2d * 90, false);
    context.lineTo(sx + r, ey);
    context.arc(sx + r, ey - r, r, r2d * 90, r2d * 180, false);
    context.lineTo(sx, sy + r);
    context.arc(sx + r, sy + r, r, r2d * 180, r2d * 270, false);
}

  draw() {
    context.beginPath();
    context.fillStyle = colorCode;
    context.strokeStyle = 'black';
    context.lineWidth = 2;
    //context.rect(x, y, width, height);
    roundedCorners(context, x, y, x + width, y + height, 10);
    context.fill();
    context.stroke();
    context.closePath();
    // wheels
    context.beginPath();
    context.fillStyle = '#000000';
    context.rect(x + 12, y - 3, 14, 6);
    context.rect(x + width - 26, y - 3, 14, 6);
    context.rect(x + 12, y + height - 3, 14, 6);
    context.rect(x + width - 26, y + height - 3, 14, 6);
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

class Car extends RoundedCornerRectangle {
  static const String gitClone = 'git clone';

  String speed;
  num dx;
  num dy;

  Car(canvas, this.speed) : super(canvas) {
    var speedNumber = int.parse(speed);
    dx = randomNum(speedNumber);
    dy = randomNum(speedNumber);
  }

  move(RedCar redCar, List<Car> cars) {
    x += dx;
    y += dy;
    if (redCar.big) {
      redCar.collision(this);
    }
    for (Car car in cars) {
      if (car != this) {
        car.collision(this);
      }
    }
    if (x > canvas.width || x < 0) dx = -dx;
    if (y > canvas.height || y < 0) dy = -dy;
  }

  collision(Car car) {
    if (car.x < x  && car.y < y) {
      if (car.x + car.width >= x && car.y + car.height >= y) {
        dx = -dx; dy = -dy;
        car.dx = -car.dx; car.dy = -car.dy;
      }
    } else if (car.x > x  && car.y < y) {
      if (car.x <= x + width && car.y + car.height >= y) {
        dx = -dx; dy = -dy;
        car.dx = -car.dx; car.dy = -car.dy;
      }
    } else if (car.x < x  && car.y > y) {
      if (car.x + car.width >= x && car.y <= y + height) {
        dx = -dx; dy = -dy;
        car.dx = -car.dx; car.dy = -car.dy;
      }
    } else if (car.x > x  && car.y > y) {
      if (car.x <= x + width && car.y <= y + height) {
        dx = -dx; dy = -dy;
        car.dx = -car.dx; car.dy = -car.dy;
      }
    }
  }

}

class RedCar extends RoundedCornerRectangle {
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
