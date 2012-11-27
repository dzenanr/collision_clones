part of game_cars;

double randomDouble(double max) {
  double randomDouble = new Random().nextDouble() * max;
  return randomDouble > max ? max : randomDouble;
}

int randomInt(int max) => new Random().nextInt(max);

randomListElement(List list) => list[randomInt(list.length - 1)];
