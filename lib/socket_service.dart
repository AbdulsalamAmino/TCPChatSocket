import 'dart:async';
import 'dart:io';
// import 'dart:io' show Platform;

// Connection status enum
enum ConnectionStatus { disconnected, connecting, connected, reconnecting, error }

class SocketService {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  final _messageController = StreamController<String>.broadcast();
  Stream<String> get messages => _messageController.stream;

  void Function(String text, bool isMe)? onMessage;

  // Connection status
  final _statusController = StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get statusStream => _statusController.stream;
  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectionStatus get status => _status;

  String? _lastIp;
  int? _lastPort;
  bool _lastWasServer = false; // if true  this app is a server

  //Update status and send to all listeners
  void _setStatus(ConnectionStatus status) {
    _status = status;
    _statusController.add(status);
  }
  // print time now and platform and message 
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final platform = Platform.operatingSystem;
    print('[$timestamp] [$platform] SocketService: $message');
  }

  // Start server
  Future<void> startServer({required int port}) async {
    _setStatus(ConnectionStatus.connecting);
    try {
      _log('Starting server on port $port...');
      _log('Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
      
      // Try different binding approaches for different platforms
      InternetAddress bindAddress;
      try {
        // it will make the server Listen on all network ( local host and Network and Specific intrface only and Ethernet )
        bindAddress = InternetAddress.anyIPv4;
        _log('Using InternetAddress.anyIPv4 for binding');
      } catch (e) {
        _log('Failed to use anyIPv4, trying localhost: $e');
        //local host
        bindAddress = InternetAddress.loopbackIPv4;
      }
      
      _serverSocket = await ServerSocket.bind(bindAddress, port);//1
      _log('Server started successfully on ${bindAddress.address}:$port');
      _setStatus(ConnectionStatus.connected); //Status update 
      _lastPort = port; //save last port
      _lastWasServer = true; //i am sever

      //start Listen to Incoming client from all client 
      // 1.	استقبال الاتصال من العميل.
	    // 2.	تسجيل بيانات الاتصال.
      // 3.	استقبال الرسائل ومعالجتها.
      // 4.	التعامل مع الأخطاء.
      // 5.	كشف حالة الانفصال.
      _serverSocket!.listen((client) { //2

        //it Records the IP address and port number of the Connected client 
        _log('Client connected from ${client.remoteAddress.address}:${client.remotePort}'); 

        //the client's socket so that the server can send messages to the Client 
        _clientSocket = client;

        client.listen(//3
          (data) {
            //convert the Massage from byte to string
            final  message = String.fromCharCodes(data);
            _log('Received message: $message');
            _messageController.add(message);
            if (onMessage != null) onMessage!(message, false);
          },
          onError: (e) {
            _log('Client socket error: $e');
           // _log('Error type: ${e.runtimeType}');
            if (e is SocketException) {
              _log('Socket error code: ${e.osError?.errorCode}');
              _log('Socket error message: ${e.osError?.message}');
            }
            _setStatus(ConnectionStatus.error);
          },
          // انقطاع الاتصال
          onDone: () {
            _log('Client disconnected');
            _setStatus(ConnectionStatus.disconnected);
          },
        );
      },
      onError: (e) {
        _log('Server socket error: $e');
        _log('Error type: ${e.runtimeType}');
        if (e is SocketException) {
          _log('Socket error code: ${e.osError?.errorCode}');
          _log('Socket error message: ${e.osError?.message}');
        }
        _setStatus(ConnectionStatus.error);
      },
      onDone: () {
        _log('Server socket closed');
        _setStatus(ConnectionStatus.disconnected);
      });
    } catch (e) {
      _log('Failed to start server: $e');
      _log('Error type: ${e.runtimeType}');
      if (e is SocketException) {
        _log('Socket error code: ${e.osError?.errorCode}');
        _log('Socket error message: ${e.osError?.message}');
      }
      _setStatus(ConnectionStatus.error);
      rethrow;
    }
  }

  // Connect as client
  Future<void> connectToServer({required String ip, required int port}) async {
    _setStatus(ConnectionStatus.connecting);
    try {
      _log('Connecting to server at $ip:$port...');
      _log('Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
      
      _clientSocket = await Socket.connect(ip/* ip server */ , port/* port server */);//1

      
      _log('Connected to server successfully');
      _setStatus(ConnectionStatus.connected);
      _lastIp = ip;
      _lastPort = port;
      _lastWasServer = false; //i am client not server
      
      _clientSocket!.listen(//2
        (data) {
          final String message = String.fromCharCodes(data);
          _log('Received message from server: $message');
          _messageController.add(message);
          if (onMessage != null) onMessage!(message, false);
        },
        onError: (e) {
          _log('Client socket error: $e');
          _log('Error type: ${e.runtimeType}');
          if (e is SocketException) {
            _log('Socket error code: ${e.osError?.errorCode}');
            _log('Socket error message: ${e.osError?.message}');
          }
          _setStatus(ConnectionStatus.error);
        },
        onDone: () {
          _log('Disconnected from server');
          _setStatus(ConnectionStatus.disconnected);
        },
      );
    } catch (e) {
      _log('Failed to connect to server: $e');
      _log('Error type: ${e.runtimeType}');
      if (e is SocketException) {
        _log('Socket error code: ${e.osError?.errorCode}');
        _log('Socket error message: ${e.osError?.message}');
      }
      _setStatus(ConnectionStatus.error);
      rethrow;
    }
  }

  // Send message/
  void sendMessage(String message) {
    try {
      _log('Sending message: $message');
      _clientSocket?.write(message); //??????????????
      _messageController.add(message);
      if (onMessage != null) onMessage!(message, true);
    } catch (e) {
      _log('Failed to send message: $e');
      _log('Error type: ${e.runtimeType}');
      if (e is SocketException) {
        _log('Socket error code: ${e.osError?.errorCode}');
        _log('Socket error message: ${e.osError?.message}');
      }
      _setStatus(ConnectionStatus.error);
    }
  }

  // Disconnect
  Future<void> disconnect() async {
    try {
      _log('Disconnecting...');
      await _clientSocket?.close();
      await _serverSocket?.close();
      _log('Disconnected successfully');
    } catch (e) {
      _log('Error during disconnect: $e');
    }
    _clientSocket = null;
    _serverSocket = null;
    _setStatus(ConnectionStatus.disconnected);
  }

  // Reconnect (to last known server/client)
  Future<void> reconnect() async {
    _log('Attempting to reconnect...');
    if (_lastWasServer/*true if i am server*/ && _lastPort != null) {
      await disconnect();
      _setStatus(ConnectionStatus.reconnecting);
      await startServer(port: _lastPort!);
    }else if (_lastIp != null && _lastPort != null) {
      await disconnect();
      _setStatus(ConnectionStatus.reconnecting);
      await connectToServer(ip: _lastIp!, port: _lastPort!);
    }
  }

  void dispose() {
    _log('Disposing SocketService...');
    _serverSocket?.close();
    _clientSocket?.close();
    _messageController.close();
    _statusController.close();
  }
} 