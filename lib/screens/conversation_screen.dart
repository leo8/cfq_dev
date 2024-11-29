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
import '../utils/date_time_utils.dart';

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
  final FocusNode _messageFocusNode = FocusNode();

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
    _messageFocusNode.dispose();
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
              const SizedBox(
                height: 20,
              ),
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
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.channelId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final doc = messages[index];
            final data = doc.data() as Map<String, dynamic>;
            final currentMessageTime =
                (data['timestamp'] as Timestamp).toDate();

            // Get previous message timestamp
            DateTime? previousMessageTime;
            if (index < messages.length - 1) {
              final previousData =
                  messages[index + 1].data() as Map<String, dynamic>;
              previousMessageTime =
                  (previousData['timestamp'] as Timestamp).toDate();
            }

            // Check if we should show timestamp
            final showTimestamp = DateTimeUtils.shouldShowTimestamp(
                previousMessageTime, currentMessageTime);

            return Column(
              children: [
                if (showTimestamp)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: CustomColor.customDarkGrey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DateTimeUtils.formatMessageDateTime(
                              currentMessageTime),
                          style: CustomTextStyle.body2.copyWith(
                            color: CustomColor.customWhite.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                _buildMessageItem(doc, data),
                const SizedBox(
                  height: 6,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc, Map<String, dynamic> data) {
    final isCurrentUser = data['senderId'] == widget.currentUser.uid;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isCurrentUser) ...[
              CircleAvatar(
                backgroundImage: NetworkImage(data['senderProfilePicture']),
                radius: 16,
              ),
              SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.70,
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      Text(
                        data['senderUsername'],
                        style: CustomTextStyle.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (!isCurrentUser)
                      const SizedBox(
                        height: 8,
                      ),
                    Text(
                      data['message'],
                      style: CustomTextStyle.body1,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final TextEditingController _controller = TextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.currentUser.profilePictureUrl),
            radius: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 150,
              ),
              child: TextField(
                focusNode: _messageFocusNode,
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: CustomTextStyle.body1.copyWith(
                      color: CustomColor.customWhite.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: CustomColor.customDarkGrey,
                  isCollapsed: true,
                ),
                style: CustomTextStyle.body1,
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: CustomColor.customPurple),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _sendMessage(_controller.text);
                _controller.clear();
                _messageFocusNode.unfocus();
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
