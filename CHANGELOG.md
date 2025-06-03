# Changelog

## [0.5.1]

### General
- Added comprehensive date-based build number support across all platforms
- Improved test coverage for version management
- Enhanced documentation with platform-specific examples
- Added more detailed logging for version updates

### macOS Version Manager

#### Added
- Support for date-based build numbers (YYMMDDHHmmss format)
- Improved error handling for Info.plist parsing
- Added validation for macOS version format
- Enhanced test coverage with edge cases

## [0.5.0]

### macOS Version Manager

#### Added
- Dedicated macOS version manager implementation
- Separate handling of macOS Info.plist files
- Support for macOS-specific version management
- Comprehensive test coverage for macOS version management
- Platform-specific version validation
- Dry-run support for version updates
- Force update capability for version downgrades

## [0.4.1]

### Linux Version Manager

#### Added
- Support for date-based build numbers
- Improved CMake file parsing
- Better error messages for file operations

## [0.4.0]

### Linux Version Manager

#### Added
- Initial Linux version manager implementation
- Support for updating version in `CMakeLists.txt`
- Version and build number validation
- Dry-run support for Linux version updates

#### Fixed
- Fixed version parsing in CMake files
- Improved error handling for file operations
- Added comprehensive test coverage

## [0.3.1]

### Windows Version Manager

#### Added
- Support for date-based build numbers in .rc files
- Improved version string formatting
- Better handling of version components

## [0.3.0]

### Windows Version Manager

#### Added
- Initial Windows version manager implementation
- Support for updating version in `CMakeLists.txt` and `.rc` files
- Version and build number validation
- Dry-run support for Windows version updates

#### Fixed
- Fixed version string formatting in resource files
- Improved error handling for file operations
- Added comprehensive test coverage

## [0.2.1]

### iOS Version Manager

#### Added
- Support for date-based build numbers
- Improved Info.plist parsing
- Better error handling for version updates

## [0.2.0]

### iOS Version Manager

#### Added
- Initial iOS version manager implementation
- Support for updating `CFBundleShortVersionString` and `CFBundleVersion` in `Info.plist`
- Version and build number validation
- Dry-run support for iOS version updates

#### Fixed
- Fixed XML parsing for Info.plist
- Improved error handling for file operations
- Added comprehensive test coverage

## [0.1.4]

### Android Version Manager

#### Added
- Support for date-based build numbers
- Improved Gradle file parsing
- Better error messages for invalid version formats

## [0.1.3]

### Android Version Manager

#### Added
- Initial Android version manager implementation
- Support for updating version in `build.gradle`
- Version and build number validation
- Dry-run support for version updates

#### Fixed
- Fixed version comparison for different version lengths
- Resolved edge cases in version parsing
- Improved error messages for invalid version formats
- Fixed build number validation for various input types

## [0.1.2]

### Android Version Manager

#### Fixed
- Fixed version comparison for different version lengths
- Resolved edge cases in version parsing
- Improved error messages for invalid version formats
- Fixed build number validation for various input types

## [0.1.1] - 2025-05-29

### Core Utilities (0.1.1)

#### Added
- Support for updating version in `build.gradle`
- Version and build number validation
- Dry-run support for version updates

#### Changed
- Improved error handling for file operations
- More robust version update logic
- Better Gradle file parsing

## [0.1.1] - 2025-05-29

### Core Utilities (0.1.1)

#### Added
- Core version utilities for semantic version handling
- Version comparison and validation functions
- Support for pre-release versions and build metadata
- Version formatting utilities
- Basic command-line interface structure

#### Fixed
- Initial lint warnings and code quality issues
- Documentation improvements
- Example application setup

## [0.1.0] - 2025-05-28

### Initial Release (0.1.0)

#### Added
- Initial project setup
- Basic package structure
- License and contribution guidelines
- Initial documentation
- Basic example implementation

## [0.0.1] - 2025-05-27

* Initial project setup and scaffolding
