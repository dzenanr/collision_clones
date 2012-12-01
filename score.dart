part of collision_clones;

class Score {
  static const num startSpeed = 2;

  var score = new Map<num, Map<String, num>>();
  num _currentSpeed;

  Score() {
    _currentSpeed = startSpeed;
    zero();
  }

  Score.fromMap(Map<num, Map<String, num>> map) {
    _currentSpeed = startSpeed;
    score = map;
  }

  Score.fromScore(Score other) {
    _currentSpeed = other.currentSpeed;
    update(other.collisionCount, other.minutes, other.seconds);
  }

  num get currentSpeed => _currentSpeed;
  set currentSpeed(num speed) {
    _currentSpeed = speed;
    zero();
  }

  zero() {
    update(0, 0, 0);
  }

  num get collisionCount => score[currentSpeed]['collisionCount'];
  num get minutes => score[currentSpeed]['minutes'];
  num get seconds => score[currentSpeed]['seconds'];

  update(num collisionCount, num minutes, num seconds) {
    var currentScore = score[currentSpeed];
    if (currentScore != null) {
      score[currentSpeed]['collisionCount'] = collisionCount;
      score[currentSpeed]['minutes'] = minutes;
      score[currentSpeed]['seconds'] = seconds;
    } else {
      var speedScore = new Map<String, num>();
      speedScore['collisionCount'] = collisionCount;
      speedScore['minutes'] = minutes;
      speedScore['seconds'] = seconds;
      score[currentSpeed] = speedScore;
    }

    /*
    var speedScore = new Map<String, num>();
    speedScore['collisionCount'] = collisionCount;
    speedScore['minutes'] = minutes;
    speedScore['seconds'] = seconds;
    score.putIfAbsent(currentSpeed, () => speedScore);
    */
  }

  /*
  Map<String, num> get currentSpeedScore => score[currentSpeed];

  set collisionCount(num collisionCount) =>
      score[currentSpeed]['collisionCount'] = collisionCount;
  set minutes(num minutes) =>
      score[currentSpeed]['minutes'] = minutes;
  set seconds(num seconds) =>
      score[currentSpeed]['seconds'] = seconds;
  */

  display() {
    score.forEach((k,v) => print('${k}: ${v}'));
  }

}
