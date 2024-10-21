import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/conversation_service.dart';
import '../models/user.dart' as model;
import '../utils/styles/colors.dart';
import '../utils/styles/text_styles.dart';
import '../utils/styles/string.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/neon_background.dart';

class ConversationScreen extends StatelessWidget {
  final String channelId;
  final String eventName;
  final List members;
  final String organizerName;
  final String organizerProfilePicture;
  final model.User currentUser;
  final ConversationService _conversationService = ConversationService();
  final Function(String) addConversationToUserList;
  final Function(String) removeConversationFromUserList;
  final bool isInUserConversations;

  ConversationScreen({
    required this.eventName,
    required this.channelId,
    required this.members,
    required this.organizerName,
    required this.organizerProfilePicture,
    required this.currentUser,
    required this.addConversationToUserList,
    required this.removeConversationFromUserList,
    required this.isInUserConversations,
  });

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Scaffold(
        backgroundColor: CustomColor.transparent,
        appBar: AppBar(
          toolbarHeight: 40,
          automaticallyImplyLeading: false,
          backgroundColor: CustomColor.transparent,
          actions: [
            IconButton(
              icon: CustomIcon.close,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildHeader(context),
            Divider(color: CustomColor.customWhite.withOpacity(0.2)),
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(eventName, style: CustomTextStyle.title1),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.more_horiz,
                          color: CustomColor.customPurple),
                      onPressed: () => _showOptions(context),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(organizerProfilePicture),
                      radius: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(organizerName, style: CustomTextStyle.body1),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(isInUserConversations ? Icons.remove : Icons.add),
                title: Text(isInUserConversations
                    ? CustomString.removeFromMyMessages
                    : CustomString.addToMyMessages),
                onTap: () {
                  if (isInUserConversations) {
                    removeConversationFromUserList(channelId);
                  } else {
                    addConversationToUserList(channelId);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text(CustomString.seeMembers),
                onTap: () {
                  Navigator.pop(context);
                  _showInviteesList(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _conversationService.getMessages(channelId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        return ListView(
          reverse: true,
          children: snapshot.data!.docs.map((doc) {
            final isCurrentUser = doc['senderId'] == currentUser.uid;
            return _buildMessageBubble(doc, isCurrentUser);
          }).toList(),
        );
      },
    );
  }

  Widget _buildMessageBubble(DocumentSnapshot doc, bool isCurrentUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(doc['senderProfilePicture']),
              radius: 16,
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? CustomColor.customPurple
                    : CustomColor.customDarkGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(doc['senderUsername'],
                        style: CustomTextStyle.miniButton),
                  Text(doc['message'], style: CustomTextStyle.body1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final TextEditingController _controller = TextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(currentUser.profilePictureUrl),
            radius: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: CustomTextStyle.body1
                    .copyWith(color: CustomColor.customWhite.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: CustomColor.customDarkGrey,
              ),
              style: CustomTextStyle.body1,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: CustomColor.customPurple),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _conversationService.sendMessage(
                  channelId,
                  _controller.text,
                  currentUser.uid,
                  currentUser.username,
                  currentUser.profilePictureUrl,
                );
                _conversationService.createConversation(
                  channelId,
                  eventName,
                  organizerProfilePicture,
                );
                _conversationService.updateConversationLastMessage(
                  channelId,
                  _controller.text,
                  currentUser.username,
                );
                _controller.clear();
              }
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
        return Container(
          color: CustomColor.customBlack,
          child: FutureBuilder<List<model.User>>(
            future: _conversationService.getInviteeDetails(members),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error loading invitees',
                        style: CustomTextStyle.body1));
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
                    title: Text(invitee.username, style: CustomTextStyle.body1),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
