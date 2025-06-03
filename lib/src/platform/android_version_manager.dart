import 'dart:io';
import 'package:path/path.dart' as path;
import 'version_manager_platform.dart';

/// Manages version information for Android platform
class AndroidVersionManager extends PlatformVersionManager {
  /// Path to the build.gradle file
  final String _buildGradlePath;

  AndroidVersionManager({
    required super.projectRoot,
    super.dryRun,
    String? buildGradlePath,
  }) : _buildGradlePath = buildGradlePath ?? _findBuildGradlePath(projectRoot);

  @override
  String get platformName => 'android';

  @override
  bool get isAvailable => File(_buildGradlePath).existsSync();

  @override
  Future<Map<String, dynamic>> getCurrentVersion() async {
    final file = File(_buildGradlePath);
    if (!await file.exists()) {
      return <String, dynamic>{};
    }

    final content = await file.readAsString();
    final result = <String, dynamic>{};
    
    // Parse versionName - match: versionName "1.0.0" or versionName '1.0.0'
    final versionNameRegex = RegExp(r'versionName\s*[\"]([^\"]+)[\"]');
    final versionNameMatch = versionNameRegex.firstMatch(content);
    if (versionNameMatch != null && versionNameMatch.groupCount >= 1) {
      result['version'] = versionNameMatch.group(1)!;
    }
    
    // Parse versionCode - match: versionCode 1
    final versionCodeRegex = RegExp(r'versionCode\s+(\d+)');
    final versionCodeMatch = versionCodeRegex.firstMatch(content);
    if (versionCodeMatch != null && versionCodeMatch.groupCount >= 1) {
      result['buildNumber'] = int.parse(versionCodeMatch.group(1)!);
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
    
    // Validate build number (must be positive)
    if (buildNumber <= 0) {
      throw ArgumentError('buildNumber must be a positive integer');
    }
    
    final file = File(_buildGradlePath);
    if (!await file.exists()) {
      throw FileSystemException('build.gradle not found at $_buildGradlePath');
    }

    var content = await file.readAsString();
    var updated = false;
    final newVersion = _formatAndroidVersion(version, preRelease);

    // Update versionName with validation
    final versionNamePattern = RegExp(r'(versionName\s*[\"])([^\"]+)([\"])');
    if (versionNamePattern.hasMatch(content) || force) {
      final currentVersionMatch = versionNamePattern.firstMatch(content);
      if (currentVersionMatch != null) {
        final currentVersion = currentVersionMatch.group(2)!;
        if (!force && !_isVersionNewer(version, currentVersion)) {
          log('New version $version is not newer than current version $currentVersion');
          return;
        }
      }
      
      content = content.replaceFirstMapped(
        versionNamePattern,
        (match) => '${match.group(1)}$newVersion${match.group(3)}',
      );
      updated = true;
    }

    // Update versionCode with validation
    final versionCodePattern = RegExp(r'(versionCode\s+)(\d+)');
    if (versionCodePattern.hasMatch(content) || force) {
      final currentBuildMatch = versionCodePattern.firstMatch(content);
      if (currentBuildMatch != null) {
        final currentBuild = int.tryParse(currentBuildMatch.group(2)!) ?? 0;
        if (!force && buildNumber <= currentBuild) {
          throw ArgumentError('New buildNumber $buildNumber must be greater than current build $currentBuild');
        }
      }
      
      content = content.replaceFirstMapped(
        versionCodePattern,
        (match) => '${match.group(1)}$buildNumber',
      );
      updated = true;
    }

    if (updated) {
      if (!dryRun) {
        await file.writeAsString(content);
        log('Updated Android version to $newVersion (build: $buildNumber)');
      } else {
        log('Would update Android version to $newVersion (build: $buildNumber)');
      }
    }
  }

  /// Checks if newVersion is newer than currentVersion
  bool _isVersionNewer(String newVersion, String currentVersion) {
    try {
      final newParts = newVersion.split('.').map(int.parse).toList();
      final currentParts = currentVersion.split('.').map(int.parse).toList();
      
      // Ensure both versions have 3 parts
      while (newParts.length < 3) {
        newParts.add(0);
      }
      while (currentParts.length < 3) {
        currentParts.add(0);
      }
      
      for (var i = 0; i < 3; i++) {
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
      }
      return false; // Versions are equal
    } catch (e) {
      // If version parsing fails, assume it's newer to be safe
      return true;
    }
  }

  String _formatAndroidVersion(String version, String? preRelease) {
    // For Android, we can include pre-release in versionName
    if (preRelease != null && preRelease.isNotEmpty) {
      // Remove any existing pre-release from version
      final cleanVersion = version.split('-').first;
      return '$cleanVersion-$preRelease';
    }
    return version;
  }

  static String _findBuildGradlePath(String projectRoot) {
    // Check common locations for build.gradle
    final possiblePaths = [
      path.join(projectRoot, 'android', 'app', 'build.gradle'),
      path.join(projectRoot, 'android', 'build.gradle'),
    ];

    for (final possiblePath in possiblePaths) {
      if (File(possiblePath).existsSync()) {
        return possiblePath;
      }
    }

    // Return default path if not found
    return possiblePaths[0];
  }
}
