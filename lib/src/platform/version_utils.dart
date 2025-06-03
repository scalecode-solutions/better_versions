import 'package:meta/meta.dart';

/// Compares two version strings in the format X[.Y[.Z[.W]]]
/// Returns:
///   - a negative value if version1 < version2
///   - zero if version1 == version2
///   - a positive value if version1 > version2
/// 
/// Throws [FormatException] if either version string is not a valid version.
int compareVersions(String version1, String version2) {
  final v1 = parseVersion(version1);
  final v2 = parseVersion(version2);
  
  // Compare each component
  for (var i = 0; i < v1.length || i < v2.length; i++) {
    final component1 = i < v1.length ? v1[i] : 0;
    final component2 = i < v2.length ? v2[i] : 0;
    
    final comparison = component1.compareTo(component2);
    if (comparison != 0) {
      return comparison;
    }
  }
  
  return 0;
}

/// Parses a version string into a list of integers.
/// 
/// A version string should be in the format X[.Y[.Z[.W]]] where X, Y, Z, and W
/// are non-negative integers. The string can have 1 to 4 components.
/// 
/// Throws [FormatException] if the version string is invalid.
@visibleForTesting
List<int> parseVersion(String version) {
  if (version.isEmpty) {
    throw const FormatException('Version string cannot be empty');
  }
  
  final components = version.split('.');
  
  if (components.length > 4) {
    throw FormatException(
      'Version string "$version" has more than 4 components',
      version,
    );
  }
  
  try {
    return components.map((s) {
      final value = int.parse(s);
      if (value < 0) {
        throw FormatException('Version component cannot be negative: $value');
      }
      return value;
    }).toList();
  } on FormatException catch (e) {
    throw FormatException(
      'Invalid version component in "$version": ${e.message}',
      version,
    );
  }
}

/// Validates that a version string is in the correct format.
/// 
/// Returns `true` if the version string is valid, `false` otherwise.
bool isValidVersion(String version) {
  try {
    parseVersion(version);
    return true;
  } catch (e) {
    return false;
  }
}

/// Validates that a build number is a positive integer.
/// 
/// Returns `true` if the build number is valid, `false` otherwise.
bool isValidBuildNumber(dynamic buildNumber) {
  if (buildNumber is int) {
    return buildNumber > 0;
  } else if (buildNumber is String) {
    try {
      return int.parse(buildNumber) > 0;
    } catch (e) {
      return false;
    }
  }
  return false;
}

/// Formats a version string to ensure it has exactly 3 components (X.Y.Z).
/// 
/// If the input has fewer than 3 components, it's padded with zeros.
/// If it has more than 3 components, extra components are truncated.
String formatVersion(String version) {
  final components = parseVersion(version);
  
  // Ensure we have exactly 3 components
  while (components.length < 3) {
    components.add(0);
  }
  
  return components.take(3).join('.');
}

/// Validates that a new version is greater than or equal to the current version.
/// 
/// Returns `true` if the new version is valid, `false` otherwise.
/// If [force] is `true`, the version check is skipped.
bool isVersionUpdateValid({
  required String currentVersion,
  required String newVersion,
  required bool force,
}) {
  if (force) return true;
  
  try {
    return compareVersions(newVersion, currentVersion) >= 0;
  } catch (e) {
    return false;
  }
}
