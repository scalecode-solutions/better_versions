import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart' as xml;
import 'version_manager_platform.dart';

/// Manages version information for macOS platform
class MacOSVersionManager extends PlatformVersionManager {
  /// Path to the Info.plist file
  final String _plistPath;

  MacOSVersionManager({
    required super.projectRoot,
    super.dryRun,
    String? plistPath,
  }) : _plistPath = plistPath ?? _findPlistPath(projectRoot);

  @override
  String get platformName => 'macos';

  @override
  bool get isAvailable => File(_plistPath).existsSync();

  static String _findPlistPath(String projectRoot) {
    // Check for macOS directory structure
    final macosDir = Directory(path.join(projectRoot, 'macos'));
    if (!macosDir.existsSync()) {
      throw Exception('macOS directory not found in project root');
    }

    // Look for Info.plist in the standard location
    final plistFile = File(path.join(
      macosDir.path,
      'Runner',
      'Info.plist',
    ));

    if (!plistFile.existsSync()) {
      throw Exception('Info.plist not found in macOS project');
    }

    return plistFile.path;
  }

  @override
  Future<Map<String, dynamic>> getCurrentVersion() async {
    final file = File(_plistPath);
    final content = await file.readAsString();
    
    final document = xml.XmlDocument.parse(content);
    final dicts = document.findAllElements('dict');
    if (dicts.isEmpty) {
      throw Exception('No dict element found in Info.plist');
    }
    
    String? version;
    String? buildNumber;
    
    // Get all key-value pairs from the first dict
    final dict = dicts.first;
    xml.XmlElement? currentKey;
    
    for (final node in dict.children) {
      if (node is xml.XmlElement) {
        if (node.name.local == 'key') {
          currentKey = node;
        } else if (currentKey != null && (node.name.local == 'string' || node.name.local == 'integer')) {
          final key = currentKey.text.trim();
          final value = node.text.trim();
          
          if (key == 'CFBundleShortVersionString') {
            version = value;
          } else if (key == 'CFBundleVersion') {
            buildNumber = value;
          }
          currentKey = null;
        }
      }
    }
    
    if (version == null) {
      throw Exception('CFBundleShortVersionString not found in Info.plist');
    }
    
    return {
      'version': version,
      'buildNumber': int.tryParse(buildNumber ?? '1') ?? 1,
    };
  }

  @override
  Future<void> updateVersion({
    required String version,
    required int buildNumber,
    String? preRelease,
    bool force = false,
  }) async {
    if (!isAvailable) {
      throw Exception('macOS project not found at $projectRoot');
    }

    final current = await getCurrentVersion();
    final currentVersion = current['version'] as String;
    final currentBuild = current['buildNumber'] as int;

    // Check if version is being downgraded
    if (!force && _compareVersions(version, currentVersion) < 0) {
      throw Exception('New version $version is older than current version $currentVersion. Use force=true to override.');
    }

    // Check if build number is being decreased
    if (!force && buildNumber < currentBuild) {
      throw Exception('New build number $buildNumber is less than current build number $currentBuild. Use force=true to override.');
    }

    if (dryRun) {
      if (kDebugMode) {
        print('[macOS]: Would update version to: $version (build: $buildNumber)');
      }
      return;
    }

    final file = File(_plistPath);
    var content = await file.readAsString();
    
    // Update CFBundleShortVersionString
    content = content.replaceAllMapped(
      RegExp(r'(<key>CFBundleShortVersionString</key>\s*<string>)([^<]+)(</string>)'),
      (match) => '${match.group(1)}$version${match.group(3)}',
    );
    
    // Update CFBundleVersion
    content = content.replaceAllMapped(
      RegExp(r'(<key>CFBundleVersion</key>\s*<string>)([^<]+)(</string>)'),
      (match) => '${match.group(1)}$buildNumber${match.group(3)}',
    );
    
    await file.writeAsString(content);
    if (kDebugMode) {
      print('[macOS]: Updated macOS version to $version (build: $buildNumber)');
    }
  }

  int _compareVersions(String a, String b) {
    // Handle pre-release versions
    final aParts = a.split('-');
    final bParts = b.split('-');
    
    // Compare main version numbers (before any '-') using semantic versioning
    final aMain = aParts[0].split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final bMain = bParts[0].split('.').map((p) => int.tryParse(p) ?? 0).toList();
    
    final maxLength = aMain.length > bMain.length ? aMain.length : bMain.length;
    
    for (var i = 0; i < maxLength; i++) {
      final aPart = i < aMain.length ? aMain[i] : 0;
      final bPart = i < bMain.length ? bMain[i] : 0;
      
      if (aPart < bPart) return -1;
      if (aPart > bPart) return 1;
    }
    
    // If main versions are equal, check for pre-release versions
    final aHasPre = aParts.length > 1;
    final bHasPre = bParts.length > 1;
    
    if (aHasPre && !bHasPre) return -1; // Pre-release is lower than release
    if (!aHasPre && bHasPre) return 1;   // Release is higher than pre-release
    if (!aHasPre && !bHasPre) return 0;  // Both are equal releases
    
    // Both have pre-release versions, compare them
    final aPre = aParts[1];
    final bPre = bParts[1];
    
    // Simple lexicographical comparison for pre-release versions
    return aPre.compareTo(bPre);
  }
}
