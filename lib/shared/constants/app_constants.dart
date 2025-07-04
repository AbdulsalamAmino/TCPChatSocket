/// Application constants
class AppConstants {
  // Network constants
  static const int defaultPort = 5000;
  static const int udpDiscoveryPort = 45678;
  static const Duration connectionTimeout = Duration(seconds: 10);
  
  // UI constants
  static const int maxMessageLength = 256;
  static const int maxServerNameLength = 32;
  
  // Discovery constants
  static const Duration serverExpiryTimeout = Duration(seconds: 10);
  static const Duration broadcastInterval = Duration(seconds: 4);
} 