# Changelog

**Developed by [Abdalssalam Amino](https://github.com/AbdulsalamAmino)**

All notable changes to the TCP ChatSocket application will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-07-05

### Added
- **UDP Broadcast Server Discovery**: Automatic server discovery using UDP broadcasts on local networks
- **Server Name Support**: Custom server names for easy identification in discovery lists
- **Automatic Reconnection**: Intelligent retry logic with up to 3 attempts and 2-second delays
- **Input Validation System**: Comprehensive validation for IP addresses, ports, messages, and server names
- **Dark Mode Support**: Automatic theme switching based on system preferences with Material 3 design
- **Enhanced Error Handling**: User-friendly error messages with color-coded status feedback
- **Resource Management**: Proper cleanup of all sockets, streams, and timers to prevent memory leaks
- **Server Expiry System**: Automatic cleanup of stale servers with 10-second timeout
- **Network Optimization**: Reduced UDP broadcast frequency from 2s to 4s for better performance
- **Message Sanitization**: Control character removal and length validation for security
- **Comprehensive Logging**: Platform-specific logging with timestamps for debugging
- **Cross-Platform Network Permissions**: Complete configuration for Android, iOS, macOS, and Windows

### Changed
- **UDP Discovery Service**: Completely refactored with optimized broadcasting and discovery
- **Connection Status Feedback**: Enhanced status messages with detailed progress indicators
- **UI/UX Improvements**: Modern Material 3 design with responsive layout and better accessibility
- **Error Recovery**: Graceful error handling with automatic fallback to manual reconnection
- **Message Display**: Enhanced chat bubbles with improved styling and timestamp formatting
- **Server Discovery UI**: Card-based server list with friendly names and auto-fill functionality
- **Theme System**: Implemented system-based theme detection with light/dark mode support

### Fixed
- **Memory Leaks**: Proper disposal of all resources including sockets, streams, and timers
- **Connection Stability**: Improved error handling and automatic recovery mechanisms
- **Input Validation**: Prevention of invalid IP addresses, ports, and malformed messages
- **Platform Compatibility**: Fixed network permissions and configurations for all supported platforms
- **UDP Broadcast Issues**: Resolved firewall and network interface binding problems
- **UI Responsiveness**: Fixed layout issues and improved cross-platform compatibility
- **Error Messages**: Clearer, more actionable error feedback for users

### Security
- **Input Sanitization**: All user inputs are now validated and sanitized
- **Message Security**: Control characters removed from messages to prevent injection
- **Length Validation**: Message and server name length limits to prevent buffer issues
- **Network Security**: Local network-only communication with no external dependencies

## [0.2.0] - 2025-06-20

### Added
- **Connection Status Monitoring**: Real-time connection status with detailed logging
- **Bi-directional Communication**: Full TCP socket communication between server and client
- **Cross-Platform Support**: Android, iOS, macOS, and Windows compatibility
- **Dynamic Role Switching**: Ability to switch between server and client modes
- **Message History**: Real-time message display with sender identification
- **Platform-Specific Configurations**: Network permissions and security settings for all platforms

### Changed
- **Socket Service**: Enhanced with comprehensive error handling and status management
- **UI Layout**: Improved connection interface with better user experience
- **Error Handling**: More robust error management with user feedback

### Fixed
- **Release Build Issues**: Resolved network permission problems in release builds
- **Platform Permissions**: Fixed Android network security and iOS transport security
- **Socket Communication**: Improved connection reliability and error recovery

## [0.1.0] - 2025-06-19

### Added
- **Basic TCP Socket Communication**: Initial implementation of server-client socket communication
- **Flutter UI Framework**: Cross-platform user interface with Material Design
- **Core Architecture**: Basic project structure with main components
- **Platform Support**: Initial Android and iOS support
- **Basic Error Handling**: Fundamental error management and user feedback

### Changed
- **Project Structure**: Organized code into logical components and services
- **UI Components**: Basic chat interface with message display

### Fixed
- **Initial Setup**: Basic configuration and dependency management
- **Core Functionality**: Fundamental TCP socket communication working

---

## Version History

- **1.0.0** - Production-ready release with advanced features and comprehensive testing
- **0.2.0** - Enhanced functionality with cross-platform support and improved reliability
- **0.1.0** - Initial development version with basic TCP communication

## Migration Guide

### From 0.2.0 to 1.0.0
- **New UDP Discovery**: Servers now automatically broadcast their presence
- **Enhanced UI**: Updated to Material 3 design with dark mode support
- **Improved Security**: All inputs are now validated and sanitized
- **Better Error Handling**: More comprehensive error messages and recovery

### From 0.1.0 to 0.2.0
- **Cross-Platform Support**: Added macOS and Windows compatibility
- **Enhanced Reliability**: Improved connection stability and error recovery
- **Platform Configurations**: Added necessary permissions and security settings

## Future Roadmap

### Planned for 1.1.0
- **Message Encryption**: Optional end-to-end encryption for messages
- **File Sharing**: Support for sending images and files
- **Multiple Clients**: Server support for multiple simultaneous clients
- **Persistent History**: Local storage for chat message history

### Planned for 1.2.0
- **Push Notifications**: Background message alerts
- **Advanced Discovery**: mDNS/Bonjour support for enhanced server discovery
- **Connection Metrics**: Network performance monitoring and statistics
- **Custom Protocols**: Enhanced message framing and compression

---

## Contributing

When contributing to this project, please update this changelog with your changes following the format above. Include:

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Fixed**: Bug fixes
- **Removed**: Removed features or functionality

## License

This project is licensed under the MIT License - see the LICENSE file for details.