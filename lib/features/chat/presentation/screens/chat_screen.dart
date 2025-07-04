import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../../services/socket_service.dart';
import '../../services/udp_discovery_service.dart';
import '../../utils/input_validator.dart';
import 'dart:async';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketService _socketService = SocketService();
  final UdpDiscoveryService _udpDiscovery = UdpDiscoveryService();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '5000');
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _serverNameController = TextEditingController(text: 'My Server');
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isServer = false;
  bool _connected = false;
  String _myName = 'Me';
  String _peerName = 'Peer';
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  late Stream<ConnectionStatus> _statusStream;
  Map<ServerInfo, DateTime> _serverLastSeen = {};
  StreamSubscription<ServerInfo>? _discoverySub;
  Timer? _cleanupTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 3;

  @override
  void initState() {
    super.initState();
    _statusStream = _socketService.statusStream;
    _statusStream.listen(_handleStatusChange);
    if (!_isServer) _startDiscovery();
  }

  void _handleStatusChange(ConnectionStatus status) {
    setState(() {
      _connectionStatus = status;
      _connected = status == ConnectionStatus.connected;
    });

    // Handle automatic reconnection
    if (status == ConnectionStatus.disconnected && _connected) {
      _handleDisconnect();
    } else if (status == ConnectionStatus.connected) {
      _reconnectAttempts = 0;
      _showStatusMessage('Connected successfully!', Colors.green);
    } else if (status == ConnectionStatus.error) {
      _showStatusMessage('Connection failed. Please check your settings.', Colors.red);
    } else if (status == ConnectionStatus.reconnecting) {
      _showStatusMessage('Reconnecting...', Colors.orange);
    }
  }

  void _handleDisconnect() {
    if (_reconnectAttempts < maxReconnectAttempts) {
      setState(() => _connectionStatus = ConnectionStatus.reconnecting);
      _reconnectAttempts++;
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          _socketService.reconnect();
        }
      });
    } else {
      setState(() => _connectionStatus = ConnectionStatus.error);
      _reconnectAttempts = 0;
      _showStatusMessage('Connection lost. Please reconnect manually.', Colors.red);
    }
  }

  void _showStatusMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startDiscovery() async {
    _discoverySub?.cancel();
    _cleanupTimer?.cancel();
    
    final stream = await _udpDiscovery.listenForServers();
    _discoverySub = stream.listen((server) {
      setState(() {
        _serverLastSeen[server] = DateTime.now();
      });
    });

    // Cleanup stale servers every 2 seconds
    _cleanupTimer = Timer.periodic(Duration(seconds: 2), (_) {
      final now = DateTime.now();
      setState(() {
        _serverLastSeen.removeWhere((server, lastSeen) => 
          now.difference(lastSeen) > Duration(seconds: 10));
      });
    });
  }

  void _stopDiscovery() {
    _discoverySub?.cancel();
    _cleanupTimer?.cancel();
    _udpDiscovery.stopListening();
    _serverLastSeen.clear();
  }

  @override
  void dispose() {
    _udpDiscovery.dispose();
    _stopDiscovery();
    _socketService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String?> _getLocalIp() async {
    for (var interface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback && addr.address.startsWith('192.168.')) {
          return addr.address;
        }
      }
    }
    return null;
  }

  void _connect() async {
    // Validate inputs
    final port = InputValidator.validatePort(_portController.text);
    if (port == null) {
      _showStatusMessage(InputValidator.getErrorMessage('port', _portController.text), Colors.red);
      return;
    }

    if (_isServer) {
      final serverName = InputValidator.validateServerName(_serverNameController.text);
      if (serverName == null) {
        _showStatusMessage(InputValidator.getErrorMessage('server name', _serverNameController.text), Colors.red);
        return;
      }

      try {
        await _socketService.startServer(port: port);
        setState(() { _myName = 'Server'; _peerName = 'Client'; });
        
        final localIp = await _getLocalIp();
        if (localIp != null) {
          _udpDiscovery.startBroadcast(localIp, port, serverName);
        }
        _stopDiscovery();
      } catch (e) {
        _showStatusMessage('Failed to start server: ${e.toString()}', Colors.red);
      }
    } else {
      final ip = InputValidator.validateIpAddress(_ipController.text);
      if (ip == null) {
        _showStatusMessage(InputValidator.getErrorMessage('ip', _ipController.text), Colors.red);
        return;
      }

      try {
        await _socketService.connectToServer(ip: ip, port: port);
        setState(() { _myName = 'Client'; _peerName = 'Server'; });
      } catch (e) {
        _showStatusMessage('Failed to connect: ${e.toString()}', Colors.red);
      }
    }

    _socketService.onMessage = (text, isMe) {
      final sanitizedText = InputValidator.validateMessage(text);
      if (sanitizedText != null) {
        setState(() {
          _messages.add(ChatMessage(
            text: sanitizedText,
            sender: isMe ? _myName : _peerName,
            timestamp: DateTime.now(),
            isMe: isMe,
          ));
        });
        _scrollToBottom();
      }
    };
  }

  void _disconnect() async {
    await _socketService.disconnect();
    _udpDiscovery.stopBroadcast();
    if (!_isServer) _startDiscovery();
  }

  void _reconnect() async {
    _reconnectAttempts = 0;
    await _socketService.reconnect();
  }

  void _sendMessage() {
    final text = _messageController.text;
    final sanitizedText = InputValidator.validateMessage(text);
    
    if (sanitizedText != null) {
      _socketService.sendMessage(sanitizedText);
      _messageController.clear();
      _scrollToBottom();
    } else {
      _showStatusMessage(InputValidator.getErrorMessage('message', text), Colors.red);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildStatusBanner() {
    Color color;
    String text;
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        color = Colors.green;
        text = 'Connected';
        break;
      case ConnectionStatus.connecting:
        color = Colors.orange;
        text = 'Connecting...';
        break;
      case ConnectionStatus.reconnecting:
        color = Colors.blue;
        text = 'Reconnecting... (${_reconnectAttempts}/$maxReconnectAttempts)';
        break;
      case ConnectionStatus.error:
        color = Colors.red;
        text = 'Connection Error';
        break;
      default:
        color = Colors.grey;
        text = 'Disconnected';
    }
    return Container(
      width: double.infinity,
      color: color,
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDiscoveryList() {
    if (_isServer || _serverLastSeen.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Discovered Servers:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ..._serverLastSeen.keys.map((server) => Card(
          margin: EdgeInsets.symmetric(vertical: 2),
          child: ListTile(
            title: Text(server.name),
            subtitle: Text('${server.ip}:${server.port}'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                _ipController.text = server.ip;
                _portController.text = server.port.toString();
              });
              _showStatusMessage('Selected ${server.name}', Colors.blue);
            },
          ),
        )),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildServerNameField() {
    if (!_isServer) return SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: _serverNameController,
        decoration: InputDecoration(
          labelText: 'Server Name',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          helperText: 'This name will be shown to clients',
        ),
        style: TextStyle(fontSize: 16),
        enabled: !_connected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TCP Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<bool>(
                value: _isServer,
                icon: Icon(Icons.swap_horiz, color: Colors.white),
                dropdownColor: Colors.white,
                style: TextStyle(color: Colors.black, fontSize: 16),
                items: [
                  DropdownMenuItem(child: Text('Server'), value: true),
                  DropdownMenuItem(child: Text('Client'), value: false),
                ],
                onChanged: (val) {
                  setState(() { _isServer = val!; });
                  if (_isServer) {
                    _stopDiscovery();
                  } else {
                    _startDiscovery();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildStatusBanner(),
            _buildDiscoveryList(),
            _buildServerNameField(),
            if (!_isServer)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: 'Server IP',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: TextStyle(fontSize: 16),
                  enabled: !_connected,
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _portController,
                    decoration: InputDecoration(
                      labelText: 'Port',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 16),
                    enabled: !_connected,
                  ),
                ),
                SizedBox(width: 16),
                if (!_connected)
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _connected ? null : _connect,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Text('Connect'),
                    ),
                  ),
                if (_connected)
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _disconnect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Text('Disconnect'),
                    ),
                  ),
                if (_connectionStatus == ConnectionStatus.disconnected || _connectionStatus == ConnectionStatus.error)
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _reconnect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Text('Reconnect'),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, idx) => MessageBubble(message: _messages[idx]),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: _connected,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _connected ? _sendMessage : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 