part of collision_clones;

Map<String, String> colorMap() {
  return {
    'azure':      '#f0ffff',
    'beige':      '#f5f5dc',
    'black':      '#000000',
    'blue':       '#0000ff' ,
    'brown':      '#963939',
    'chocolate':  '#d2691e',
    'coral':      '#ff7f50',
    'gold':       '#ffd700',
    'gray':       '#909090',
    'green':      '#009000',
    'ivory':      '#fffff0',
    'khaki':      '#f0e68c',
    'linen':      '#faf0e6',
    'maroon':     '#800000',
    'orange':     '#ff6f00',
    'silver':     '#c0c0c0',
    'wheat':      '#f5deb3',
    'white':      '#ffffff',
    'yellow':     '#ffff00'
  };
}

List<String> colorList() {
  return [
    'azure',
    'beige',
    'black',
    'blue',
    'brown',
    'chocolate',
    'coral',
    'gold',
    'gray',
    'green',
    'ivory',
    'khaki',
    'linen',
    'maroon',
    'orange',
    'silver',
    'wheat',
    'white',
    'yellow'
  ];
}

String randomColor() => randomListElement(colorList());

String randomColorCode() => colorMap()[randomColor()];
