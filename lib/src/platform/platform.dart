import 'package:better_versions/src/platform/version_manager_platform.dart';

export 'version_manager_platform.dart';
export 'ios_version_manager.dart';
import 'macos_version_manager.dart' show MacOSVersionManager;
export 'android_version_manager.dart';
export 'windows_version_manager.dart';
export 'linux_version_manager.dart';

/// Creates a platform-appropriate version manager
PlatformVersionManager createPlatformVersionManager({
  required String projectRoot,
  bool dryRun = false,
  String? plistPath,
}) {
  if (MacOSVersionManager(projectRoot: projectRoot, plistPath: plistPath).isAvailable) {
    return MacOSVersionManager(projectRoot: projectRoot, dryRun: dryRun, plistPath: plistPath);
  }
  // Other platform checks...
  throw UnsupportedError('Unsupported platform');
}
