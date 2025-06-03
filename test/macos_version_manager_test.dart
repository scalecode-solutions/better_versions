import 'dart:io';
import 'package:better_versions/src/platform/macos_version_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('MacOSVersionManager', () {
    late Directory tempDir;
    late File plistFile;
    late MacOSVersionManager manager;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('better_versions_test_');
      final macosDir = Directory(path.join(tempDir.path, 'macos', 'Runner'));
      await macosDir.create(recursive: true);
      
      // Create test Info.plist
      plistFile = File(path.join(macosDir.path, 'Info.plist'));
      await plistFile.writeAsString('''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Runner</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.test</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>test_app</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
      ''');

      manager = MacOSVersionManager(projectRoot: tempDir.path);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('getCurrentVersion returns correct version', () async {
      final version = await manager.getCurrentVersion();
      expect(version['version'], '1.0.0');
      expect(version['buildNumber'], 1);
    });

    test('updateVersion updates version and build number', () async {
      await manager.updateVersion(
        version: '2.1.0',
        buildNumber: 42,
      );

      final updated = await manager.getCurrentVersion();
      expect(updated['version'], '2.1.0');
      expect(updated['buildNumber'], 42);
    });

    test('updateVersion with pre-release updates version correctly', () async {
      await manager.updateVersion(
        version: '2.1.0-beta.1',
        buildNumber: 42,
      );

      final updated = await manager.getCurrentVersion();
      expect(updated['version'], '2.1.0-beta.1');
      expect(updated['buildNumber'], 42);
    });

    test('updateVersion prevents version downgrade without force', () async {
      expect(
        () => manager.updateVersion(version: '0.9.0', buildNumber: 1),
        throwsA(isA<Exception>()),
      );
    });

    test('updateVersion with force allows version downgrade', () async {
      await manager.updateVersion(
        version: '2.0.0',
        buildNumber: 2,
      );

      await manager.updateVersion(
        version: '1.9.0',
        buildNumber: 1,
        force: true,
      );

      final updated = await manager.getCurrentVersion();
      expect(updated['version'], '1.9.0');
      expect(updated['buildNumber'], 1);
    });

    test('updateVersion works with date-based build number', () async {
      // Generate a build number based on current date and time (YYMMDDHHmmss format)
      final now = DateTime.now();
      final buildNumber = int.parse(
        '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}',
      );
      
      // Update to version 1.1.0 with the date-based build number
      await manager.updateVersion(
        version: '1.1.0',
        buildNumber: buildNumber,
      );

      final updated = await manager.getCurrentVersion();
      expect(updated['version'], '1.1.0');
      expect(updated['buildNumber'], buildNumber);
      
      if (kDebugMode) {
        print('Updated to version ${updated['version']} with build number: $buildNumber (${now.toIso8601String()})');
      }
    });
  });
}
