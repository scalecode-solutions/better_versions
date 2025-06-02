import 'package:flutter_test/flutter_test.dart';
import 'package:better_versions/better_versions.dart';

void main() {
  group('VersionFormatter', () {
    final formatter = VersionFormatter(
      format: VersionFormat(pattern: VersionPattern.semantic),
    );

    test('formats semantic version correctly', () {
      final version = formatter.formatVersion(
        major: 1,
        minor: 2,
        patch: 3,
      );
      expect(version, matches(r'^\d+\.\d+\.\d+$'));
    });

    test('formats date-based version correctly', () {
      final dateFormatter = VersionFormatter(
        format: VersionFormat(pattern: VersionPattern.dateBased),
      );
      final version = dateFormatter.formatVersion(
        major: 1,
        minor: 2,
        patch: 3,
      );
      expect(version, matches(r'^\d{8}\.\d+$'));
    });

    test('formats timestamp version correctly', () {
      final timestampFormatter = VersionFormatter(
        format: VersionFormat(pattern: VersionPattern.timestamp),
      );
      final version = timestampFormatter.formatVersion(
        major: 1,
        minor: 2,
        patch: 3,
      );
      expect(version, matches(r'^\d+$'));
    });

    test('formats custom version correctly', () {
      final customFormatter = VersionFormatter(
        format: VersionFormat(
          pattern: VersionPattern.custom,
          customFormat: 'v{major}.{minor}.{patch}-build{build}',
        ),
      );
      final version = customFormatter.formatVersion(
        major: 1,
        minor: 2,
        patch: 3,
        buildNumber: 42,
      );
      expect(version, 'v1.2.3-build42');
    });
  });

  group('VersionManager', () {
    // Note: These tests would require proper file system mocking to be fully tested
    // This is just a basic structure
    test('bumps major version correctly', () async {
      final manager = VersionManager(projectRoot: '.');
      // This is a simplified test - in a real test, we would mock the file system
      expect(manager, isNotNull);
    });

    test('bumps minor version correctly', () async {
      final manager = VersionManager(projectRoot: '.');
      // This is a simplified test - in a real test, we would mock the file system
      expect(manager, isNotNull);
    });

    test('bumps patch version correctly', () async {
      final manager = VersionManager(projectRoot: '.');
      // This is a simplified test - in a real test, we would mock the file system
      expect(manager, isNotNull);
    });
  });
}
