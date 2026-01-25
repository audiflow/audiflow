import 'dart:io';

import 'package:args/args.dart';
import 'package:audiflow_cli/src/commands/pattern_list_command.dart';
import 'package:audiflow_cli/src/commands/pattern_test_command.dart';
import 'package:audiflow_cli/src/commands/season_debug_command.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
    ..addFlag('version', negatable: false, help: 'Show version');

  // Add subcommands
  parser.addCommand('season-debug')
    ..addFlag('json', help: 'Output as JSON')
    ..addOption('pattern', abbr: 'p', help: 'Pattern ID to use');

  parser.addCommand('pattern-test')
    ..addOption('title', abbr: 't', help: 'Episode title to test')
    ..addOption('title-pattern', help: 'Regex pattern for title extraction')
    ..addOption('title-group', help: 'Capture group for title', defaultsTo: '1')
    ..addOption('title-fallback', help: 'Fallback value for title')
    ..addOption('episode-pattern', help: 'Regex pattern for episode number')
    ..addOption('season-number', abbr: 's', help: 'Season number (int or null)')
    ..addOption(
      'episode-number',
      abbr: 'e',
      help: 'Episode number (int or null)',
    );

  parser.addCommand('pattern-list');

  try {
    final results = parser.parse(args);

    if (results['help'] as bool) {
      _printUsage(parser);
      exit(0);
    }

    if (results['version'] as bool) {
      stdout.writeln('audiflow_cli 0.0.1');
      exit(0);
    }

    final command = results.command;
    if (command == null) {
      _printUsage(parser);
      exit(1);
    }

    switch (command.name) {
      case 'season-debug':
        await _runSeasonDebug(command);
      case 'pattern-test':
        _runPatternTest(command);
      case 'pattern-list':
        _runPatternList();
      default:
        stdout.writeln('Unknown command: ${command.name}');
        exit(1);
    }
  } on FormatException catch (e) {
    stdout.writeln('Error: ${e.message}');
    _printUsage(parser);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  stdout.writeln('Usage: dart run audiflow_cli <command> [options]');
  stdout.writeln('');
  stdout.writeln('Commands:');
  stdout.writeln('  season-debug <url>   Test extractors against RSS feed');
  stdout.writeln('  pattern-test         Test patterns against a single title');
  stdout.writeln('  pattern-list         List available patterns');
  stdout.writeln('');
  stdout.writeln('Options:');
  stdout.writeln(parser.usage);
}

Future<void> _runSeasonDebug(ArgResults command) async {
  if (command.rest.isEmpty) {
    stdout.writeln('Error: Feed URL required');
    exit(1);
  }

  final feedUrl = command.rest.first;
  final json = command['json'] as bool;
  final patternId = command['pattern'] as String?;

  final cmd = SeasonDebugCommand(stdout);
  final exitCode = await cmd.run(
    feedUrl: feedUrl,
    patternId: patternId,
    json: json,
  );
  exit(exitCode);
}

void _runPatternTest(ArgResults command) {
  final title = command['title'] as String?;
  if (title == null) {
    stdout.writeln('Error: --title is required');
    exit(1);
  }

  final titlePattern = command['title-pattern'] as String?;
  final titleGroup = int.tryParse(command['title-group'] as String) ?? 1;
  final titleFallback = command['title-fallback'] as String?;
  final episodePattern = command['episode-pattern'] as String?;

  final seasonNumberStr = command['season-number'] as String?;
  final seasonNumber = seasonNumberStr == null
      ? null
      : int.tryParse(seasonNumberStr);

  final episodeNumberStr = command['episode-number'] as String?;
  final episodeNumber = episodeNumberStr == null
      ? null
      : int.tryParse(episodeNumberStr);

  final cmd = PatternTestCommand(stdout);
  final exitCode = cmd.run(
    title: title,
    titlePattern: titlePattern,
    titleGroup: titleGroup,
    titleFallback: titleFallback,
    episodePattern: episodePattern,
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
  );
  exit(exitCode);
}

void _runPatternList() {
  final cmd = PatternListCommand(stdout);
  final exitCode = cmd.run();
  exit(exitCode);
}
