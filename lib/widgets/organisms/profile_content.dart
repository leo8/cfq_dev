import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/widgets/molecules/avatar_neon_switch.dart';
import 'package:cfq_dev/utils/styles/string.dart';
import '../../utils/styles/icons.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/text_styles.dart';

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              if (widget.isCurrentUser)
                AvatarNeonSwitch(
                  isActive: widget.user.isActive,
                  onChanged: widget.onActiveChanged,
                  imageUrl: widget.user.profilePictureUrl,
                  avatarRadius: 70,
                  switchSize: 1.4,
                )
              else
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(widget.user.profilePictureUrl),
                ),
              const SizedBox(height: 40),
              Text(
                widget.user.username,
                style: CustomTextStyle.title1,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CustomIcon.userLocation,
                    color: CustomColor.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.user.location.isNotEmpty
                        ? widget.user.location[0].toUpperCase() +
                            widget.user.location.substring(1)
                        : CustomString.noLocation,
                    style: CustomTextStyle.title3,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.isCurrentUser)
                ElevatedButton(
                  onPressed: widget.onFriendsTap,
                  child: const Text(CustomString.myFriends),
                )
              else if (!widget.isFriend)
                ElevatedButton(
                  onPressed: widget.onAddFriendTap,
                  child: const Text(CustomString.addFriend),
                )
              else
                ElevatedButton(
                  onPressed: widget.onRemoveFriendTap,
                  child: const Text(CustomString.removeFriend),
                ),
              const SizedBox(height: 24),
              if (!widget.isCurrentUser && !widget.isFriend)
                const Icon(CustomIcon.privateProfile,
                    size: 100, color: CustomColor.white)
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
          ),
        ),
        if (widget.isCurrentUser)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(CustomIcon.settings,
                  color: CustomColor.white, size: 30),
              onPressed: widget.onParametersTap,
            ),
          ),
      ],
    );
  }
}
