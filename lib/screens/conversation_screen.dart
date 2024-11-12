import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/conversation_service.dart';
import '../models/user.dart' as model;
import '../utils/styles/colors.dart';
import '../utils/styles/text_styles.dart';
import '../utils/styles/string.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/neon_background.dart';
import '../utils/logger.dart';
import '../utils/loading_overlay.dart';

class ConversationScreen extends StatefulWidget {
  final String channelId;
  final String eventName;
  final String organizerId;
  final List<String> members;
  final String organizerName;
  final String organizerProfilePicture;
  final model.User currentUser;
  final Function(String) addConversationToUserList;
  final Function(String) removeConversationFromUserList;
  final bool initialIsInUserConversations;
  final String eventPicture;
  final Future<void> Function(String) resetUnreadMessages;

  ConversationScreen({
    required this.eventName,
    required this.organizerId,
    required this.channelId,
    required this.members,
    required this.organizerName,
    required this.organizerProfilePicture,
    required this.eventPicture,
    required this.currentUser,
    required this.addConversationToUserList,
    required this.removeConversationFromUserList,
    required this.initialIsInUserConversations,
    required this.resetUnreadMessages,
  });

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late bool _isInUserConversations;
  final ConversationService _conversationService = ConversationService();
  bool _isDisposed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isInUserConversations = widget.initialIsInUserConversations;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Override the default back button behavior
    ModalRoute.of(context)?.addScopedWillPopCallback(_onWillPop);
  }

  Future<bool> _onWillPop() async {
    await _resetUnreadAndPop();
    return true;
  }

  Future<void> _resetUnreadAndPop() async {
    if (!_isDisposed) {
      _setLoadingState(true);
      await widget.resetUnreadMessages(widget.channelId);
      if (!_isDisposed) {
        Navigator.of(context).pop();
      }
      _setLoadingState(false);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: Scaffold(
          backgroundColor: CustomColor.transparent,
          appBar: AppBar(
            toolbarHeight: 40,
            automaticallyImplyLeading: false,
            backgroundColor: CustomColor.customBlack,
            surfaceTintColor: CustomColor.customBlack,
            actions: [
              IconButton(
                icon: CustomIcon.close,
                onPressed: _resetUnreadAndPop,
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
                    Text(
                      widget.eventName,
                      style: CustomTextStyle.title1,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.more_horiz,
                          color: CustomColor.customPurple),
                      onPressed: () => _showOptions(context),
                      constraints:
                          const BoxConstraints.tightFor(width: 40, height: 40),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(widget.organizerProfilePicture),
                      radius: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(widget.organizerName, style: CustomTextStyle.body1),
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
          color: CustomColor.customBlack,
          child: Wrap(
            children: <Widget>[
              const Divider(height: 20, color: CustomColor.transparent),
              const Divider(),
              ListTile(
                minTileHeight: 45,
                leading:
                    Icon(_isInUserConversations ? Icons.remove : Icons.add),
                title: Text(_isInUserConversations
                    ? CustomString.removeFromMyMessages
                    : CustomString.addToMyMessages),
                onTap: () {
                  setState(() {
                    if (_isInUserConversations) {
                      widget.removeConversationFromUserList(widget.channelId);
                      _isInUserConversations = false;
                    } else {
                      widget.addConversationToUserList(widget.channelId);
                      _isInUserConversations = true;
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                minTileHeight: 45,
                leading: const Icon(Icons.people),
                title: const Text(CustomString.seeMembers),
                onTap: () {
                  Navigator.pop(context);
                  _showInviteesList(context);
                },
              ),
              const Divider(),
              const SizedBox(
                height: 120,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _conversationService.getMessages(widget.channelId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        return ListView(
          reverse: true,
          children: snapshot.data!.docs.map((doc) {
            final isCurrentUser = doc['senderId'] == widget.currentUser.uid;
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
            backgroundImage: NetworkImage(widget.currentUser.profilePictureUrl),
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
                _sendMessage(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) async {
    try {
      await _conversationService.sendMessage(
        widget.channelId,
        message,
        widget.currentUser.uid,
        widget.currentUser.username,
        widget.currentUser.profilePictureUrl,
      );
    } catch (e) {
      AppLogger.debug('Error sending message: $e');
      // You might want to show an error message to the user here
    }
  }

  void _showInviteesList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: CustomColor.customBlack,
          child: FutureBuilder<List<model.User>>(
            future: _conversationService.getInviteeDetails(widget.members),
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

  void _setLoadingState(bool loading) {
    if (!_isDisposed) {
      setState(() {
        _isLoading = loading;
      });
    }
  }
}
