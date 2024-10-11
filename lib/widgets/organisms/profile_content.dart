import 'package:flutter/material.dart';
import 'package:cfq_dev/models/user.dart' as model;
import 'package:cfq_dev/widgets/molecules/avatar_neon_switch.dart';
import 'package:cfq_dev/utils/styles/string.dart';

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
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.user.location.isNotEmpty
                        ? widget.user.location[0].toUpperCase() +
                            widget.user.location.substring(1)
                        : CustomString.aucuneLocalisation,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.isCurrentUser)
                ElevatedButton(
                  onPressed: widget.onFriendsTap,
                  child: const Text(CustomString.mesAmis),
                )
              else if (!widget.isFriend)
                ElevatedButton(
                  onPressed: widget.onAddFriendTap,
                  child: const Text(CustomString.ajouter),
                )
              else
                ElevatedButton(
                  onPressed: widget.onRemoveFriendTap,
                  child: const Text(CustomString.retirer),
                ),
              const SizedBox(height: 24),
              if (!widget.isCurrentUser && !widget.isFriend)
                const Icon(
                  Icons.lock,
                  size: 100,
                  color: Colors.white,
                )
              else if (!widget.isCurrentUser && widget.isFriend)
                Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Text(
                            CustomString.sesPosts,
                            style: TextStyle(
                              color: _selectedIndex == 0
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: _selectedIndex == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'ÇA VA TURN',
                            style: TextStyle(
                              color: _selectedIndex == 1
                                  ? Colors.white
                                  : Colors.grey,
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
                        children: const [
                          Center(
                              child: Text(CustomString.sesPosts,
                                  style: TextStyle(color: Colors.white))),
                          Center(
                              child: Text(CustomString.sonCalendrier,
                                  style: TextStyle(color: Colors.white))),
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
                      indicatorColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Text(
                            CustomString.sesPosts,
                            style: TextStyle(
                              color: _selectedIndex == 0
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: _selectedIndex == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            CustomString.sonCalendrier,
                            style: TextStyle(
                              color: _selectedIndex == 1
                                  ? Colors.white
                                  : Colors.grey,
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
                        children: const [
                          Center(
                              child: Text(CustomString.mesPosts,
                                  style: TextStyle(color: Colors.white))),
                          Center(
                              child: Text(CustomString.monCalendrier,
                                  style: TextStyle(color: Colors.white))),
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
              icon: const Icon(Icons.settings, color: Colors.white, size: 30),
              onPressed: widget.onParametersTap,
            ),
          ),
      ],
    );
  }
}
