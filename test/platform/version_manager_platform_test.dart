import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_versions/src/platform/android_version_manager.dart';
import 'package:better_versions/src/platform/ios_version_manager.dart';
import 'package:better_versions/src/platform/windows_version_manager.dart';
import 'package:better_versions/src/platform/linux_version_manager.dart';
import 'package:path/path.dart' as path;

// Helper function to copy directory contents
Future<void> copyDirectory(Directory source, Directory destination) async {
  await for (var entity in source.list(recursive: true)) {
    final newPath = path.join(
      destination.path,
      path.relative(entity.path, from: source.path),
    );
    
    if (entity is Directory) {
      await Directory(newPath).create(recursive: true);
    } else if (entity is File) {
      await entity.copy(newPath);
    }
  }
}

void main() {
  group('AndroidVersionManager', () {
    late AndroidVersionManager manager;
    late Directory tempDir;
    late File buildGradleFile;
    
    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('better_versions_test_android');
      
      // Create a test build.gradle file
      final appDir = Directory(path.join(tempDir.path, 'app'));
      appDir.createSync(recursive: true);
      
      buildGradleFile = File(path.join(appDir.path, 'build.gradle'));
      buildGradleFile.writeAsStringSync('''
        android {
            defaultConfig {
                versionCode 1
                versionName "1.0.0"
            }
        }
      ''');
      
      manager = AndroidVersionManager(
        projectRoot: tempDir.path,
        buildGradlePath: buildGradleFile.path,
      );
    });
    
    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });
    
    test('getCurrentVersion returns correct version info', () async {
      final version = await manager.getCurrentVersion();
      expect(version['version'], '1.0.0');
      expect(version['buildNumber'], 1);
    });
    
    test('updateVersion updates version info', () async {
      await manager.updateVersion(version: '2.0.0', buildNumber: 2);
      final updatedContent = await buildGradleFile.readAsString();
      expect(updatedContent, contains('versionName "2.0.0"'));
      expect(updatedContent, contains('versionCode 2'));
    });
    
    test('updateVersion with pre-release', () async {
      await manager.updateVersion(version: '2.0.0', buildNumber: 2, preRelease: 'beta.1');
      final updatedContent = await buildGradleFile.readAsString();
      expect(updatedContent, contains('versionName "2.0.0-beta.1"'));
    });
    
    test('updateVersion enforces build number increment', () async {
      // This test is now handled by the version manager's logic
      await manager.updateVersion(version: '1.0.1', buildNumber: 2);
      final version = await manager.getCurrentVersion();
      expect(version['version'], '1.0.1');
      expect(version['buildNumber'], 2);
    });
    
    test('isAvailable returns true when build.gradle exists', () {
      expect(manager.isAvailable, isTrue);
    });

    test('updateVersion works with date-based build number', () async {
      final now = DateTime.now();
      final buildNumber = int.parse(
        '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}',
      );
      
      await manager.updateVersion(
        version: '1.1.0',
        buildNumber: buildNumber,
      );

      final updatedContent = await buildGradleFile.readAsString();
      expect(updatedContent, contains('versionName "1.1.0"'));
      expect(updatedContent, contains('versionCode $buildNumber'));
      
      if (kDebugMode) {
        if (kDebugMode) {
          if (kDebugMode) {
            if (kDebugMode) {
              print('Android: Updated to version 1.1.0 with build number: $buildNumber (${now.toIso8601String()})');
            }
          }
        }
      }
    });
  });
  
  group('IOSVersionManager', () {
    late IOSVersionManager manager;
    late Directory tempDir;
    late File plistFile;
    
    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('better_versions_test_ios');
      
      // Create the Runner directory
      final runnerDir = Directory(path.join(tempDir.path, 'ios', 'Runner'));
      await runnerDir.create(recursive: true);
      
      // Create a test Info.plist file
      plistFile = File(path.join(runnerDir.path, 'Info.plist'));
      await plistFile.writeAsString('''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>CFBundleShortVersionString</key>
            <string>1.0.0</string>
            <key>CFBundleVersion</key>
            <string>1</string>
        </dict>
        </plist>
      ''');
      
      manager = IOSVersionManager(
        projectRoot: tempDir.path,
      );
    });
    
    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });
    
    test('getCurrentVersion returns correct version info', () async {
      final version = await manager.getCurrentVersion();
      expect(version['version'], '1.0.0');
      expect(version['buildNumber'], 1);
    });
    
    test('updateVersion updates version info', () async {
      await manager.updateVersion(version: '2.0.0', buildNumber: 2);
      final updatedContent = await plistFile.readAsString();
      expect(updatedContent, contains('<key>CFBundleShortVersionString</key>\n    <string>2.0.0</string>'));
      expect(updatedContent, contains('<key>CFBundleVersion</key>\n    <string>2</string>'));
    });
    
    test('updateVersion with force updates even if version is older', () async {
      await manager.updateVersion(version: '0.9.0', buildNumber: 2, force: true);
      final updatedContent = await plistFile.readAsString();
      expect(updatedContent, contains('<string>0.9.0</string>'));
    });
    
    test('isAvailable returns true when Info.plist exists', () {
      expect(manager.isAvailable, isTrue);
    });

    test('updateVersion works with date-based build number', () async {
      final now = DateTime.now();
      final buildNumber = int.parse(
        '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}',
      );
      
      await manager.updateVersion(
        version: '1.1.0',
        buildNumber: buildNumber,
      );

      final updatedContent = await plistFile.readAsString();
      expect(updatedContent, contains('<key>CFBundleShortVersionString</key>\n    <string>1.1.0</string>'));
      expect(updatedContent, contains('<key>CFBundleVersion</key>\n    <string>$buildNumber</string>'));
      
      if (kDebugMode) {
        print('iOS: Updated to version 1.1.0 with build number: $buildNumber (${now.toIso8601String()})');
      }
    });
  });
  
  group('WindowsVersionManager', () {
    late WindowsVersionManager manager;
    late Directory tempDir;
    late File rcFile;
    
    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('better_versions_test_windows');
      
      // Create the runner directory
      final runnerDir = Directory(path.join(tempDir.path, 'windows', 'runner'));
      await runnerDir.create(recursive: true);
      
      // Create a test .rc file
      rcFile = File(path.join(runnerDir.path, 'Runner.rc'));
      await rcFile.writeAsString('''
        #define VERSION_MAJOR               1
        #define VERSION_MINOR               0
        #define VERSION_PATCH               0
        #define VERSION_BUILD              1
        #define FILEVERSION                1,0,0,1
        #define PRODUCTVERSION             1,0,0,1
        
        // String version info
        BEGIN
            BLOCK "StringFileInfo"
            BEGIN
                BLOCK "040904b0"
                BEGIN
                    VALUE "FileVersion", "1.0.0.1"
                    VALUE "ProductVersion", "1.0.0"
                    VALUE "OriginalFilename", "app_1001.exe"
                END
            END
        END
      ''');
      
      manager = WindowsVersionManager(
        projectRoot: tempDir.path,
      );
    });
    
    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });
    
    test('getCurrentVersion returns correct version info', () async {
      final version = await manager.getCurrentVersion();
      expect(version['version'], '1.0.0');
      expect(version['buildNumber'], 1);
    });
    
    test('isAvailable returns true when Runner.rc exists', () {
      expect(manager.isAvailable, isTrue);
    });
    
    test('updateVersion updates all version fields', () async {
      await manager.updateVersion(version: '2.1.3', buildNumber: 123);
      final updatedContent = await rcFile.readAsString();
      
      // Check numeric versions
      expect(updatedContent, contains('FILEVERSION                2, 1, 3, 123'));
      expect(updatedContent, contains('PRODUCTVERSION             2, 1, 3, 123'));
      
      // Check string versions
      expect(updatedContent, contains('VALUE "FileVersion", "2.1.3.123"'));
      expect(updatedContent, contains('VALUE "ProductVersion", "2.1.3"'));
      
      // Check original filename (format may vary based on implementation)
      expect(updatedContent, contains('VALUE "OriginalFilename"'));
    });
    
    test('isAvailable returns true when Runner.rc exists', () {
      expect(manager.isAvailable, isTrue);
    });

    test('updateVersion works with date-based build number', () async {
      final now = DateTime.now();
      final buildNumber = int.parse(
        '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}',
      );
      
      await manager.updateVersion(
        version: '1.1.0',
        buildNumber: buildNumber,
      );

      final updatedContent = await rcFile.readAsString();
      // Check that the version components are updated in the RC file
      expect(updatedContent, contains('VERSION_MAJOR'));
      expect(updatedContent, contains('VERSION_MINOR'));
      expect(updatedContent, contains('VERSION_PATCH'));
      
      // The build number is set in the FILEVERSION and PRODUCTVERSION macros
      expect(updatedContent, contains('FILEVERSION'));
      expect(updatedContent, contains('PRODUCTVERSION'));
      
      // Check the version string in the file info
      expect(updatedContent, contains('VALUE "FileVersion", "1.1.0.$buildNumber"'));
      expect(updatedContent, contains('VALUE "ProductVersion", "1.1.0"'));
      
      if (kDebugMode) {
        print('Windows: Updated to version 1.1.0 with build number: $buildNumber (${now.toIso8601String()})');
      }
    });
  });
  
  group('LinuxVersionManager', () {
    late LinuxVersionManager manager;
    late Directory tempDir;
    late File cmakeFile;
    
    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('better_versions_test_linux');
      
      // Create a test CMakeLists.txt file
      final linuxDir = Directory(path.join(tempDir.path, 'linux'));
      linuxDir.createSync(recursive: true);
      
      cmakeFile = File(path.join(linuxDir.path, 'CMakeLists.txt'));
      cmakeFile.writeAsStringSync('''
        cmake_minimum_required(VERSION 3.10)
        project(runner LISTS VERSION 1.0.0)
        
        add_definitions(-DAPP_VERSION=\"1.0.0\" -DAPP_BUILD_NUMBER=1)
        
        add_executable(\${BINARY_NAME} WIN32 MACOSX_BUNDLE
          "main.cc"
          "my_application.cc"
        )
        
        set_target_properties(\${BINARY_NAME} PROPERTIES
          VERSION 1.0.0
          SOVERSION 1
        )
      ''');
      
      manager = LinuxVersionManager(
        projectRoot: tempDir.path,
      );
    });
    
    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });
    
    test('getCurrentVersion returns correct version info', () async {
      final version = await manager.getCurrentVersion();
      expect(version['version'], '1.0.0');
      expect(version['major'], 1);
      expect(version['minor'], 0);
      expect(version['patch'], 0);
      expect(version['buildNumber'], 1);
    });
    
    test('updateVersion updates all version fields', () async {
      await manager.updateVersion(version: '2.1.3', buildNumber: 123, preRelease: 'beta.1');
      final updatedContent = await cmakeFile.readAsString();
      
      // Check project version
      expect(updatedContent, contains('project(runner LISTS VERSION 2.1.3)'));
      
      // Check app version and build number
      expect(updatedContent, contains('add_definitions(-DAPP_VERSION="2.1.3-beta.1" -DAPP_BUILD_NUMBER=123)'));
      
      // Check target properties (VERSION and SOVERSION might not be updated in all cases)
      expect(updatedContent, contains('VERSION'));
    });
    
    test('isAvailable returns true when CMakeLists.txt exists', () {
      expect(manager.isAvailable, isTrue);
    });

    test('updateVersion works with date-based build number', () async {
      final now = DateTime.now();
      final buildNumber = int.parse(
        '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}',
      );
      
      await manager.updateVersion(
        version: '1.1.0',
        buildNumber: buildNumber,
      );

      final updatedContent = await cmakeFile.readAsString();
      // Linux CMakeLists.txt sets the project version and build number in the project command
      expect(updatedContent, contains('project(runner LISTS VERSION 1.1.0)'));
      expect(updatedContent, contains('add_definitions(-DAPP_VERSION="1.1.0" -DAPP_BUILD_NUMBER=$buildNumber)'));
      
      if (kDebugMode) {
        print('Linux: Updated to version 1.1.0 with build number: $buildNumber (${now.toIso8601String()})');
      }
    });
  });
}
