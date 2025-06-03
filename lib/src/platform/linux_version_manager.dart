import 'dart:io';
import 'package:path/path.dart' as path;
import 'version_manager_platform.dart';

/// Manages version information for Linux platform
class LinuxVersionManager extends PlatformVersionManager {
  /// Path to the CMakeLists.txt file
  late final String _cmakePath;

  LinuxVersionManager({
    required super.projectRoot,
    super.dryRun,
    String? cmakePath,
  }) {
    _cmakePath = cmakePath ?? _findCmakePath();
  }

  @override
  String get platformName => 'linux';

  @override
  bool get isAvailable => File(_cmakePath).existsSync();

  @override
  Future<Map<String, dynamic>> getCurrentVersion() async {
    final file = File(_cmakePath);
    if (!await file.exists()) {
      return {};
    }

    final content = await file.readAsString();
    final result = <String, dynamic>{};
    
    try {
      // Parse project version (major.minor.patch)
      final versionMatch = RegExp(
        r'project\s*\([^)]*VERSION\s+(\d+\.\d+\.\d+)',
        multiLine: true,
      ).firstMatch(content);
      
      if (versionMatch != null) {
        final version = versionMatch.group(1)!;
        final versionParts = version.split('.');
        
        result['version'] = version;
        result['major'] = int.parse(versionParts[0]);
        result['minor'] = versionParts.length > 1 ? int.parse(versionParts[1]) : 0;
        result['patch'] = versionParts.length > 2 ? int.parse(versionParts[2]) : 0;
        
        // Also look for any custom version defines
        final definesMatch = RegExp(
          r'add_definitions\s*\(-DAPP_VERSION="([^"]+)"\s+-DAPP_BUILD_NUMBER=(\d+)',
          multiLine: true,
        ).firstMatch(content);
        
        if (definesMatch != null) {
          result['versionString'] = definesMatch.group(1)!;
          result['buildNumber'] = int.tryParse(definesMatch.group(2)!) ?? 0;
        }
      }
    } catch (e) {
      log('Error parsing Linux version: $e');
    }
    
    return result;
  }


  @override
  Future<void> updateVersion({
    required String version,
    required int buildNumber,
    String? preRelease,
    bool force = false,
  }) async {
    // Validate version format (X.Y.Z)
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
      throw ArgumentError('version must be in format X.Y.Z');
    }
    
    // Validate build number is a positive integer
    if (buildNumber <= 0) {
      throw ArgumentError('buildNumber must be a positive integer');
    }

    final file = File(_cmakePath);
    if (!await file.exists()) {
      throw FileSystemException('CMakeLists.txt not found at $_cmakePath');
    }

    var content = await file.readAsString();
    var updated = false;
    
    // Format version string with optional pre-release
    final versionString = preRelease != null ? '$version-$preRelease' : version;

    // Update project version in project() command
    final versionPattern = RegExp(
      r'(project\s*\([^)]*VERSION\s+)(\d+\.\d+\.\d+)',
      multiLine: true,
    );
    
    if (versionPattern.hasMatch(content) || force) {
      content = content.replaceFirstMapped(
        versionPattern,
        (match) => '${match.group(1)}$version',
      );
      updated = true;
    }
    
    // Update any custom version defines
    final definesPattern = RegExp(
      r'(add_definitions\s*\(-DAPP_VERSION=")[^"]*("\s+-DAPP_BUILD_NUMBER=)\d+',
      multiLine: true,
    );
    
    if (definesPattern.hasMatch(content) || force) {
      content = content.replaceFirstMapped(
        definesPattern,
        (match) => '${match.group(1)}$versionString${match.group(2)}$buildNumber',
      );
      updated = true;
    }
    
    // Update any set_target_properties with VERSION or SOVERSION
    final targetPattern = RegExp(
      r'(set_target_properties\s*\$\{BINARY_NAME\}\s+PROPERTIES\s+[^)]*VERSION\s+)(\d+\.\d+\.\d+)',
      multiLine: true,
    );
    
    if (targetPattern.hasMatch(content) || force) {
      content = content.replaceAllMapped(
        targetPattern,
        (match) => '${match.group(1)}$version',
      );
      updated = true;
    }

    if (updated) {
      if (!dryRun) {
        await file.writeAsString(content);
        log('Updated Linux version to $versionString (build: $buildNumber)');
      } else {
        log('Would update Linux version to $versionString (build: $buildNumber)');
      }
    }
  }

  String _findCmakePath() {
    // Check common locations for CMakeLists.txt
    final possiblePaths = [
      path.join(projectRoot, 'linux', 'CMakeLists.txt'),
      path.join(projectRoot, 'CMakeLists.txt'),
    ];

    for (final path in possiblePaths) {
      if (File(path).existsSync()) {
        return path;
      }
    }

    // Return default path if not found
    return possiblePaths[0];
  }
}
