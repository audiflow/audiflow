import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    printEmojis: false,
    colors: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
