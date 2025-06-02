import 'package:better_versions/src/version_patterns.dart';

/// A utility class for formatting version strings according to different patterns.
class VersionFormatter {
  final VersionFormat format;
  final DateTime now;
  
  /// Create a new VersionFormatter with the specified format
  VersionFormatter({
    required this.format,
    DateTime? currentTime,
  }) : now = currentTime ?? DateTime.now();
  
  /// Format a version string according to the specified format
  String formatVersion({
    required int major,
    required int minor,
    required int patch,
    int? buildNumber,
    String? buildMetadata,
  }) {
    final buffer = StringBuffer();
    
    // Add version core (major.minor.patch)
    buffer.write('$major.$minor.$patch');
    
    // Add pre-release if specified
    if (format.preRelease != null) {
      buffer.write('-${format.preRelease}');
    }
    
    // Add build metadata if enabled
    if (format.includeBuildMetadata) {
      final metadata = buildMetadata ?? _generateBuildMetadata(buildNumber);
      if (metadata.isNotEmpty) {
        buffer.write('+$metadata');
      }
    }
    
    return buffer.toString();
  }
  
  /// Generate build metadata based on the format pattern
  String _generateBuildMetadata(int? buildNumber) {
    switch (format.pattern) {
      case VersionPattern.semantic:
        return buildNumber?.toString() ?? '';
        
      case VersionPattern.dateBased:
        final month = now.month.toString().padLeft(2, '0');
        final day = now.day.toString().padLeft(2, '0');
        return '$month$day';
        
      case VersionPattern.timestamp:
        final year = now.year.toString().substring(2);
        final month = now.month.toString().padLeft(2, '0');
        final day = now.day.toString().padLeft(2, '0');
        final hour = now.hour.toString().padLeft(2, '0');
        final minute = now.minute.toString().padLeft(2, '0');
        return '$year$month$day$hour$minute';
        
      case VersionPattern.buildNumber:
        return buildNumber?.toString() ?? '1';
        
      case VersionPattern.custom:
        return _formatCustomBuildMetadata();
    }
  }
  
  /// Format build metadata using a custom format string
  String _formatCustomBuildMetadata() {
    if (format.customFormat == null) return '';
    
    var result = format.customFormat!;
    final now = this.now;
    
    // Replace date and time placeholders
    result = result.replaceAll('{yyyy}', now.year.toString());
    result = result.replaceAll('{yy}', now.year.toString().substring(2));
    result = result.replaceAll('{MM}', now.month.toString().padLeft(2, '0'));
    result = result.replaceAll('{dd}', now.day.toString().padLeft(2, '0'));
    result = result.replaceAll('{HH}', now.hour.toString().padLeft(2, '0'));
    result = result.replaceAll('{mm}', now.minute.toString().padLeft(2, '0'));
    result = result.replaceAll('{ss}', now.second.toString().padLeft(2, '0'));
    
    // Replace build number placeholder if present
    if (result.contains('{build}')) {
      // In a real implementation, you might want to get this from a persistent store
      result = result.replaceAll('{build}', '1');
    }
    
    return result;
  }
  
  /// Parse a version string into its components
  static Map<String, dynamic> parseVersion(String versionString) {
    final result = <String, dynamic>{
      'major': 0,
      'minor': 0,
      'patch': 0,
      'preRelease': null,
      'buildMetadata': null,
    };
    
    try {
      // Split version and build metadata
      final parts = versionString.split('+');
      if (parts.length > 1) {
        result['buildMetadata'] = parts[1];
      }
      
      // Split version core and pre-release
      final versionCore = parts[0].split('-');
      if (versionCore.length > 1) {
        result['preRelease'] = versionCore[1];
      }
      
      // Parse version numbers
      final versionNumbers = versionCore[0].split('.');
      result['major'] = int.tryParse(versionNumbers[0]) ?? 0;
      if (versionNumbers.length > 1) {
        result['minor'] = int.tryParse(versionNumbers[1]) ?? 0;
      }
      if (versionNumbers.length > 2) {
        result['patch'] = int.tryParse(versionNumbers[2]) ?? 0;
      }
    } catch (e) {
      // If parsing fails, return default values
    }
    
    return result;
  }
}
