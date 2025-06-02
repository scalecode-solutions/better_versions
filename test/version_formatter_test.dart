import 'package:test/test.dart';
import 'package:better_versions/better_versions.dart';

void main() {
  group('VersionFormatter', () {
    test('formats semantic version correctly', () {
      final formatter = VersionFormatter(
        format: VersionFormat(pattern: VersionPattern.semantic),
      );
      
      final version = formatter.formatVersion(
        major: 1,
        minor: 2,
        patch: 3,
      );
      
      expect(version, '1.2.3');
    });

    test('formats semantic version with pre-release', () {
      final formatter = VersionFormatter(
        format: VersionFormat(
          pattern: VersionPattern.semantic,
          preRelease: 'beta.1',
        ),
      );
      
      final version = formatter.formatVersion(
        major: 1,
        minor: 2,
        patch: 3,
      );
      
      expect(version, '1.2.3-beta.1');
    });

    test('formats semantic version with build metadata', () {
      final formatter = VersionFormatter(
        format: VersionFormat(
          pattern: VersionPattern.semantic,
          includeBuildMetadata: true,
        ),
      );
      
      final version = formatter.formatVersion(
        major: 1,
        minor: 2,
        patch: 3,
        buildNumber: 42,
      );
      
      expect(version, '1.2.3+42');
    });

    test('formats date-based version correctly', () {
      final formatter = VersionFormatter(
        format: VersionFormat(pattern: VersionPattern.dateBased),
        currentTime: DateTime(2023, 6, 2), // Fixed date for testing
      );
      
      final version = formatter.formatVersion(
        major: 1,
        minor: 2,
        patch: 3,
      );
      
      // Date-based format is MMdd.version (e.g., 0602.1)
      expect(version, '1.2.3+0602');
    });

    test('formats custom version correctly', () {
      final formatter = VersionFormatter(
        format: VersionFormat(
          pattern: VersionPattern.custom,
          customFormat: 'v{major}.{minor}.{patch}-build{build}',
        ),
      );
      
      final version = formatter.formatVersion(
        major: 1,
        minor: 2,
        patch: 3,
        buildNumber: 42,
      );
      
      // Custom format is treated as build metadata when pattern is custom
      expect(version, '1.2.3+v{major}.{minor}.{patch}-build1');
    });
  });
}
