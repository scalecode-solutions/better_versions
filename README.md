# Better Versions

[![pub package](https://img.shields.io/pub/v/better_versions.svg)](https://pub.dev/packages/better_versions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Test Status](https://github.com/scalecode-solutions/better_versions/actions/workflows/test.yml/badge.svg)](https://github.com/scalecode-solutions/better_versions/actions)
[![Coverage](https://codecov.io/gh/scalecode-solutions/better_versions/branch/main/graph/badge.svg)](https://codecov.io/gh/scalecode-solutions/better_versions)

A robust version management package for Flutter and Dart that simplifies version control across multiple platforms. Better Versions provides a unified interface to manage version numbers and build numbers across Android, iOS, macOS, Windows, and Linux platforms.

## Features

- 🚀 **Cross-Platform Support**: Manage versions for Android, iOS, macOS, Windows, and Linux from a single interface
- 🔄 **Automatic Build Number Management**: Keep build numbers in sync across all platforms
- 🏷️ **Semantic Versioning**: Full support for semantic versioning (SemVer) standards
- 🛠️ **Platform-Specific Integration**:
  - Android: Update `versionName` and `versionCode` in `build.gradle`
  - iOS: Update `CFBundleShortVersionString` and `CFBundleVersion` in `Info.plist`
  - macOS: Update `CFBundleShortVersionString` and `CFBundleVersion` in `Info.plist` with dedicated macOS support
  - Windows: Update version in `CMakeLists.txt` and `.rc` files
  - Linux: Update version in `CMakeLists.txt`
- 🔍 **Dry-run Mode**: Preview changes before applying them
- 🧪 **Comprehensive Testing**: Thoroughly tested with high code coverage
- 📱 **Flutter & Dart**: Works with both Flutter apps and pure Dart packages
- 🛡️ **Validation**: Built-in validation for version numbers and build numbers
- 🔄 **Version Comparison**: Compare versions with support for different version lengths
- 📝 **Detailed Logging**: Get clear feedback about version changes

## Installation

Add this to your project's `pubspec.yaml` file:

```yaml
dependencies:
  better_versions: ^0.1.3
```

For command-line usage, activate globally:

```bash
dart pub global activate better_versions
```

## Quick Start

### 1. Import the package

```dart
import 'package:better_versions/better_versions.dart';
```

### 2. Update version across all platforms

```dart
final manager = VersionManager(projectRoot: '.');
await manager.updateVersion(
  version: '1.2.3',
  buildNumber: 42,
  preRelease: 'beta.1',  // optional
  force: false,          // optional, set to true to allow version downgrades
);
```

### 3. Or update platform-specific versions

```dart
// Android only
final androidManager = AndroidVersionManager(projectRoot: '.');
await androidManager.updateVersion(version: '1.2.3', buildNumber: 42);

// iOS only
final iosManager = IOSVersionManager(projectRoot: '.');
await iosManager.updateVersion(version: '1.2.3', buildNumber: 42);

// macOS only (dedicated manager)
final macosManager = MacOSVersionManager(projectRoot: '.');
await macosManager.updateVersion(version: '1.2.3', buildNumber: 42);

// Windows only
final windowsManager = WindowsVersionManager(projectRoot: '.');
await windowsManager.updateVersion(version: '1.2.3', buildNumber: 42);

// Linux only
final linuxManager = LinuxVersionManager(projectRoot: '.');
await linuxManager.updateVersion(version: '1.2.3', buildNumber: 42);

// Date-based build numbers (e.g., YYMMDDHHmmss format)
final now = DateTime.now();
final buildNumber = int.parse(
  '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}',
);
await manager.updateVersion(
  version: '1.2.3',
  buildNumber: buildNumber,
);
```

## Platform-Specific Details

### Android

Updates the following in `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        versionCode 42
        versionName "1.2.3"
    }
}
```

### iOS/macOS

Updates the following in `ios/Runner/Info.plist`:
```xml
<key>CFBundleShortVersionString</key>
<string>1.2.3</string>
<key>CFBundleVersion</key>
<string>42</string>
```

### Windows

Updates version in `windows/CMakeLists.txt`:
```cmake
set(BINARY_NAME "YourAppName")
set(VERSION_MAJOR 1)
set(VERSION_MINOR 2)
set(VERSION_PATCH 3)
set(VERSION_BUILD 42)
```

### Linux

Updates version in `linux/CMakeLists.txt`:
```cmake
set(APPLICATION_ID "com.example.app")
set(APPLICATION_NAME "YourAppName")
set(APPLICATION_VERSION_MAJOR 1)
set(APPLICATION_VERSION_MINOR 2)
set(APPLICATION_VERSION_PATCH 3)
set(APPLICATION_VERSION_BUILD 42)
```

## Advanced Usage

### Dry Run Mode

Preview changes without modifying any files:

```dart
final manager = VersionManager(projectRoot: '.');
await manager.updateVersion(
  version: '1.2.3',
  buildNumber: 42,
  dryRun: true,  // Set to true for dry run
);
```

### Custom File Paths

If your project has a non-standard structure, you can specify custom file paths:

```dart
final androidManager = AndroidVersionManager(
  projectRoot: '.',
  buildGradlePath: 'android/app/build.gradle',  // Custom path to build.gradle
);

final iosManager = IOSVersionManager(
  projectRoot: '.',
  plistPath: 'ios/Runner/Info.plist',  // Custom path to Info.plist
);
```

### Version Validation

Validate version strings before updating:

```dart
if (isValidVersion('1.2.3')) {
  // Version is valid
}

if (isValidBuildNumber(42)) {
  // Build number is valid
}

// Format version to ensure consistent format
final formattedVersion = formatVersion('1.2');  // Returns '1.2.0'
```

### Platform-Specific Configuration

You can also manage versions for specific platforms:

```dart
// Update Android version only
final androidManager = AndroidVersionManager(projectRoot: '.');
await androidManager.updateVersion(version: '1.2.3', buildNumber: 123);

// Update iOS version only
final iosManager = IOSVersionManager(projectRoot: '.');
await iosManager.updateVersion(version: '1.2.3', buildNumber: 123);
```

## Error Handling

Better Versions provides detailed error messages for common issues:

- Invalid version formats
- Invalid build numbers
- File access issues
- Permission errors
- Version downgrade attempts (when not forced)

Example error handling:

```dart
try {
  await manager.updateVersion(version: '1.2.3', buildNumber: 42);
} on FormatException catch (e) {
  print('Invalid version format: ${e.message}');
} on FileSystemException catch (e) {
  print('File access error: ${e.message}');
} on Exception catch (e) {
  print('An error occurred: $e');
}
```

## Version Management

### Get Current Version

```dart
final manager = VersionManager(projectRoot: '.');
final versionInfo = await manager.getCurrentVersion();
print('Version: ${versionInfo['version']}');
print('Build number: ${versionInfo['buildNumber']}');
```

### Bump Versions

```dart
// Bump major version (1.2.3 -> 2.0.0)
await manager.bumpMajor();

// Bump minor version (1.2.3 -> 1.3.0)
await manager.bumpMinor();

// Bump patch version (1.2.3 -> 1.2.4)
await manager.bumpPatch();

// Bump build number (42 -> 43)
await manager.bumpBuildNumber();
```

### Pre-release Versions

```dart
// Set pre-release version (1.2.3 -> 1.2.3-beta.1)
await manager.setPreRelease('beta.1');

// Remove pre-release (1.2.3-beta.1 -> 1.2.3)
await manager.removePreRelease();
```

## Command Line Interface

### Installation

```bash
dart pub global activate better_versions
```

### Usage

```bash
# Show current version across all platforms
better_versions get

# Bump version components
better_versions bump major    # 1.0.0 -> 2.0.0
better_versions bump minor    # 1.0.0 -> 1.1.0
better_versions bump patch    # 1.0.0 -> 1.0.1
better_versions bump build    # Increment build number

# Set specific version
better_versions set 1.2.3 --build 42

# Pre-release versions
better_versions pre-release beta.1     # 1.0.0 -> 1.0.0-beta.1
better_versions pre-release --remove   # 1.0.0-beta.1 -> 1.0.0

# Platform-specific operations
better_versions get --platform=android
better_versions set 1.2.3 --platform=ios --build 42

# Dry run (preview changes without modifying files)
better_versions set 1.2.3 --dry-run

# Custom project root
better_versions get --project=path/to/project
```

### Options

```
-p, --platform    Target platform (android, ios, windows, linux, all)
-b, --build       Set build number
-f, --force       Force version update even if it's a downgrade
-d, --dry-run     Preview changes without modifying files
-v, --verbose     Show detailed logging
--version         Show version information
--help            Show usage information
```

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a complete list of changes in each version.

### Custom Formatting

You can define a custom version format in your `pubspec.yaml`:

```yaml
better_versions:
  format:
    pattern: custom
    custom_format: 'v{major}.{minor}.{patch}-{build}'
    pre_release: beta  # Optional pre-release identifier
```

Available placeholders:
- `{major}`: Major version number
- `{minor}`: Minor version number
- `{patch}`: Patch version number
- `{build}`: Build number
- `{yyyy}`: 4-digit year
- `{yy}`: 2-digit year
- `{MM}`: Month (01-12)
- `{dd}`: Day (01-31)
- `{HH}`: Hour (00-23)
- `{mm}`: Minute (00-59)
- `{ss}`: Second (00-59)

# Auto-increment build number
better_versions --auto-increment

# Set specific build number
better_versions --build-number=42

# Use date-based versioning (MMDD)
better_versions --format=date

# Use timestamp-based versioning (YYMMDDHHmm)
better_versions --format=timestamp

# Use custom format
better_versions --format=custom --custom-format='{yyyy}.{MM}.{dd}+{build}'

# Dry run (show what would be done without making changes)
better_versions --major --dry-run
```

### Programmatic Usage

```dart
import 'package:better_versions/better_versions.dart';

void main() async {
  // Create a version manager
  final manager = VersionManager(
    projectRoot: '.',  // Path to your project root
    versionFormat: VersionFormat.dateBased,  // Use date-based versioning
  );

  // Bump major version
  await manager.bumpMajor();
  
  // Bump minor version
  await manager.bumpMinor();
  
  // Bump patch version
  await manager.bumpPatch();
  
  // Set pre-release version
  await manager.setPreRelease('beta.1');
  
  // Remove pre-release version
  await manager.removePreRelease();
  
  // Get current version
  final current = await manager.getCurrentVersion();
  print('Current version: ${current['major']}.${current['minor']}.${current['patch']}');
}
```

## Version Formats

### Semantic Versioning (default)
Format: `MAJOR.MINOR.PATCH+BUILD`
Example: `1.2.3+45`

### Date-Based
Format: `MAJOR.MINOR.MMDD+BUILD`
Example: `1.2.0602+45` (for June 2nd)

### Timestamp
Format: `MAJOR.MINOR.PATCH+YYMMDDHHmm`
Example: `1.2.3+2506021423` (for 2025-06-02 14:23)

### Custom Format
You can define your own format using placeholders:
- `{yyyy}`: 4-digit year
- `{yy}`: 2-digit year
- `{MM}`: 2-digit month (01-12)
- `{dd}`: 2-digit day (01-31)
- `{HH}`: 2-digit hour (00-23)
- `{mm}`: 2-digit minute (00-59)
- `{ss}`: 2-digit second (00-59)
- `{build}`: Build number

Example: `{yyyy}.{MM}.{dd}+{build}` → `2025.06.02+1`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Error Handling

Better Versions provides clear error messages for common issues:

- **Missing pubspec.yaml**: Throws `PubspecNotFound` if the file is not found
- **Invalid version format**: Validates version strings against semantic versioning rules
- **File system errors**: Handles permission issues and other file system errors gracefully
- **Network connectivity**: For operations that might require network access

## Performance

The package is designed to be efficient:
- Minimal dependencies
- Lazy loading of resources
- Efficient file operations
- Memory-efficient processing

## Migration Guide

### From 0.0.1 to 0.1.0
- Updated version format handling for better consistency
- Improved error messages and validation
- Added support for custom version formats
- Breaking changes in the CLI interface (see updated examples)

## Troubleshooting

### Common Issues

1. **Version not updating**
   - Ensure you have write permissions to the pubspec.yaml file
   - Check for syntax errors in your pubspec.yaml
   - Run with `--verbose` flag for more detailed output

2. **Build number not incrementing**
   - Make sure the build number is in the correct format (integer)
   - Check for any custom formatting that might be affecting the build number

3. **Pre-release versions not working**
   - Ensure the pre-release identifier follows semantic versioning rules
   - Check for any typos in the pre-release string

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please [open an issue](https://github.com/scalecode-solutions/better_versions/issues) on GitHub.

## Acknowledgements

- Inspired by various version management tools in the Flutter/Dart ecosystem
- Built with ❤️ by the ScaleCode Solutions team
