part of collision_clones;

class Score {
  static const String speedLimit = '2'; // upper limit in random speed
  static const num timeLimit = 3; // in minutes
  static const String localStorageKey = 'best_score_per_speed';

  var score = new Map<String, Map<String, num>>();
  String _currentSpeedLimit;
  num _currentTimeLimit;

  Score() {
    _currentSpeedLimit = speedLimit;
    _currentTimeLimit = timeLimit;
    zero();
  }

  Score.fromMap(Map<String, Map<String, num>> map) {
    _currentSpeedLimit = speedLimit;
    _currentTimeLimit = timeLimit;
    map.forEach((k,v) => score[k] = v);
  }

  Score.fromScore(Score other) {
    _currentSpeedLimit = other.currentSpeedLimit;
    _currentTimeLimit = other.currentTimeLimit;
    update(other.collisionCount, other.minutes, other.seconds);
  }

  String get currentSpeedLimit => _currentSpeedLimit;
  set currentSpeedLimit(String speed) {
    _currentSpeedLimit = speed;
    zero();
  }

  num get currentTimeLimit => _currentTimeLimit;
  set currentTimeLimit(num timeLimit) {
    _currentTimeLimit = timeLimit;
    zero();
  }

  zero() {
    update(0, 0, 0);
  }

  num get collisionCount => score[currentSpeedLimit]['collisionCount'];
  num get minutes => score[currentSpeedLimit]['minutes'];
  num get seconds => score[currentSpeedLimit]['seconds'];
  num get carCount => score[currentSpeedLimit]['carCount'];

  bool load() {
    String bestScoresString = window.localStorage[localStorageKey];
    if (bestScoresString != null) {
      print('load best scores: ${bestScoresString}');
      Map<String, Map<String, num>> bestScoresMap = parse(bestScoresString);
      bestScoresMap.forEach((k,v) => score[k] = v);
      return true;
    }
    return false;
  }

  save() {
    String bestScoresString = stringify(score);
    window.localStorage[localStorageKey] = bestScoresString;
  }

  update(num collisionCount, num minutes, num seconds, [num carCount=0]) {
    var currentScore = score[currentSpeedLimit];
    if (currentScore != null) {
      score[currentSpeedLimit]['collisionCount'] = collisionCount;
      score[currentSpeedLimit]['minutes'] = minutes;
      score[currentSpeedLimit]['seconds'] = seconds;
      score[currentSpeedLimit]['carCount'] = carCount;
    } else {
      var speedScore = new Map<String, num>();
      speedScore['collisionCount'] = collisionCount;
      speedScore['minutes'] = minutes;
      speedScore['seconds'] = seconds;
      speedScore['carCount'] = carCount;
      score[currentSpeedLimit] = speedScore;
    }
  }

  bool betterTimeThan(Score other) {
    // better: longer time played (more difficult)
    num thisSeconds = minutes * 60 + seconds;
    num otherSeconds = other.minutes * 60 + other.seconds;
    if (thisSeconds > otherSeconds) {
      return true;
    }
    return false;
  }

  bool equalTime(Score other) {
    num thisSeconds = minutes * 60 + seconds;
    num otherSeconds = other.minutes * 60 + other.seconds;
    if (thisSeconds == otherSeconds) {
      return true;
    }
    return false;
  }

  bool betterCollisionCountThan(Score other) {
    // better: less collisions
    if (other.minutes == 0 && other.seconds == 0) {
      return true;
    }
    if (collisionCount < other.collisionCount) {
      return true;
    }
    return false;
  }

  bool equalCollisionCount(Score other) {
    if (collisionCount == other.collisionCount) {
      return true;
    }
    return false;
  }

  bool betterCarCountThan(Score other) {
    // better: more cars (more difficult)
    if (carCount > other.carCount) {
      return true;
    }
    return false;
  }

  display() {
    score.forEach((k,v) => print('${k}: ${v}'));
  }

}
