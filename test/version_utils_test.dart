import 'package:better_versions/src/platform/version_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Version Utils', () {
    test('compareVersions compares versions correctly', () {
      expect(compareVersions('1.0.0', '1.0.0'), equals(0));
      expect(compareVersions('1.0.0', '1.0.1'), lessThan(0));
      expect(compareVersions('1.0.1', '1.0.0'), greaterThan(0));
      expect(compareVersions('1.0.0', '1.1.0'), lessThan(0));
      expect(compareVersions('1.1.0', '1.0.0'), greaterThan(0));
      expect(compareVersions('1.0.0', '2.0.0'), lessThan(0));
      expect(compareVersions('2.0.0', '1.0.0'), greaterThan(0));
      
      // Test with different version lengths
      expect(compareVersions('1.0', '1.0.0'), equals(0));
      expect(compareVersions('1', '1.0.0'), equals(0));
      expect(compareVersions('1.0.0.0', '1.0.0'), equals(0));
    });

    test('parseVersion parses version strings correctly', () {
      expect(parseVersion('1.2.3'), equals([1, 2, 3]));
      expect(parseVersion('4.5.0'), equals([4, 5, 0]));
      expect(parseVersion('6.0.0'), equals([6, 0, 0]));
      expect(parseVersion('7.8.9.10'), equals([7, 8, 9, 10]));
    });

    test('parseVersion throws FormatException for invalid versions', () {
      expect(() => parseVersion(''), throwsA(isA<FormatException>()));
      
      // Test with more than 4 components
      expect(
        () => parseVersion('1.2.3.4.5'),
        throwsA(isA<FormatException>()),
      );
      
      // Test with non-numeric versions
      expect(
        () => parseVersion('1.2.x'),
        throwsA(isA<FormatException>()),
      );
      
      // Test with negative numbers
      expect(
        () => parseVersion('-1.2.3'),
        throwsA(isA<FormatException>()),
      );
      
      // Test with empty components
      expect(
        () => parseVersion('1..2.3'),
        throwsA(isA<FormatException>()),
      );
    });
    
    test('parseVersion handles edge cases', () {
      // Test with leading/trailing dots
      expect(
        () => parseVersion('.1.2.3'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => parseVersion('1.2.3.'),
        throwsA(isA<FormatException>()),
      );
      
      // Test with empty components
      expect(
        () => parseVersion('1..2.3'),
        throwsA(isA<FormatException>()),
      );
    });
    
    test('compareVersions handles edge cases', () {
      // Test with very large numbers
      expect(compareVersions('999999999999999.0.0', '1.0.0'), greaterThan(0));
      expect(compareVersions('1.0.0', '999999999999999.0.0'), lessThan(0));
      
      // Test with leading zeros
      expect(compareVersions('01.02.03', '1.2.3'), equals(0));
      
      // Test with different component counts (normalize to 3 components)
      expect(compareVersions('1.0', '1.0.0'), equals(0));
      expect(compareVersions('1.0.0.0', '1.0.0'), equals(0));
    });
    
    test('parseVersion throws FormatException for invalid versions', () {
      // Test empty string
      expect(
        () => parseVersion(''),
        throwsA(isA<FormatException>()),
      );
      
      // Test too many components
      expect(
        () => parseVersion('1.2.3.4.5'),
        throwsA(isA<FormatException>()),
      );
      
      // Test non-numeric component
      expect(
        () => parseVersion('1.2.x'),
        throwsA(isA<FormatException>()),
      );
      
      // Test negative number
      expect(
        () => parseVersion('-1.2.3'),
        throwsA(isA<FormatException>()),
      );
      
      // Test empty component
      expect(
        () => parseVersion('1..2.3'),
        throwsA(isA<FormatException>()),
      );
    });

    test('isValidVersion validates version strings', () {
      expect(isValidVersion('1.0.0'), isTrue);
      expect(isValidVersion('1.2.3.4'), isTrue);
      expect(isValidVersion('1.0'), isTrue);
      expect(isValidVersion('1'), isTrue);
      
      expect(isValidVersion(''), isFalse);
      expect(isValidVersion('1.2.3.4.5'), isFalse);
      expect(isValidVersion('1.2.x'), isFalse);
      expect(isValidVersion('1.-2.3'), isFalse);
    });

    test('isValidBuildNumber validates build numbers', () {
      expect(isValidBuildNumber(1), isTrue);
      expect(isValidBuildNumber(42), isTrue);
      expect(isValidBuildNumber('1'), isTrue);
      expect(isValidBuildNumber('42'), isTrue);
      
      expect(isValidBuildNumber(0), isFalse);
      expect(isValidBuildNumber(-1), isFalse);
      expect(isValidBuildNumber('0'), isFalse);
      expect(isValidBuildNumber('-1'), isFalse);
      expect(isValidBuildNumber('1.0'), isFalse);
      expect(isValidBuildNumber('abc'), isFalse);
      expect(isValidBuildNumber(null), isFalse);
    });

    test('formatVersion formats version strings correctly', () {
      expect(formatVersion('1'), equals('1.0.0'));
      expect(formatVersion('1.2'), equals('1.2.0'));
      expect(formatVersion('1.2.3'), equals('1.2.3'));
      expect(formatVersion('1.2.3.4'), equals('1.2.3'));
    });

    test('isVersionUpdateValid validates version updates', () {
      // Valid updates
      expect(
        isVersionUpdateValid(
          currentVersion: '1.0.0',
          newVersion: '1.0.1',
          force: false,
        ),
        isTrue,
      );
      
      // Same version is valid
      expect(
        isVersionUpdateValid(
          currentVersion: '1.0.0',
          newVersion: '1.0.0',
          force: false,
        ),
        isTrue,
      );
      
      // Downgrade is invalid without force
      expect(
        isVersionUpdateValid(
          currentVersion: '1.0.1',
          newVersion: '1.0.0',
          force: false,
        ),
        isFalse,
      );
      
      // Downgrade is valid with force
      expect(
        isVersionUpdateValid(
          currentVersion: '1.0.1',
          newVersion: '1.0.0',
          force: true,
        ),
        isTrue,
      );
      
      // Invalid version format
      expect(
        isVersionUpdateValid(
          currentVersion: '1.0.0',
          newVersion: '1.x.0',
          force: false,
        ),
        isFalse,
      );
    });
  });
}
