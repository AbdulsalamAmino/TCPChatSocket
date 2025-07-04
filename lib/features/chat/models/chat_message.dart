class ChatMessage {
  final String text;
  final String sender;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.text,
    required this.sender,//server or client
    required this.timestamp, //time of the message
    required this.isMe, //true if the message is from me
  });
} 