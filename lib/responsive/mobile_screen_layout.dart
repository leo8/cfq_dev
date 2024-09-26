import 'package:cfq_dev/utils/home_screen_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/gen/colors.dart';
import '../utils/gen/icons.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children: CustomHomeScreenItems.homeScreenItems,
      ),
      bottomNavigationBar: CupertinoTabBar(
        iconSize: 32,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Icon(
                CustomIcon.languageOutlined,
                color: _page == 0 ? CustomColor.primaryColor : CustomColor.secondaryColor,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Icon(
                CustomIcon.locationOnOutlined,
                color: _page == 1 ? CustomColor.primaryColor : CustomColor.secondaryColor,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Icon(
                CustomIcon.addCircleOutlineRounded,
                color: _page == 2 ? CustomColor.purpleAccent : CustomColor.secondaryColor,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Icon(
                CustomIcon.calendarTodayOutlined,
                color: _page == 3 ? CustomColor.primaryColor : CustomColor.secondaryColor,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Icon(
                CustomIcon.personOutlined,
                color: _page == 4 ? CustomColor.primaryColor : CustomColor.secondaryColor,
              ),
            ),
          ),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}
