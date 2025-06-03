import 'package:flutter/foundation.dart';

// Import platform-specific implementations
import 'ios_version_manager.dart';
import 'android_version_manager.dart';
import 'windows_version_manager.dart';
import 'linux_version_manager.dart';

/// Base class for platform-specific version managers
abstract class PlatformVersionManager {
  final String projectRoot;
  final bool dryRun;

  PlatformVersionManager({
    required this.projectRoot,
    this.dryRun = false,
  });

  /// Update version information for the platform
  Future<void> updateVersion({
    required String version,
    required int buildNumber,
    String? preRelease,
    bool force = false,
  });

  /// Get current version information from the platform
  Future<Map<String, dynamic>> getCurrentVersion();

  /// Check if the platform is available in the project
  bool get isAvailable;

  /// Get the platform name (e.g., 'ios', 'android', 'windows')
  String get platformName;

  @protected
  void log(String message) {
    final prefix = dryRun ? '[$platformName] [DRY RUN]' : '[$platformName]';
    if (kDebugMode) {
      print('$prefix: $message');
    }
  }
}

/// A no-op version manager for unsupported platforms
class NoOpVersionManager extends PlatformVersionManager {
  NoOpVersionManager({required super.projectRoot, super.dryRun});

  @override
  Future<Map<String, dynamic>> getCurrentVersion() async => {};

  @override
  Future<void> updateVersion({
    required String version,
    required int buildNumber,
    String? preRelease,
    bool force = false,
  }) async {
    log('Version update not supported for this platform');
  }

  @override
  bool get isAvailable => false;

  @override
  String get platformName => 'unsupported';
}

/// Factory to create the appropriate platform version manager
class PlatformVersionManagerFactory {
  static PlatformVersionManager create({
    required String projectRoot,
    required String platform,
    bool dryRun = false,
  }) {
    switch (platform) {
      case 'ios':
      case 'macos':
        return IOSVersionManager(projectRoot: projectRoot, dryRun: dryRun);
      case 'android':
        return AndroidVersionManager(projectRoot: projectRoot, dryRun: dryRun);
      case 'windows':
        return WindowsVersionManager(projectRoot: projectRoot, dryRun: dryRun);
      case 'linux':
        return LinuxVersionManager(projectRoot: projectRoot, dryRun: dryRun);
      default:
        return NoOpVersionManager(projectRoot: projectRoot, dryRun: dryRun);
    }
  }

  /// Get all available platform version managers for the current project
  static List<PlatformVersionManager> getAll({
    required String projectRoot,
    bool dryRun = false,
  }) {
    final managers = <PlatformVersionManager>[];
    
    for (final platform in ['ios', 'android', 'windows', 'linux', 'macos']) {
      final manager = create(
        projectRoot: projectRoot,
        platform: platform,
        dryRun: dryRun,
      );
      if (manager.isAvailable) {
        managers.add(manager);
      }
    }
    
    return managers;
  }
}
