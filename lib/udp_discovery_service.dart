import 'dart:async';
import 'dart:convert';
import 'dart:io';

class UdpDiscoveryService {
  static const int udpPort = 45678;
  static const Duration broadcastInterval = Duration(seconds: 4);

  RawDatagramSocket? _broadcastSocket;
  RawDatagramSocket? _listenSocket;
  Timer? _broadcastTimer;

  // Server: Start broadcasting
  Future<void> startBroadcast(String serverIp, int serverPort, String serverName) async {
    _broadcastSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _broadcastTimer = Timer.periodic(broadcastInterval, (_) {
      final msg = jsonEncode({
        'ip': serverIp, 
        'port': serverPort, 
        'name': serverName,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
      _broadcastSocket?.send(
        utf8.encode(msg),
        InternetAddress('255.255.255.255'),
        udpPort,
      );
    });
    _broadcastSocket?.broadcastEnabled = true;
  }

  // Server: Stop broadcasting
  void stopBroadcast() {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _broadcastSocket?.close();
    _broadcastSocket = null;
  }

  // Client: Listen for broadcasts
  Future<Stream<ServerInfo>> listenForServers() async {
    final controller = StreamController<ServerInfo>.broadcast();
    _listenSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, udpPort, reuseAddress: true, reusePort: true);
    _listenSocket?.broadcastEnabled = true;
    _listenSocket?.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = _listenSocket?.receive();
        if (datagram != null) {
          try {
            final data = utf8.decode(datagram.data);
            final json = jsonDecode(data);
            final ip = json['ip'] as String;
            final port = json['port'] as int;
            final name = json['name'] as String? ?? 'Unknown Server';
            final timestamp = json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;
            controller.add(ServerInfo(ip, port, name, timestamp));
          } catch (e) {
            // Silently ignore malformed packets
          }
        }
      }
    });
    return controller.stream;
  }

  // Client: Stop listening
  void stopListening() {
    _listenSocket?.close();
    _listenSocket = null;
  }

  // Cleanup all resources
  void dispose() {
    stopBroadcast();
    stopListening();
  }
}

class ServerInfo {
  final String ip;
  final int port;
  final String name;
  final int timestamp;

  ServerInfo(this.ip, this.port, this.name, this.timestamp);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerInfo && 
      runtimeType == other.runtimeType && 
      ip == other.ip && 
      port == other.port;

  @override
  int get hashCode => ip.hashCode ^ port.hashCode;

  @override
  String toString() => '$name ($ip:$port)';
} 