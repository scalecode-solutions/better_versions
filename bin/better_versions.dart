#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:better_versions/better_versions.dart';
import 'package:flutter/foundation.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Print this usage information.', negatable: false)
    ..addFlag('dry-run', help: 'Print what would be done without making changes.', negatable: false)
    ..addOption('format', abbr: 'f', help: 'Version format (semantic, date, timestamp, build, custom)')
    ..addOption('custom-format', help: 'Custom format string (use with --format=custom)')
    ..addFlag('major', help: 'Bump the major version (1.0.0 -> 2.0.0)', negatable: false)
    ..addFlag('minor', help: 'Bump the minor version (0.1.0 -> 0.2.0)', negatable: false)
    ..addFlag('patch', help: 'Bump the patch version (0.0.1 -> 0.0.2)', negatable: false)
    ..addOption('pre-release', help: 'Set a pre-release version (e.g., alpha, beta.1, rc.2)')
    ..addFlag('remove-pre-release', help: 'Remove pre-release version', negatable: false)
    ..addOption('build-number', help: 'Set a specific build number')
    ..addFlag('auto-increment', help: 'Auto-increment build number', negatable: false)
    ..addOption('project-dir', help: 'Project directory (defaults to current directory)', defaultsTo: '.');

  try {
    final results = parser.parse(arguments);
    
    if (results['help'] as bool || arguments.isEmpty) {
      printUsage(parser);
      return;
    }
    
    final projectDir = results['project-dir'] as String;
    final dryRun = results['dry-run'] as bool;
    
    // Determine version format
    final format = _determineVersionFormat(
      format: results['format'] as String?,
      customFormat: results['custom-format'] as String?,
    );
    
    final manager = VersionManager(
      projectRoot: projectDir,
      versionFormat: format,
      dryRun: dryRun,
    );
    
    // Handle version bumping
    if (results['major'] as bool) {
      await manager.bumpMajor();
    } else if (results['minor'] as bool) {
      await manager.bumpMinor();
    } else if (results['patch'] as bool) {
      await manager.bumpPatch();
    }
    
    // Handle pre-release versions
    if (results['pre-release'] != null) {
      await manager.setPreRelease(results['pre-release'] as String);
    } else if (results['remove-pre-release'] as bool) {
      await manager.removePreRelease();
    }
    
    // Handle build number
    if (results['build-number'] != null) {
      final buildNumber = int.tryParse(results['build-number'] as String);
      if (buildNumber == null) {
        if (kDebugMode) {
          print('Error: Invalid build number');
        }
        exitCode = 1;
        return;
      }
      await manager.updateVersion(buildNumber: buildNumber);
    } else if (results['auto-increment'] as bool) {
      await manager.updateVersion(autoIncrementBuild: true);
    }
    
    // If no specific action was taken, just show the current version
    if (!results.wasParsed('major') &&
        !results.wasParsed('minor') &&
        !results.wasParsed('patch') &&
        !results.wasParsed('pre-release') &&
        !results.wasParsed('remove-pre-release') &&
        !results.wasParsed('build-number') &&
        !results.wasParsed('auto-increment')) {
      final current = await manager.getCurrentVersion();
      if (kDebugMode) {
        print('Current version: ${current['major']}.${current['minor']}.${current['patch']}');
      }
      if (current['preRelease'] != null) {
        if (kDebugMode) {
          print('Pre-release: ${current['preRelease']}');
        }
      }
      if (current['buildMetadata'] != null) {
        if (kDebugMode) {
          print('Build metadata: ${current['buildMetadata']}');
        }
      }
    }
  } on FormatException catch (e) {
    if (kDebugMode) {
      print('Error: ${e.message}');
    }
    printUsage(parser);
    exitCode = 1;
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
    exitCode = 1;
  }
}

VersionFormat _determineVersionFormat({
  String? format,
  String? customFormat,
}) {
  switch (format?.toLowerCase()) {
    case 'semantic':
      return VersionFormat.semantic;
    case 'date':
      return VersionFormat.dateBased;
    case 'timestamp':
      return VersionFormat.timestamp;
    case 'build':
      return VersionFormat.buildNumber;
    case 'custom':
      if (customFormat == null) {
        throw FormatException('--custom-format is required when --format=custom');
      }
      return VersionFormat.custom(customFormat);
    case null:
      return VersionFormat.semantic;
    default:
      throw FormatException('Unknown format: $format');
  }
}

void printUsage(ArgParser parser) {
  if (kDebugMode) {
    print('''Better Versions - A powerful version management tool for Flutter/Dart

Usage: better_versions [options]

Options:
${parser.usage}

Examples:
  better_versions --major                      # Bump major version (1.0.0 -> 2.0.0)
  better_versions --minor                      # Bump minor version (0.1.0 -> 0.2.0)
  better_versions --patch                      # Bump patch version (0.0.1 -> 0.0.2)
  better_versions --pre-release=beta.1         # Set pre-release version
  better_versions --remove-pre-release          # Remove pre-release version
  better_versions --auto-increment              # Auto-increment build number
  better_versions --build-number=42             # Set specific build number
  better_versions --format=date                # Use date-based versioning (MMDD)
  better_versions --format=timestamp           # Use timestamp-based versioning (YYMMDDHHmm)
  better_versions --format=custom --custom-format='{yyyy}.{MM}.{dd}+{build}' # Custom format
  better_versions --dry-run                    # Show what would be done without making changes
  better_versions                              # Show current version
  ''');
  }
}
