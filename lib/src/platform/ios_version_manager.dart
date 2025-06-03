import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart' as xml;
import 'version_manager_platform.dart';

/// Manages version information for iOS and macOS platforms
class IOSVersionManager extends PlatformVersionManager {
  /// Path to the Info.plist file
  final String _plistPath;

  IOSVersionManager({
    required super.projectRoot,
    super.dryRun,
    String? plistPath,
  }) : _plistPath = plistPath ?? _findPlistPath(projectRoot);

  @override
  String get platformName => 'ios';

  @override
  bool get isAvailable => File(_plistPath).existsSync();

  @override
  Future<Map<String, dynamic>> getCurrentVersion() async {
    final file = File(_plistPath);
    if (!await file.exists()) {
      return <String, dynamic>{};
    }

    final content = await file.readAsString();
    final document = xml.XmlDocument.parse(content);
    
    final result = <String, dynamic>{};
    
    // Get CFBundleShortVersionString
    final shortVersionNode = _findPlistValue(document, 'CFBundleShortVersionString');
    if (shortVersionNode != null) {
      result['version'] = shortVersionNode.innerText;
    }
    
    // Get CFBundleVersion
    final bundleVersionNode = _findPlistValue(document, 'CFBundleVersion');
    if (bundleVersionNode != null) {
      result['buildNumber'] = int.tryParse(bundleVersionNode.innerText) ?? 1;
    }
    
    return result;
  }

  @override
  Future<void> updateVersion({
    required String version,
    required int buildNumber,
    String? preRelease,
    bool force = false,
  }) async {
    // Validate version format (X.Y.Z)
    if (!RegExp(r'^\d+(\.\d+){0,2}$').hasMatch(version)) {
      throw ArgumentError('version must be in format X[.Y[.Z]]');
    }
    
    // Validate build number is a positive integer
    if (buildNumber <= 0) {
      throw ArgumentError('buildNumber must be a positive integer');
    }

    final file = File(_plistPath);
    if (!await file.exists()) {
      throw FileSystemException('Info.plist not found at $_plistPath');
    }

    final content = await file.readAsString();
    final document = xml.XmlDocument.parse(content);
    var updated = false;

    // Update CFBundleShortVersionString (marketing version)
    final shortVersionNode = _findPlistValue(document, 'CFBundleShortVersionString');
    if (shortVersionNode != null || force) {
      final currentVersion = shortVersionNode?.innerText ?? '0.0.0';
      
      if (!force && !_isVersionNewer(version, currentVersion)) {
        log('New version $version is not newer than current version $currentVersion');
        return;
      }
      
      _updatePlistValue(
        document,
        'CFBundleShortVersionString',
        version,
      );
      updated = true;
    }

    // Update CFBundleVersion (build number)
    final bundleVersionNode = _findPlistValue(document, 'CFBundleVersion');
    if (bundleVersionNode != null || force) {
      final currentBuildStr = bundleVersionNode?.innerText ?? '0';
      final currentBuild = int.tryParse(currentBuildStr) ?? 0;
      
      if (!force && buildNumber <= currentBuild) {
        throw ArgumentError('New buildNumber $buildNumber must be greater than current build $currentBuildStr');
      }
      
      _updatePlistValue(
        document,
        'CFBundleVersion',
        buildNumber.toString(),
      );
      updated = true;
    }

    if (updated) {
      if (!dryRun) {
        await File(_plistPath).writeAsString(document.toXmlString(pretty: true));
        log('Updated iOS/macOS version to $version (build: $buildNumber)');
      } else {
        log('Would update iOS/macOS version to $version (build: $buildNumber)');
      }
    }
  }

  /// Checks if newVersion is newer than currentVersion
  bool _isVersionNewer(String newVersion, String currentVersion) {
    try {
      final newParts = newVersion.split('.').map(int.parse).toList();
      final currentParts = currentVersion.split('.').map(int.parse).toList();
      
      // Pad with zeros to ensure equal length
      final maxLength = newParts.length > currentParts.length ? newParts.length : currentParts.length;
      while (newParts.length < maxLength) {
        newParts.add(0);
      }
      while (currentParts.length < maxLength) {
        currentParts.add(0);
      }
      
      for (var i = 0; i < maxLength; i++) {
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
      }
      return false; // Versions are equal
    } catch (e) {
      // If version parsing fails, assume it's newer to be safe
      return true;
    }
  }

  static String _findPlistPath(String projectRoot) {
    // Check iOS path first
    final iosPath = path.join(projectRoot, 'ios', 'Runner', 'Info.plist');
    if (File(iosPath).existsSync()) {
      return iosPath;
    }

    // Check macOS path
    final macosPath = path.join(projectRoot, 'macos', 'Runner', 'Info.plist');
    if (File(macosPath).existsSync()) {
      return macosPath;
    }

    // Default to iOS path
    return iosPath;
  }

  xml.XmlElement? _findPlistValue(xml.XmlDocument document, String key) {
    try {
      return document.findAllElements('key')
          .firstWhere((element) => element.innerText == key)
          .nextElementSibling;
    } catch (e) {
      return null;
    }
  }

  /// Updates a value in the Info.plist file
  void _updatePlistValue(
    xml.XmlDocument document,
    String key,
    String value,
  ) {
    try {
      final keyElement = document.findAllElements('key')
          .firstWhere((element) => element.innerText == key);
      
      final valueElement = keyElement.nextElementSibling!;
      // Update the text content of the value element
      valueElement.children.clear();
      valueElement.children.add(xml.XmlText(value));
    } catch (e) {
      // If key doesn't exist, add it
      final dict = document.findAllElements('dict').first;
      dict.children.add(xml.XmlElement(
        xml.XmlName('key'),
        [],
        [xml.XmlText(key)],
      ));
      dict.children.add(xml.XmlElement(
        xml.XmlName('string'),
        [],
        [xml.XmlText(value)],
      ));
    }
  }
}
