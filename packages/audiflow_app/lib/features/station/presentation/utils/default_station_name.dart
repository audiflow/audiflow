/// The name a new station starts with: [label] for the smallest number
/// no existing station uses, so deleting "Station 2" frees that name.
String defaultStationName(
  Iterable<String> existingNames,
  String Function(int number) label,
) {
  final taken = existingNames.map((name) => name.trim()).toSet();
  var number = 1;
  while (taken.contains(label(number))) {
    number++;
  }
  return label(number);
}
