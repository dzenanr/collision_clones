part of game_cars;

Map<String, String> colorMap() {
  var colors = new Map<String, String>();
  colors['black']  = '#000000';
  colors['blue']   = '#0000ff';
  colors['brown']  = '#963939';
  colors['gray']   = '#909090';
  colors['green']  = '#009000';
  colors['orange'] = '#ff6f00';
  colors['white']  = '#ffffff';
  colors['yellow'] = '#ffff00';
  return colors;
}

List colorList() {
  return
  ['black', 'blue', 'brown', 'gray', 'green', 'orange', 'red', 'white', 'yellow'];
}

String randomColor() => randomListElement(colorList());

String randomColorCode() => colorMap()[randomColor()];
