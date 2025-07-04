# TCP ChatSocket – Advanced Cross-Platform Flutter Chat Application

A sophisticated real-time, peer-to-peer chat application built with Flutter and Dart that enables direct TCP socket communication between devices on a local network. The application features automatic server discovery, robust error handling, and enterprise-grade security without external dependencies or cloud services.

## 🚀 Features

### Core Communication
- **🔌 Bi-directional TCP Communication**: Real-time messaging between server and client devices
- **📱💻 Cross-Platform Support**: Android, iOS, macOS, Windows, Linux, and Web
- **🔄 Dynamic Role Switching**: Seamlessly switch between server and client modes without restart
- **📊 Real-time Status Monitoring**: Live connection status with detailed logging and user feedback

### Advanced Discovery & Connectivity
- **🌐 Automatic Server Discovery**: UDP broadcast-based server discovery on local networks
- **🔍 Smart Server Detection**: Automatic cleanup of stale servers with friendly naming
- **🔄 Automatic Reconnection**: Intelligent retry logic with configurable attempts
- **📡 Network Optimization**: Reduced UDP broadcast frequency to minimize network traffic

### Security & Reliability
- **🛡️ Comprehensive Input Validation**: IP address, port, and message sanitization
- **🔒 Message Security**: Control character removal and length validation
- **⚡ Robust Error Handling**: Graceful error recovery with user-friendly messages
- **🧹 Resource Management**: Proper cleanup of all sockets, streams, and timers

### User Experience
- **🌙 Dark Mode Support**: Automatic theme switching based on system preferences
- **📝 Real-time Message Display**: Chat bubbles with sender identification and timestamps
- **🎨 Modern UI**: Material 3 design with responsive layout
- **📱 Intuitive Interface**: Server naming, discovery lists, and status indicators

## 🏗️ Architecture Overview

The application uses an **advanced dual-role architecture** with UDP discovery and automatic reconnection:

```
┌─────────────────┐    UDP Discovery    ┌─────────────────┐
│                 │ ◄─────────────────► │                 │
│   Device A      │                     │   Device B      │
│  (Server Mode)  │                     │  (Client Mode)  │
│                 │    TCP Socket       │                 │
│ • Broadcasts    │ ◄───────────────►   │ • Discovers     │
│   presence      │   Connection        │   servers       │
│ • Listens on    │                     │ • Connects to   │
│   port 5000     │                     │   selected      │
│ • Auto-reconnect│                     │   server        │
└─────────────────┘                     └─────────────────┘
```

## 🧱 Technical Stack

- **Flutter**: Cross-platform UI framework with Material 3
- **Dart**: Programming language with native socket support
- **dart:io**: Low-level socket programming library
- **StreamController**: Reactive programming for real-time updates
- **UDP Broadcasting**: Automatic server discovery protocol

## 🔧 How It Works

### Core Communication Flow

1. **Server Discovery**: UDP broadcasts enable automatic server detection
2. **Connection Establishment**: TCP socket connection between devices
3. **Bi-directional Messaging**: Real-time message exchange
4. **Automatic Recovery**: Smart reconnection on connection loss

### Advanced Features

#### UDP Server Discovery
- **Broadcast Frequency**: Optimized to 4-second intervals
- **Server Expiry**: Automatic cleanup of stale servers (10-second timeout)
- **Friendly Naming**: Custom server names for easy identification
- **Cross-Platform**: Works on all supported platforms

#### Automatic Reconnection
- **Retry Logic**: Up to 3 automatic reconnection attempts
- **Progressive Delays**: 2-second intervals between attempts
- **Status Feedback**: Clear indication of reconnection progress
- **Graceful Fallback**: Manual reconnection after maximum attempts

#### Security & Validation
- **Input Sanitization**: All user inputs are validated and sanitized
- **Message Security**: Control character removal and length limits
- **Error Prevention**: Comprehensive validation prevents common issues

## 📁 Project Structure

