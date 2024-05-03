import 'package:logger/logger.dart';

var logger = Logger(
    printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 50,
        colors: true,
        printEmojis: true,
        printTime: true,
        levelColors: {Level.debug: const AnsiColor.bg(7)}));
