import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/conversation_service.dart';
import '../models/user.dart' as model;

class ConversationScreen extends StatelessWidget {
  final String channelId;
  final String eventName;
  final List members;
  final ConversationService _conversationService = ConversationService();

  ConversationScreen({
    required this.eventName,
    required this.channelId,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        actions: [
          IconButton(
            icon: Icon(Icons.people),
            onPressed: () {
              _showInviteesList(context);
            },
          ),
        ],
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

  void _showInviteesList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<model.User>>(
          future: _conversationService.getInviteeDetails(members),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading invitees'));
            }
            final inviteeDetails = snapshot.data ?? [];
            return ListView.builder(
              itemCount: inviteeDetails.length,
              itemBuilder: (context, index) {
                final invitee = inviteeDetails[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(invitee.profilePictureUrl),
                  ),
                  title: Text(invitee.username),
                );
              },
            );
          },
        );
      },
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
