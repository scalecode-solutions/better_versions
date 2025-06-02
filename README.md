# Better Versions

[![pub package](https://img.shields.io/pub/v/better_versions.svg)](https://pub.dev/packages/better_versions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful version management package for Flutter and Dart that provides flexible version formatting and automatic build number generation.

## Features

- Multiple versioning formats (semantic, date-based, timestamp, custom)
- Automatic build number incrementing
- Pre-release version support (alpha, beta, rc, etc.)
- Command-line interface for easy integration with CI/CD pipelines
- Support for custom version formats
- Dry-run mode to preview changes

## Installation

Add this to your project's `pubspec.yaml` file:

```yaml
dependencies:
  better_versions: ^0.1.0
```

For command-line usage, activate globally:

```bash
dart pub global activate better_versions
```

## Usage

### Command Line

```bash
# Show current version
better_versions

# Bump major version (1.0.0 -> 2.0.0)
better_versions --major

# Bump minor version (0.1.0 -> 0.2.0)
better_versions --minor

# Bump patch version (0.0.1 -> 0.0.2)
better_versions --patch

# Set pre-release version
better_versions --pre-release=beta.1

# Remove pre-release version
better_versions --remove-pre-release

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
