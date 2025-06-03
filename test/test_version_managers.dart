import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:better_versions/src/platform/android_version_manager.dart';
import 'package:better_versions/src/platform/ios_version_manager.dart';
import 'package:better_versions/src/platform/windows_version_manager.dart';
import 'package:better_versions/src/platform/linux_version_manager.dart';

// This file contains test code and is not part of the main package
// ignore_for_file: avoid_print

Future<void> main() async {
  if (kDebugMode) {
    print('Testing version managers...\n');
  }
  
  // Create a temporary directory for testing
  final tempDir = Directory.systemTemp.createTempSync('better_versions_test_');
  if (kDebugMode) {
    print('Created temporary directory: ${tempDir.path}');
  }
  
  try {
    await testAndroidVersionManager(tempDir);
    await testIosVersionManager(tempDir);
    await testWindowsVersionManager(tempDir);
    await testLinuxVersionManager(tempDir);
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
  } finally {
    // Clean up
    tempDir.deleteSync(recursive: true);
    if (kDebugMode) {
      print('\nCleaned up temporary directory');
    }
  }
}

Future<void> testAndroidVersionManager(Directory tempDir) async {
  if (kDebugMode) {
    print('\n--- Testing AndroidVersionManager ---');
  }
  
  // Create a test build.gradle file
  final buildGradleFile = File(path.join(tempDir.path, 'build.gradle'));
  buildGradleFile.writeAsStringSync('''
    android {
        defaultConfig {
            versionCode 1
            versionName "1.0.0"
        }
    }
  ''');
  
  final manager = AndroidVersionManager(
    projectRoot: tempDir.path,
    buildGradlePath: buildGradleFile.path,
  );
  
  if (kDebugMode) {
    print('Initial version:');
    final version = await manager.getCurrentVersion();
    print('  Version: ${version['version']}');
    print('  Build: ${version['buildNumber']}');
    
    print('\nUpdating to version 2.0.0 (build 2)...');
  }
  
  await manager.updateVersion(version: '2.0.0', buildNumber: 2);
  
  if (kDebugMode) {
    print('\nUpdated version:');
    final updatedVersion = await manager.getCurrentVersion();
    print('  Version: ${updatedVersion['version']}');
    print('  Build: ${updatedVersion['buildNumber']}');
    
    print('\nBuild.gradle content:');
    print(await buildGradleFile.readAsString());
  }
}

Future<void> testIosVersionManager(Directory tempDir) async {
  if (kDebugMode) {
    print('\n--- Testing IOSVersionManager ---');
  }
  
  // Create a test Info.plist file
  final plistFile = File(path.join(tempDir.path, 'Info.plist'));
  plistFile.writeAsStringSync('''
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
  
  final manager = IOSVersionManager(
    projectRoot: tempDir.path,
    plistPath: plistFile.path,
  );
  
  if (kDebugMode) {
    print('Initial version:');
    final version = await manager.getCurrentVersion();
    print('  Version: ${version['version']}');
    print('  Build: ${version['buildNumber']}');
    
    print('\nUpdating to version 2.0.0 (build 2)...');
  }
  
  await manager.updateVersion(version: '2.0.0', buildNumber: 2);
  
  if (kDebugMode) {
    print('\nUpdated version:');
    final updatedVersion = await manager.getCurrentVersion();
    print('  Version: ${updatedVersion['version']}');
    print('  Build: ${updatedVersion['buildNumber']}');
    
    print('\nInfo.plist content:');
    print(await plistFile.readAsString());
  }
}

Future<void> testWindowsVersionManager(Directory tempDir) async {
  if (kDebugMode) {
    print('\n--- Testing WindowsVersionManager ---');
  }
  
  // Create a test .rc file
  final rcFile = File(path.join(tempDir.path, 'runner.rc'));
  rcFile.writeAsStringSync('''
    #define VERSION_MAJOR               1
    #define VERSION_MINOR               0
    #define VERSION_PATCH               0
    #define VERSION_BUILD             42
    #define FILEVERSION                1,0,0,42
    #define PRODUCTVERSION             1,0,0,42
    
    // String version info
    BEGIN
        BLOCK "StringFileInfo"
        BEGIN
            BLOCK "040904b0"
            BEGIN
                VALUE "FileVersion", "1.0.0.42"
                VALUE "ProductVersion", "1.0.0"
                VALUE "OriginalFilename", "app_10042.exe"
            END
        END
    END
  ''');
  
  final manager = WindowsVersionManager(
    projectRoot: tempDir.path,
    rcFilePath: rcFile.path,
  );
  
  if (kDebugMode) {
    print('Initial version:');
    final version = await manager.getCurrentVersion();
    print('  Version: ${version['version']}');
    print('  Build: ${version['buildNumber']}');
    
    print('\nUpdating to version 2.1.3 (build 123)...');
  }
  
  await manager.updateVersion(version: '2.1.3', buildNumber: 123);
  
  if (kDebugMode) {
    print('\nUpdated version:');
    final updatedVersion = await manager.getCurrentVersion();
    print('  Version: ${updatedVersion['version']}');
    print('  Build: ${updatedVersion['buildNumber']}');
    
    print('\n.rc file content:');
    print(await rcFile.readAsString());
  }
}

Future<void> testLinuxVersionManager(Directory tempDir) async {
  if (kDebugMode) {
    print('\n--- Testing LinuxVersionManager ---');
  }
  
  // Create a test CMakeLists.txt file
  final cmakeFile = File(path.join(tempDir.path, 'CMakeLists.txt'));
  cmakeFile.writeAsStringSync('''
    cmake_minimum_required(VERSION 3.10)
    project(runner LISTS VERSION 1.0.0)
    
    add_definitions(-DAPP_VERSION="1.0.0" -DAPP_BUILD_NUMBER=1)
    
    add_executable(\${BINARY_NAME} WIN32 MACOSX_BUNDLE
      "main.cc"
      "my_application.cc"
    )
    
    set_target_properties(\${BINARY_NAME} PROPERTIES
      VERSION 1.0.0
      SOVERSION 1
    )
  ''');
  
  final manager = LinuxVersionManager(
    projectRoot: tempDir.path,
    cmakePath: cmakeFile.path,
  );
  
  if (kDebugMode) {
    print('Initial version:');
    final version = await manager.getCurrentVersion();
    print('  Version: ${version['version']}');
    print('  Build: ${version['buildNumber']}');
    
    print('\nUpdating to version 2.1.3 (build 123)...');
  }
  
  await manager.updateVersion(version: '2.1.3', buildNumber: 123);
  
  if (kDebugMode) {
    print('\nUpdated version:');
    final updatedVersion = await manager.getCurrentVersion();
    print('  Version: ${updatedVersion['version']}');
    print('  Build: ${updatedVersion['buildNumber']}');
    
    print('\nCMakeLists.txt content:');
    print(await cmakeFile.readAsString());
  }
}
