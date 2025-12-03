import 'package:flutter/material.dart';
import 'package:ui_specification/models/message.dart';

class CommunicationProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  CommunicationProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      _messages = [
        Message(
          id: '1',
          senderId: '2',
          receiverId: '1', // Current user
          content:
              'Hi, can you send me the quotation for the wedding photography?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          senderName: 'Jane Smith',
          isRead: false,
        ),
        Message(
          id: '2',
          senderId: '1',
          receiverId: '2',
          content: 'Sure, I will send it shortly.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          senderName: 'Me',
          isRead: true,
        ),
        Message(
          id: '3',
          senderId: '3',
          receiverId: '1',
          content: 'Meeting confirmed for tomorrow at 10 AM.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          senderName: 'Mike Johnson',
          isRead: true,
        ),
      ];

      _isLoading = false;
      notifyListeners();
    });
  }

  List<Message> getMessagesForContact(String contactId) {
    return _messages
        .where((m) => m.senderId == contactId || m.receiverId == contactId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void sendMessage(String content, String receiverId) {
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: '1', // Mock current user ID
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      senderName: 'Me',
      isRead: true,
    );

    _messages.add(newMessage);
    notifyListeners();
  }
}
