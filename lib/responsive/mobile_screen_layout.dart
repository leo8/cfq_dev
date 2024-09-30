import 'package:cfq_dev/screens/profile_screen.dart';
import 'package:cfq_dev/screens/thread_screen.dart';
import 'package:flutter/material.dart';

import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  bool isClicked = false;
  bool isOpen = false;
  bool _showButtons = false;
  int currentPageIndex = 0;
  double _yPositionPlusButton = 0.95;
  double _width = 45.0;
  final double _height = 45.0;
  final double _yPositionPlusButtonClose = 0.95;
  final double _yPositionPlusButtonOpen = 0.80;
  final Duration durationAnimation200 = const Duration(milliseconds: 200);
  final Duration durationAnimation500 = const Duration(milliseconds: 500);
  final double paddingTopIcon = 10;
  final double paddinghorizontal = 40;
  final double sizeIcon = 30;

  void _handleTap() {
    if (isClicked) {
      return;
    }
    isClicked = true;

    if (isOpen) {
      // Fermer horizontalement puis descendre
      setState(() {
        _width = 45; // Fermer horizontalement
      });
      Future.delayed(durationAnimation200, () {
        setState(() {
          _yPositionPlusButton = _yPositionPlusButtonClose; // Descendre
          isClicked = false;
        });
      });
      _showButtons = false;
    } else {
      // Monter d'abord, puis ouvrir horizontalement
      setState(() {
        _yPositionPlusButton = _yPositionPlusButtonOpen; // Monter
      });
      Future.delayed(durationAnimation200, () {
        setState(() {
          _width = 200; // Ouvrir horizontalement
        });
      });
      Future.delayed(durationAnimation500, () {
        setState(() {
          _showButtons = true; // Afficher les boutons
          isClicked = false;
        });
      });
    }
    isOpen = !isOpen;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Stack(
        children: [
          // Positioned element for the button with transformation-like behavior
          AnimatedAlign(
            alignment: Alignment(0, _yPositionPlusButton),
            duration: durationAnimation500,
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: _handleTap,
              child: AnimatedContainer(
                width: _width,
                height: _height,
                decoration: BoxDecoration(
                  color: CustomColor.black,
                  borderRadius: BorderRadius.circular(isOpen ? 10.0 : 0.0),
                ),
                // Define how long the animation should take.
                duration: durationAnimation500,
                // Provide an optional curve to make the animation feel smoother.
                curve: Curves.easeInOut,
                child: Transform.rotate(
                  alignment: Alignment.center,
                  angle: isOpen ? 0.75 : 0,
                  child: const Icon(
                    Icons.add,
                    color: CustomColor.white100,
                    size: sizeIcon,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, _yPositionPlusButton),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isOpen)
                  AnimatedOpacity(
                    duration: durationAnimation200,
                    curve: Curves.fastOutSlowIn,
                    opacity: _showButtons ? 1 : 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: CustomColor.white100,
                      ),
                      splashColor: CustomColor.transparent,
                      onPressed: () {
                        print("click edit");
                      },
                    ),
                  ),
                const SizedBox(width: 90),
                if (isOpen)
                  AnimatedOpacity(
                    duration: durationAnimation200,
                    curve: Curves.fastOutSlowIn,
                    opacity: _showButtons ? 1 : 0,
                    child: IconButton(
                      splashColor: CustomColor.transparent,
                      focusColor: CustomColor.transparent,
                      icon: const Icon(
                        Icons.camera_alt,
                        color: CustomColor.white100,
                      ),
                      onPressed: () {
                        print("click photo");
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: CustomColor.transparent,
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (_) => CustomColor.transparent,
        ),
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: paddingTopIcon),
            child: NavigationDestination(
              selectedIcon: Icon(
                CustomIcon.languageOutlined,
                color: CustomColor.white100,
                size: sizeIcon,
              ),
              icon: Icon(
                CustomIcon.languageOutlined,
                color: CustomColor.black,
                size: sizeIcon,
              ),
              label: '',
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(right: paddinghorizontal, top: paddingTopIcon),
            child: NavigationDestination(
              selectedIcon: Icon(
                CustomIcon.locationOnOutlined,
                color: CustomColor.white100,
                size: sizeIcon,
              ),
              icon: Icon(
                CustomIcon.locationOnOutlined,
                color: CustomColor.black,
                size: sizeIcon,
              ),
              label: '',
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: paddinghorizontal, top: paddingTopIcon),
            child: NavigationDestination(
              selectedIcon: Icon(
                CustomIcon.calendarTodayOutlined,
                color: CustomColor.white100,
                size: sizeIcon,
              ),
              icon: Icon(
                CustomIcon.calendarTodayOutlined,
                color: CustomColor.black,
                size: sizeIcon,
              ),
              label: '',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: paddingTopIcon),
            child: NavigationDestination(
              selectedIcon: Icon(
                CustomIcon.personOutlined,
                color: CustomColor.white100,
                size: sizeIcon,
              ),
              icon: Icon(
                CustomIcon.personOutlined,
                color: CustomColor.black,
                size: sizeIcon,
              ),
              label: '',
            ),
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        const ThreadScreen(),
        const Center(child: Text('Map')),
        const Center(child: Text('Friends')),
        const ProfileScreen()
      ][currentPageIndex],
    );
  }
}
