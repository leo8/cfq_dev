import 'package:cfq_dev/utils/global_variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/utils/colors.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

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
        children: homeScreenItems,
      ),
      bottomNavigationBar: CupertinoTabBar(
        iconSize: 32,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Icon(
                Icons.language_outlined,
                color: _page == 0 ? CustomColor.primaryColor : CustomColor.secondaryColor,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Icon(
                Icons.location_on_outlined,
                color: _page == 1 ? CustomColor.primaryColor : CustomColor.secondaryColor,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Icon(
                Icons.add_circle_outline_rounded,
                color: _page == 2 ? CustomColor.purpleAccent : CustomColor.secondaryColor,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Icon(
                Icons.calendar_today_outlined,
                color: _page == 3 ? CustomColor.primaryColor : CustomColor.secondaryColor,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Icon(
                Icons.person_outlined,
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
