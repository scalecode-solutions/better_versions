import 'dart:io';
import 'package:path/path.dart' as path;
import 'version_manager_platform.dart';

/// Manages version information for Windows platform
class WindowsVersionManager extends PlatformVersionManager {
  /// Path to the Runner.rc file
  late final String _rcFilePath;

  WindowsVersionManager({
    required super.projectRoot,
    super.dryRun,
    String? rcFilePath,
  }) {
    _rcFilePath = rcFilePath ?? _findRcFilePath();
  }

  @override
  String get platformName => 'windows';

  @override
  bool get isAvailable => File(_rcFilePath).existsSync();

  @override
  Future<Map<String, dynamic>> getCurrentVersion() async {
    final file = File(_rcFilePath);
    if (!await file.exists()) {
      return {};
    }

    final content = await file.readAsString();
    final result = <String, dynamic>{};
    
    try {
      // Parse FILEVERSION (4-part version: major.minor.patch.build)
      final fileVersionMatch = RegExp(
        r'FILEVERSION\s+(\d+),\s*(\d+),\s*(\d+),\s*(\d+)',
      ).firstMatch(content);
      
      if (fileVersionMatch != null) {
        result['major'] = int.parse(fileVersionMatch.group(1)!);
        result['minor'] = int.parse(fileVersionMatch.group(2)!);
        result['patch'] = int.parse(fileVersionMatch.group(3)!);
        result['buildNumber'] = int.parse(fileVersionMatch.group(4)!);
        result['version'] = '${result['major']}.${result['minor']}.${result['patch']}';
      }
      
      // Also check for string versions
      final stringVersionMatch = RegExp(
        r'VALUE\s+"FileVersion",\s*"([^"]+)"',
      ).firstMatch(content);
      
      if (stringVersionMatch != null) {
        result['versionString'] = stringVersionMatch.group(1)!;
      }
    } catch (e) {
      log('Error parsing Windows version: $e');
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

    final file = File(_rcFilePath);
    if (!await file.exists()) {
      throw FileSystemException('Runner.rc not found at $_rcFilePath');
    }

    var content = await file.readAsString();
    var updated = false;

    // Parse version components (major.minor.patch)
    final versionParts = version.split('.');
    final major = int.tryParse(versionParts[0]) ?? 0;
    final minor = versionParts.length > 1 ? int.tryParse(versionParts[1]) ?? 0 : 0;
    final patch = versionParts.length > 2 ? int.tryParse(versionParts[2]) ?? 0 : 0;
    
    // Format version strings
    final versionString = '$major.$minor.$patch.$buildNumber';
    final versionComma = '$major, $minor, $patch, $buildNumber';
    final versionStringNoBuild = '$major.$minor.$patch';

    // Update FILEVERSION
    final fileVersionPattern = RegExp(
      r'(FILEVERSION\s+)(\d+),\s*(\d+),\s*(\d+),\s*(\d+)',
      caseSensitive: false,
    );
    
    if (fileVersionPattern.hasMatch(content) || force) {
      content = content.replaceFirstMapped(
        fileVersionPattern,
        (match) => '${match.group(1)}$versionComma',
      );
      updated = true;
    }

    // Update PRODUCTVERSION
    final productVersionPattern = RegExp(
      r'(PRODUCTVERSION\s+)(\d+),\s*(\d+),\s*(\d+),\s*(\d+)',
      caseSensitive: false,
    );
    
    if (productVersionPattern.hasMatch(content) || force) {
      content = content.replaceFirstMapped(
        productVersionPattern,
        (match) => '${match.group(1)}$versionComma',
      );
      updated = true;
    }

    // Update FileVersion string
    final fileVersionStringPattern = RegExp(
      r'(VALUE\s+"FileVersion",\s*")[^"]*(")',
      caseSensitive: false,
    );
    
    if (fileVersionStringPattern.hasMatch(content) || force) {
      content = content.replaceAllMapped(
        fileVersionStringPattern,
        (match) => '${match.group(1)}$versionString${match.group(2)}',
      );
      updated = true;
    }

    // Update ProductVersion string
    final productVersionStringPattern = RegExp(
      r'(VALUE\s+"ProductVersion",\s*")[^"]*(")',
      caseSensitive: false,
    );
    
    if (productVersionStringPattern.hasMatch(content) || force) {
      content = content.replaceAllMapped(
        productVersionStringPattern,
        (match) => '${match.group(1)}$versionStringNoBuild${match.group(2)}',
      );
      updated = true;
    }

    // Update OriginalFilename (if it exists)
    final originalFilenamePattern = RegExp(
      r'(VALUE\s+"OriginalFilename",\s*")[^"]*(\.exe")',
      caseSensitive: false,
    );
    
    if (originalFilenamePattern.hasMatch(content)) {
      content = content.replaceAllMapped(
        originalFilenamePattern,
        (match) => '${match.group(1)}${versionStringNoBuild.replaceAll('.', '')}.exe"',
      );
      updated = true;
    }

    if (updated) {
      if (!dryRun) {
        await file.writeAsString(content);
        log('Updated Windows version to $versionString');
      } else {
        log('Would update Windows version to $versionString');
      }
    }
  }

  String _findRcFilePath() {
    // Check common locations for Runner.rc
    final possiblePaths = [
      path.join(projectRoot, 'windows', 'runner', 'Runner.rc'),
      path.join(projectRoot, 'windows', 'Runner.rc'),
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
