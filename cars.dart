part of game_cars;

class Car {
  static const num speed = 2;

  num x;
  num y;
  num width;
  num height;

  num dx;
  num dy;

  CanvasElement canvas;
  CanvasRenderingContext2D context;

  String colorCode;

  Car(this.canvas) {
    context = canvas.getContext('2d');
    dx = randomNum(speed);
    dy = randomNum(speed);

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

class RedCar extends Car {
  static const num bigWidth = 90;
  static const num bigHeight = 36;
  static const String bigColorCode = '#ff0000';

  static const num smallWidth = 35;
  static const num smallHeight = 14;
  static const String smallColorCode = '#000000';

  AudioManager audioManager;
  int collisionCount = 0;

  bool small = false;
  bool get big => !small;

  RedCar(canvas, this.audioManager) : super(canvas) {
    colorCode = bigColorCode;
    width = bigWidth;
    height = bigHeight;
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

  bigger() {
    if (small) {
      small = false;
      colorCode = bigColorCode;
      width = bigWidth;
      height = bigHeight;
    }
  }

  smaller() {
    if (big) {
      small = true;
      //audioManager.playClipFromSource('game', 'collision');
      audioManager.playClipFromSourceIn(0.0, 'game', 'collision');
      colorCode = smallColorCode;
      width = smallWidth;
      height = smallHeight;
      collisionCount++;
    }
  }

  collision(Car car) {
    if (big) {
      if (car.x < x  && car.y < y) {
        if (car.x + car.width >= x && car.y + car.height >= y) {
          smaller();
        }
      } else if (car.x > x  && car.y < y) {
        if (car.x <= x + width && car.y + car.height >= y) {
          smaller();
        }
      } else if (car.x < x  && car.y > y) {
        if (car.x + car.width >= x && car.y <= y + height) {
          smaller();
        }
      } else if (car.x > x  && car.y > y) {
        if (car.x <= x + width && car.y <= y + height) {
          smaller();
        }
      }
    }
  }

}
