part of collision_clones;

class Score {
  static const String startSpeed = '2';
  static const String localStorageKey = 'best scores for collision clones';

  var score = new Map<String, Map<String, num>>();
  String _currentSpeed;

  Score() {
    _currentSpeed = startSpeed;
    zero();
  }

  Score.fromMap(Map<String, Map<String, num>> map) {
    _currentSpeed = startSpeed;
    //score = map;
    map.forEach((k,v) => score[k] = v);
  }

  Score.fromScore(Score other) {
    _currentSpeed = other.currentSpeed;
    update(other.collisionCount, other.minutes, other.seconds);
  }

  String get currentSpeed => _currentSpeed;
  set currentSpeed(String speed) {
    _currentSpeed = speed;
    zero();
  }

  zero() {
    update(0, 0, 0);
  }

  num get collisionCount => score[currentSpeed]['collisionCount'];
  num get minutes => score[currentSpeed]['minutes'];
  num get seconds => score[currentSpeed]['seconds'];

  load() {
    String bestScoresString = window.localStorage[localStorageKey];
    if (bestScoresString != null) {
      print('load best scores: ${bestScoresString}');
      Map<String, Map<String, num>> bestScoresMap = JSON.parse(bestScoresString);
      bestScoresMap.forEach((k,v) => score[k] = v);
    }
  }

  save() {
    String bestScoresString = JSON.stringify(score);
    print('save bests scores: ${bestScoresString}');
    window.localStorage[localStorageKey] = bestScoresString;
  }

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

  bool betterThan(Score other) {
    num thisSeconds = minutes * 60 + seconds;
    num otherSeconds = other.minutes * 60 + other.seconds;
    if (thisSeconds > otherSeconds) {
      return true;
    }
    return false;
  }

  display() {
    score.forEach((k,v) => print('${k}: ${v}'));
  }

}
