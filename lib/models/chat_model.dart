class ChatMessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isFromCustomer;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isFromCustomer,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String) 
          : DateTime.now(),
      isFromCustomer: json['is_from_customer'] as bool? ?? true,
    );
  }
}
