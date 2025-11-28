import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui_specification/core/widgets/custom_card.dart';
import 'package:ui_specification/features/communication/providers/communication_provider.dart';
import 'package:ui_specification/models/message.dart';
import 'package:intl/intl.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunicationProvider>(
      builder: (context, provider, child) {
        // Group messages by contact (simplified logic for demo)
        final Map<String, Message> lastMessages = {};
        for (var msg in provider.messages) {
          final contactId = msg.senderId == '1' ? msg.receiverId : msg.senderId;
          if (!lastMessages.containsKey(contactId) ||
              msg.timestamp.isAfter(lastMessages[contactId]!.timestamp)) {
            lastMessages[contactId] = msg;
          }
        }

        final sortedConversations = lastMessages.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Messages'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedConversations.length,
                  itemBuilder: (context, index) {
                    final msg = sortedConversations[index];
                    final contactName = msg.senderId == '1'
                        ? 'Contact ${msg.receiverId}'
                        : msg.senderName;
                    final contactId = msg.senderId == '1'
                        ? msg.receiverId
                        : msg.senderId;

                    return CustomCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            contactName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                        title: Text(
                          contactName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          msg.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: msg.isRead ? Colors.grey : Colors.black,
                            fontWeight: msg.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          DateFormat('h:mm a').format(msg.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              contactId: contactId,
                              contactName: contactName,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String contactId;
  final String contactName;

  const ChatScreen({
    super.key,
    required this.contactId,
    required this.contactName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunicationProvider>(
      builder: (context, provider, child) {
        final messages = provider.getMessagesForContact(widget.contactId);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(widget.contactName),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == '1';

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? Radius.zero : null,
                            bottomLeft: !isMe ? Radius.zero : null,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('h:mm a').format(msg.timestamp),
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.note_add_outlined),
                            onPressed: () {
                              // Template Selector
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Select Template',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ListTile(
                                        title: const Text('Meeting Reminder'),
                                        onTap: () {
                                          _messageController.text =
                                              "Hi, just a reminder about our meeting tomorrow.";
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Payment Follow-up'),
                                        onTap: () {
                                          _messageController.text =
                                              "Hi, this is a gentle reminder regarding the pending payment.";
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          if (_messageController.text.trim().isNotEmpty) {
                            provider.sendMessage(
                              _messageController.text.trim(),
                              widget.contactId,
                            );
                            _messageController.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
