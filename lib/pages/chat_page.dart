import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:thewall/auth/chat/chat_service.dart';
import 'package:thewall/model/message.dart';

class ChatPage extends StatefulWidget {
  final String recieverUserId;
  final String recieverUserEmail;

  const ChatPage({
    Key? key,
    required this.recieverUserId,
    required this.recieverUserEmail,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recieverUserEmail),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
        widget.recieverUserId,
        _chatService.currentUserId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data!.docs.toList();

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index].data() as Map<String, dynamic>;
            final message = Message.fromMap(messageData);
            final isCurrentUserMessage =
                message.senderId == _chatService.currentUserId;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: isCurrentUserMessage
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrentUserMessage
                        ? Colors.blue[200]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        DateFormat('HH:mm').format(message.timestamp.toDate()),
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();

    if (message.isNotEmpty) {
      _chatService.sendMessage(widget.recieverUserId, message);
      _messageController.clear();
    }
  }
}
