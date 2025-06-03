import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:better_versions/src/platform/android_version_manager.dart';

void main() {
  group('AndroidVersionManager', () {
    late Directory tempDir;
    late File buildGradleFile;
    late AndroidVersionManager manager;

    setUp(() async {
      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('better_versions_test_');
      
      // Create a test build.gradle file
      buildGradleFile = File(path.join(tempDir.path, 'build.gradle'));
      await buildGradleFile.writeAsString('''
        android {
            defaultConfig {
                versionCode 1
                versionName "1.0.0"
                applicationId "com.example.app"
            }
        }
      ''');
      
      // Initialize the manager
      manager = AndroidVersionManager(
        projectRoot: tempDir.path,
        buildGradlePath: buildGradleFile.path,
      );
    });

    tearDown(() async {
      // Clean up the temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('getCurrentVersion returns correct version', () async {
      final version = await manager.getCurrentVersion();
      expect(version['version'], equals('1.0.0'));
      expect(version['buildNumber'], equals(1));
    });

    test('updateVersion updates version and build number', () async {
      // Update version and build number
      await manager.updateVersion(version: '2.1.3', buildNumber: 42);
      
      // Verify the file was updated
      final content = await buildGradleFile.readAsString();
      expect(content, contains('versionName "2.1.3"'));
      expect(content, contains('versionCode 42'));
      
      // Verify getCurrentVersion returns the updated values
      final version = await manager.getCurrentVersion();
      expect(version['version'], equals('2.1.3'));
      expect(version['buildNumber'], equals(42));
    });

    test('updateVersion with pre-release updates version correctly', () async {
      // Update version with pre-release and build number
      await manager.updateVersion(version: '2.1.3', buildNumber: 42, preRelease: 'beta.1');
      
      // Verify the file was updated with pre-release
      final content = await buildGradleFile.readAsString();
      expect(content, contains('versionName "2.1.3-beta.1"'));
      expect(content, contains('versionCode 42'));
      
      // Verify getCurrentVersion returns the updated values
      final version = await manager.getCurrentVersion();
      expect(version['version'], equals('2.1.3-beta.1'));
      expect(version['buildNumber'], equals(42));
    });

    test('updateVersion with force allows version downgrade', () async {
      // First update to a higher version
      await manager.updateVersion(version: '2.0.0', buildNumber: 2);
      
      // Try to downgrade with force
      await manager.updateVersion(version: '1.9.0', buildNumber: 1, force: true);
      
      // Verify the version was changed
      var version = await manager.getCurrentVersion();
      expect(version['version'], equals('1.9.0'));
      expect(version['buildNumber'], equals(1));
      
      // Now try with force (should succeed)
      await manager.updateVersion(version: '1.9.0', buildNumber: 1, force: true);
      
      // Verify the version was changed
      version = await manager.getCurrentVersion();
      expect(version['version'], equals('1.9.0'));
      expect(version['buildNumber'], equals(1));
    });

    test('updateVersion throws for invalid version format', () async {
      expect(
        () => manager.updateVersion(version: 'invalid', buildNumber: 1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('updateVersion throws for invalid build number', () async {
      expect(
        () => manager.updateVersion(version: '1.0.0', buildNumber: 0),
        throwsA(isA<ArgumentError>()),
      );
      
      expect(
        () => manager.updateVersion(version: '1.0.0', buildNumber: -1),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
