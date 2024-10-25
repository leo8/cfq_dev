import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/widgets/molecules/avatar_neon_switch.dart';
import 'package:cfq_dev/utils/styles/string.dart';
import '../../utils/styles/icons.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/text_styles.dart';
import '../atoms/buttons/custom_button.dart';
import '../atoms/avatars/custom_avatar.dart';

class ProfileContent extends StatefulWidget {
  final model.User user;
  final bool isFriend;
  final bool isCurrentUser;
  final Function(bool)? onActiveChanged;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onAddFriendTap;
  final VoidCallback? onRemoveFriendTap;
  final VoidCallback? onFriendsTap;
  final VoidCallback? onParametersTap;
  final int commonFriendsCount;
  final int commonTeamsCount;

  const ProfileContent({
    super.key,
    required this.user,
    required this.isFriend,
    required this.isCurrentUser,
    this.onActiveChanged,
    this.onLogoutTap,
    this.onAddFriendTap,
    this.onRemoveFriendTap,
    this.onFriendsTap,
    this.onParametersTap,
    required this.commonFriendsCount,
    required this.commonTeamsCount,
  });

  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildCommonInfoRow() {
    List<TextSpan> textSpans = [];

    if (widget.commonFriendsCount > 0) {
      textSpans.add(TextSpan(
        text: '${widget.commonFriendsCount} ',
        style: CustomTextStyle.body2.copyWith(fontWeight: FontWeight.bold),
      ));
      textSpans.add(TextSpan(
        text: widget.commonFriendsCount == 1
            ? CustomString.commonFriend
            : CustomString.commonFriends,
        style: CustomTextStyle.body2,
      ));
    }

    if (widget.commonFriendsCount > 0 && widget.commonTeamsCount > 0) {
      textSpans.add(TextSpan(
        text: ' ${CustomString.and} ',
        style: CustomTextStyle.body2,
      ));
    }

    if (widget.commonTeamsCount > 0) {
      textSpans.add(TextSpan(
        text: '${widget.commonTeamsCount} ',
        style: CustomTextStyle.body2.copyWith(fontWeight: FontWeight.bold),
      ));
      textSpans.add(TextSpan(
        text: widget.commonTeamsCount == 1
            ? CustomString.commonTeam
            : CustomString.commonTeams,
        style: CustomTextStyle.body2,
      ));
    }

    if (widget.commonFriendsCount > 0 || widget.commonTeamsCount > 0) {
      textSpans.add(TextSpan(
        text: ' ${CustomString.inCommon}',
        style: CustomTextStyle.body2,
      ));
    }

    return RichText(
      text: TextSpan(children: textSpans),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 100,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left 1/3 container with AvatarNeonSwitch or CircleAvatar
            Container(
                width: MediaQuery.of(context).size.width / 3,
                padding: const EdgeInsets.only(
                    left: 16, top: 16, bottom: 16, right: 1),
                child: widget.isCurrentUser
                    ? AvatarNeonSwitch(
                        isActive: widget.user.isActive,
                        onChanged: widget.onActiveChanged,
                        imageUrl: widget.user.profilePictureUrl,
                        avatarRadius: 70,
                        switchSize: 1.2,
                      )
                    : widget.isFriend
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: widget.user.isActive
                                  ? [
                                      const BoxShadow(
                                        color: CustomColor.turnColor,
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: CustomAvatar(
                              radius: 70,
                              imageUrl: widget.user.profilePictureUrl,
                              borderColor: CustomColor.turnColor,
                              borderWidth: 1,
                            ),
                          )
                        : CircleAvatar(
                            radius: 70,
                            backgroundImage:
                                NetworkImage(widget.user.profilePictureUrl),
                          )),
            // Right 2/3 column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 1, top: 16, bottom: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.isCurrentUser
                        ? const SizedBox(
                            height: 50,
                          )
                        : const SizedBox(
                            height: 25,
                          ),
                    // Username, separator, location icon, and location
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.user.username,
                              style: CustomTextStyle.bigBody1),
                          const SizedBox(width: 8),
                          if (widget.isCurrentUser | widget.isFriend)
                            Text('|', style: CustomTextStyle.bigBody1),
                          const SizedBox(width: 8),
                          if (widget.isCurrentUser | widget.isFriend)
                            CustomIcon.userLocation,
                          const SizedBox(width: 4),
                          if (widget.isCurrentUser | widget.isFriend)
                            Text(
                                widget.user.location.isNotEmpty
                                    ? widget.user.location[0].toUpperCase() +
                                        widget.user.location.substring(1)
                                    : CustomString.noLocation,
                                style: CustomTextStyle.bigBody1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Buttons
                    if (widget.isCurrentUser)
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                                label: CustomString.myFriends,
                                textStyle: CustomTextStyle.subButton.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                onTap: widget.onFriendsTap!,
                                color: CustomColor.customBlack,
                                borderWidth: 0.5,
                                borderRadius: 5,
                                width: 110,
                                height: 50),
                            const SizedBox(width: 20),
                            CustomButton(
                                label: CustomString.parameters,
                                textStyle: CustomTextStyle.subButton.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                onTap: widget.onParametersTap!,
                                color: CustomColor.customBlack,
                                borderWidth: 0.5,
                                borderRadius: 5,
                                width: 110,
                                height: 50),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          Center(
                            child: CustomButton(
                                label: widget.isFriend
                                    ? CustomString.removeFriend
                                    : CustomString.addFriend,
                                onTap: widget.isFriend
                                    ? widget.onRemoveFriendTap!
                                    : widget.onAddFriendTap!,
                                color: widget.isFriend
                                    ? CustomColor.customBlack
                                    : CustomColor.customPurple,
                                textStyle: CustomTextStyle.subButton
                                    .copyWith(color: CustomColor.customWhite),
                                borderRadius: 5,
                                borderWidth: 0.5,
                                width: 220,
                                height: 50),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Center(
                            child: _buildCommonInfoRow(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!widget.isCurrentUser && !widget.isFriend)
          Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: CustomColor.transparent,
                indicator: const BoxDecoration(),
                tabs: [
                  Tab(
                    child: Text(
                      CustomString.otherUserPosts,
                      style: TextStyle(
                        color: _selectedIndex == 0
                            ? CustomColor.grey
                            : CustomColor.grey,
                        fontWeight: _selectedIndex == 0
                            ? FontWeight.normal
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      CustomString.otherUserCalendar,
                      style: TextStyle(
                        color: _selectedIndex == 1
                            ? CustomColor.grey
                            : CustomColor.grey,
                        fontWeight: _selectedIndex == 1
                            ? FontWeight.normal
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 150),
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CustomColor.grey,
                      width: 3,
                    ),
                    color: CustomColor.transparent,
                  ),
                  child: const Icon(
                    CustomIcon.privateProfile,
                    size: 120,
                    color: CustomColor.grey,
                  ),
                ),
              ),
            ],
          )
        else if (!widget.isCurrentUser && widget.isFriend)
          Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: CustomColor.transparent,
                tabs: [
                  Tab(
                    child: Text(
                      CustomString.otherUserPosts,
                      style: TextStyle(
                        color: _selectedIndex == 0
                            ? CustomColor.white
                            : CustomColor.grey,
                        fontWeight: _selectedIndex == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      CustomString.otherUserCalendar,
                      style: TextStyle(
                        color: _selectedIndex == 1
                            ? CustomColor.white
                            : CustomColor.grey,
                        fontWeight: _selectedIndex == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Center(
                        child: Text(CustomString.otherUserPosts,
                            style: CustomTextStyle.title3)),
                    Center(
                        child: Text(CustomString.otherUserCalendar,
                            style: CustomTextStyle.title3)),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: CustomColor.transparent,
                tabs: [
                  Tab(
                    child: Text(
                      CustomString.myPosts,
                      style: TextStyle(
                        color: _selectedIndex == 0
                            ? CustomColor.white
                            : CustomColor.grey,
                        fontWeight: _selectedIndex == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      CustomString.myCalendar,
                      style: TextStyle(
                        color: _selectedIndex == 1
                            ? CustomColor.white
                            : CustomColor.grey,
                        fontWeight: _selectedIndex == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Center(
                        child: Text(CustomString.myPosts,
                            style: CustomTextStyle.title3)),
                    Center(
                        child: Text(CustomString.myCalendar,
                            style: CustomTextStyle.title3)),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
