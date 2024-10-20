import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/conversation_service.dart';

class ConversationScreen extends StatelessWidget {
  final String channelId;
  final String eventName;
  final ConversationService _conversationService = ConversationService();

  ConversationScreen({required this.eventName, required this.channelId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _conversationService.getMessages(channelId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['message']),
                      subtitle: Text(doc['senderId']),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          MessageInput(
            onSend: (message) {
              _conversationService.sendMessage(
                  channelId, message, 'currentUserId');
            },
          ),
        ],
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final Function(String) onSend;

  MessageInput({required this.onSend});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Type a message'),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSend(_controller.text);
              _controller.clear();
            }
          },
        ),
      ],
    );
  }
}
