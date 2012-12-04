part of collision_clones;

class Score {
  static const String startSpeed = '2';
  static const num timeLimit = 3; // in minutes
  static const String localStorageKey = 'best_scores_per_speed';

  var score = new Map<String, Map<String, num>>();
  String _currentSpeed;
  num _currentTimeLimit;

  Score() {
    _currentSpeed = startSpeed;
    _currentTimeLimit = timeLimit;
    zero();
  }

  Score.fromMap(Map<String, Map<String, num>> map) {
    _currentSpeed = startSpeed;
    _currentTimeLimit = timeLimit;
    map.forEach((k,v) => score[k] = v);
  }

  Score.fromScore(Score other) {
    _currentSpeed = other.currentSpeed;
    _currentTimeLimit = other.currentTimeLimit;
    update(other.collisionCount, other.minutes, other.seconds);
  }

  String get currentSpeed => _currentSpeed;
  set currentSpeed(String speed) {
    _currentSpeed = speed;
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

  num get collisionCount => score[currentSpeed]['collisionCount'];
  num get minutes => score[currentSpeed]['minutes'];
  num get seconds => score[currentSpeed]['seconds'];
  num get carCount => score[currentSpeed]['carCount'];

  bool load() {
    String bestScoresString = window.localStorage[localStorageKey];
    if (bestScoresString != null) {
      print('load best scores: ${bestScoresString}');
      Map<String, Map<String, num>> bestScoresMap = JSON.parse(bestScoresString);
      bestScoresMap.forEach((k,v) => score[k] = v);
      return true;
    }
    return false;
  }

  save() {
    String bestScoresString = JSON.stringify(score);
    print('save bests scores: ${bestScoresString}');
    window.localStorage[localStorageKey] = bestScoresString;
  }

  update(num collisionCount, num minutes, num seconds, [num carCount]) {
    var currentScore = score[currentSpeed];
    if (currentScore != null) {
      score[currentSpeed]['collisionCount'] = collisionCount;
      score[currentSpeed]['minutes'] = minutes;
      score[currentSpeed]['seconds'] = seconds;
      if (carCount != null) {
        score[currentSpeed]['carCount'] = carCount;
      }
    } else {
      var speedScore = new Map<String, num>();
      speedScore['collisionCount'] = collisionCount;
      speedScore['minutes'] = minutes;
      speedScore['seconds'] = seconds;
      if (carCount != null) {
        speedScore['carCount'] = carCount;
      }
      score[currentSpeed] = speedScore;
    }
  }

  bool betterTimeThan(Score other) {
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
    if (carCount > other.carCount) {
      return true;
    }
    return false;
  }

  display() {
    score.forEach((k,v) => print('${k}: ${v}'));
  }

}