```
lib/
├── main.dart                    # Application entry point with theme support
├── chat_screen.dart             # Main UI with discovery and reconnection
├── socket_service.dart          # Core TCP socket implementation
├── udp_discovery_service.dart   # UDP server discovery service
├── input_validator.dart         # Input validation and sanitization
├── models/
│   └── chat_message.dart        # Message data model
└── widgets/
    └── message_bubble.dart      # Chat message UI component
```

## 🔌 Socket Implementation Details

### Enhanced SocketService Class

```dart
class SocketService {
  ServerSocket? _serverSocket;    // For server mode
  Socket? _clientSocket;          // For client mode & server's client connection
  final _messageController = StreamController<String>.broadcast();
  final _statusController = StreamController<ConnectionStatus>.broadcast();
  
  // Enhanced with automatic reconnection
  Future<void> reconnect() async { /* ... */ }
  Future<void> disconnect() async { /* ... */ }
}
```

### UDP Discovery Service

```dart
class UdpDiscoveryService {
  static const Duration broadcastInterval = Duration(seconds: 4);
  
  // Server broadcasting with friendly names
  Future<void> startBroadcast(String serverIp, int serverPort, String serverName) async { /* ... */ }
  
  // Client discovery with automatic cleanup
  Future<Stream<ServerInfo>> listenForServers() async { /* ... */ }
}
```

### Input Validation System

```dart
class InputValidator {
  static String? validateIpAddress(String ip) { /* ... */ }
  static int? validatePort(String port) { /* ... */ }
  static String? validateMessage(String message) { /* ... */ }
  static String? validateServerName(String name) { /* ... */ }
}
```

## 🌐 Platform-Specific Configurations

### Android Configuration

**Permissions** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```

**Network Security** (`android/app/src/main/res/xml/network_security_config.xml`):
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">10.0.0.0/8</domain>
        <domain includeSubdomains="true">192.168.0.0/16</domain>
        <domain includeSubdomains="true">172.16.0.0/12</domain>
    </domain-config>
</network-security-config>
```

### iOS Configuration

**Info.plist** (`ios/Runner/Info.plist`):
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

### macOS Configuration

**DebugProfile.entitlements** and **Release.entitlements**:
```xml
<key>com.apple.security.network.server</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
```

### Windows Configuration

