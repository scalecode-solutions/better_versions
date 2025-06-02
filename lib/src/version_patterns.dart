/// Predefined version patterns for common use cases
enum VersionPattern {
  /// Standard semantic versioning (e.g., 1.2.3)
  semantic,
  
  /// Date-based versioning (e.g., 1.2.31 for Jan 2, 31st day)
  dateBased,
  
  /// Timestamp-based build number (e.g., 1.2.3+2102151230 for 2021-02-15 12:30)
  timestamp,
  
  /// Auto-incrementing build number (e.g., 1.2.3+45)
  buildNumber,
  
  /// Custom pattern (specify your own format)
  custom,
}

/// A class to hold pattern formatting options
class VersionFormat {
  /// The version pattern to use
  final VersionPattern pattern;
  
  /// Custom format string (used when pattern is [VersionPattern.custom])
  final String? customFormat;
  
  /// Whether to include build metadata
  final bool includeBuildMetadata;
  
  /// Pre-release identifier (e.g., 'beta', 'alpha', 'rc.1')
  final String? preRelease;
  
  /// Create a new VersionFormat
  const VersionFormat({
    this.pattern = VersionPattern.semantic,
    this.customFormat,
    this.includeBuildMetadata = true,
    this.preRelease,
  }) : assert(
          pattern != VersionPattern.custom || customFormat != null,
          'Custom format must be provided when pattern is custom',
        );
  
  /// Standard semantic versioning
  static const VersionFormat semantic = VersionFormat(
    pattern: VersionPattern.semantic,
  );
  
  /// Date-based versioning (e.g., 1.2.31 for Jan 2, 31st day)
  static const VersionFormat dateBased = VersionFormat(
    pattern: VersionPattern.dateBased,
  );
  
  /// Timestamp-based build number
  static const VersionFormat timestamp = VersionFormat(
    pattern: VersionPattern.timestamp,
  );
  
  /// Auto-incrementing build number
  static const VersionFormat buildNumber = VersionFormat(
    pattern: VersionPattern.buildNumber,
  );
  
  /// Create a custom format
  static VersionFormat custom(String format) => VersionFormat(
        pattern: VersionPattern.custom,
        customFormat: format,
      );
  
  /// Create a version format with pre-release identifier
  VersionFormat withPreRelease(String preRelease) => VersionFormat(
        pattern: pattern,
        customFormat: customFormat,
        includeBuildMetadata: includeBuildMetadata,
        preRelease: preRelease,
      );
  
  /// Create a version format with build metadata
  VersionFormat withBuildMetadata(bool include) => VersionFormat(
        pattern: pattern,
        customFormat: customFormat,
        includeBuildMetadata: include,
        preRelease: preRelease,
      );
}
