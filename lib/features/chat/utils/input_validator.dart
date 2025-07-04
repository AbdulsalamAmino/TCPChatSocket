import 'dart:io';

class InputValidator {
  static const int maxMessageLength = 256;
  static const int minPort = 1;
  static const int maxPort = 65535;

  /// Validates and sanitizes an IP address
  static String? validateIpAddress(String ip) {
    if (ip.trim().isEmpty) return null;
    
    try {
      final address = InternetAddress.tryParse(ip.trim());
      if (address == null) return null;
      
      // Ensure it's an IPv4 address
      if (address.type != InternetAddressType.IPv4) return null;
      
      return address.address;
    } catch (e) {
      return null;
    }
  }

  /// Validates a port number
  static int? validatePort(String port) {
    final portNum = int.tryParse(port.trim());
    if (portNum == null) return null;
    
    if (portNum < minPort || portNum > maxPort) return null;
    
    return portNum;
  }

  /// Sanitizes and validates a chat message
  static String? validateMessage(String message) {
    if (message.trim().isEmpty) return null;
    
    // Remove control characters and trim
    final sanitized = message
        .trim()
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remove control chars
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
    
    if (sanitized.isEmpty) return null;
    
    if (sanitized.length > maxMessageLength) {
      return sanitized.substring(0, maxMessageLength);
    }
    
    return sanitized;
  }

  /// Validates a server name
  static String? validateServerName(String name) {
    if (name.trim().isEmpty) return null;
    
    final sanitized = name
        .trim()
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remove control chars
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
    
    if (sanitized.isEmpty) return null;
    
    // Limit server name length
    if (sanitized.length > 32) {
      return sanitized.substring(0, 32);
    }
    
    return sanitized;
  }

  /// Gets user-friendly error messages for validation failures
  static String getErrorMessage(String field, String? value) {
    switch (field.toLowerCase()) {
      case 'ip':
        return 'Please enter a valid IPv4 address (e.g., 192.168.1.100)';
      case 'port':
        return 'Please enter a valid port number (1-65535)';
      case 'message':
        return 'Message cannot be empty and must be under $maxMessageLength characters';
      case 'server name':
        return 'Please enter a server name (1-32 characters)';
      default:
        return 'Invalid $field';
    }
  }
} 