**runner.exe.manifest**:
```xml
<network-capabilities>
    <capability name="internetClient"/>
</network-capabilities>
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.0 or higher
- **Dart SDK**: Version 2.17 or higher
- **Development Environment**: Android Studio, VS Code, or your preferred IDE
- **Target Devices**: At least two devices on the same local network

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd chat_socket
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Build for your target platforms**:
   ```bash
   # For Android
   flutter build apk --release
   
   # For iOS
   flutter build ios --release
   
   # For macOS
   flutter build macos --release
   
   # For Windows
   flutter build windows --release
   ```

## 🧪 Testing Instructions

### Basic Functionality Test

1. **Start the Server**:
   - Launch the app on Device A
   - Select "Server" mode
   - Enter a server name (e.g., "Alice's MacBook")
   - Enter port number (e.g., 5000)
   - Tap "Connect"
   - Verify status shows "Connected"

2. **Discover and Connect Client**:
   - Launch the app on Device B
   - Select "Client" mode
   - Wait for Device A to appear in "Discovered Servers"
   - Tap on the discovered server to auto-fill connection details
   - Tap "Connect"
   - Verify status shows "Connected"

3. **Test Messaging**:
   - Send messages from both devices
   - Verify messages appear with correct sender identification
   - Check that timestamps are displayed correctly

### Advanced Feature Testing

#### Automatic Reconnection Test
1. **Establish Connection**: Connect server and client
2. **Simulate Disconnection**: Turn off Wi-Fi on one device
3. **Observe Reconnection**: Watch for automatic reconnection attempts
4. **Verify Recovery**: Confirm connection is restored

#### Server Discovery Test
1. **Start Multiple Servers**: Run the app on 3+ devices as servers
2. **Client Discovery**: Run client on another device
3. **Verify Discovery**: Check that all servers appear in the list
4. **Test Expiry**: Turn off one server and verify it disappears from the list

#### Input Validation Test
1. **Invalid IP**: Try connecting with invalid IP addresses
2. **Invalid Port**: Test port numbers outside valid range (1-65535)
3. **Empty Messages**: Attempt to send empty or whitespace-only messages
4. **Long Messages**: Test messages exceeding the 256-character limit

#### Dark Mode Test
1. **System Theme**: Change your system theme between light and dark
2. **App Adaptation**: Verify the app automatically adapts to the system theme
3. **UI Elements**: Check that all UI elements are properly themed

### Network Configuration Test

#### Local Network Requirements
- **Same Network**: Ensure all devices are on the same Wi-Fi network
- **No VPN**: Disable VPN connections that might interfere with local discovery
- **Firewall Settings**: Ensure local network traffic is allowed
- **Router Settings**: Verify AP isolation is disabled

#### Troubleshooting Common Issues

**Server Not Discovered**:
- Check firewall settings on the server device
- Ensure both devices are on the same network
- Verify UDP port 45678 is not blocked
- Try disabling VPN if active

**Connection Fails**:
- Verify the IP address is correct
- Check that the port is not in use by another application
- Ensure the server is running and listening
- Check network permissions on both devices

**Messages Not Delivered**:
- Verify both devices show "Connected" status
- Check for any error messages in the status banner
- Try sending a test message from both directions
- Restart the connection if necessary

## 🔧 Development

### Building for Different Platforms

```bash
# Debug builds
flutter run

# Release builds
flutter build apk --release
flutter build ios --release
flutter build macos --release
flutter build windows --release
```

### Code Structure

The application follows a clean architecture pattern:

- **UI Layer**: `chat_screen.dart` handles user interaction and display
- **Service Layer**: `socket_service.dart` and `udp_discovery_service.dart` manage communication
- **Validation Layer**: `input_validator.dart` ensures data integrity
- **Model Layer**: `chat_message.dart` defines data structures

### Adding New Features

1. **UI Changes**: Modify `chat_screen.dart` for interface updates
2. **Communication**: Extend `socket_service.dart` for new protocols
3. **Discovery**: Enhance `udp_discovery_service.dart` for new discovery methods
4. **Validation**: Add new validation rules to `input_validator.dart`

## 📊 Performance Characteristics

- **UDP Broadcast Frequency**: 4-second intervals (optimized for network efficiency)
- **Server Expiry Time**: 10 seconds (balances responsiveness with accuracy)
- **Reconnection Attempts**: 3 attempts with 2-second delays
- **Message Length Limit**: 256 characters (prevents buffer issues)
- **Server Name Limit**: 32 characters (maintains clean UI)

## 🔒 Security Considerations

- **Input Validation**: All user inputs are validated and sanitized
- **Message Sanitization**: Control characters are removed from messages
- **Network Security**: Uses local network only, no external dependencies
- **Error Handling**: Comprehensive error management prevents crashes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues, questions, or contributions:
- Create an issue on the repository
- Check the troubleshooting section above
- Ensure you're testing on supported platforms


**Built with ❤️ using Flutter and Dart**

## 👨‍💻 Developed By

This project was fully developed, optimized, and documented by 
**[Abdalsslam Amino](https://www.linkedin.com/in/abdalsslam-amino-3b3667241/)**  
GitHub Profile: [github.com/AbdulsalamAmino](https://github.com/AbdulsalamAmino)

If you like this project or want to follow more updates, feel free to ⭐ the repository and connect with me!

---

## 📂 Project on GitHub

[🔗 View Source Code on GitHub](https://github.com/AbdulsalamAmino)

---

## �� Stay Tuned!

**Don't forget to follow and support the developer — more cool Flutter apps are on the way! 🚀**
