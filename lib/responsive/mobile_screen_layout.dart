import 'package:cfq_dev/widgets/atoms/buttons/cfq_button.dart';
import 'package:cfq_dev/widgets/atoms/buttons/turn_button.dart';
import 'package:flutter/material.dart';
import 'package:cfq_dev/screens/map_screen.dart';
import 'package:cfq_dev/screens/teams_screen.dart';
import 'package:cfq_dev/screens/thread_screen.dart';
import 'package:cfq_dev/screens/profile_screen.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/string.dart';
import 'dart:async';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  // State variables for managing the state of the plus button and navigation
  bool isClicked = false; // Prevent multiple rapid clicks
  bool isOpen = false; // Track if the floating button is expanded
  bool _showButtons = false; // Show additional buttons when expanded
  int currentPageIndex = 0; // Track the current page selected
  double _yPositionPlusButton = 0.95; // Y position of the plus button
  double _width = 45.0; // Initial width of the plus button
  final double _height = 45.0; // Height of the plus button
  final double _yPositionPlusButtonClose = 0.95; // Y position when closed
  final double _yPositionPlusButtonOpen = 0.80; // Y position when opened
  final Duration durationAnimation200 =
      const Duration(milliseconds: 200); // Short animation duration
  final Duration durationAnimation300 = const Duration(milliseconds: 300);
  final Duration durationAnimation500 =
      const Duration(milliseconds: 500); // Longer animation duration
  final double paddingTopIcon =
      10; // Top padding for icons in the bottom navigation bar
  final double paddinghorizontal =
      40; // Horizontal padding for icons in the navigation bar
  final double sizeIcon = 24; // Size of icons

  // Add this new variable
  Timer? _autoCloseTimer;

  // Handle the tap on the plus button
  void _handleTap() {
    if (isClicked) {
      return;
    }
    isClicked = true;

    if (isOpen) {
      _closeButton();
    } else {
      _openButton();
    }
  }

  // New method to open the button
  void _openButton() {
    setState(() {
      _yPositionPlusButton = _yPositionPlusButtonOpen;
      isOpen = true;
    });
    Future.delayed(durationAnimation200, () {
      setState(() {
        _width = 170;
      });
    });
    Future.delayed(durationAnimation300, () {
      setState(() {
        _showButtons = true;
        isClicked = false;
      });
    });

    // Start the auto-close timer
    _autoCloseTimer?.cancel(); // Cancel any existing timer
    _autoCloseTimer = Timer(const Duration(seconds: 3), _closeButton);
  }

  // New method to close the button
  void _closeButton() {
    _autoCloseTimer?.cancel(); // Cancel the timer when closing manually

    setState(() {
      _width = 45;
      _showButtons = false;
    });
    Future.delayed(durationAnimation200, () {
      setState(() {
        _yPositionPlusButton = _yPositionPlusButtonClose;
        isOpen = false;
        isClicked = false;
      });
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor:
          CustomColor.transparent, // Make the Scaffold background transparent
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(0, _yPositionPlusButton),
            duration: durationAnimation300,
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: _handleTap,
              child: AnimatedContainer(
                width: _width,
                height: _height,
                duration: durationAnimation300,
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: CustomColor.customBlack,
                  borderRadius: BorderRadius.circular(isOpen ? 10.0 : 12.0),
                  boxShadow: [
                    BoxShadow(
                      color: CustomColor.blue.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: CustomColor.purple.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.rotate(
                    alignment: Alignment.center,
                    angle: isOpen ? 0.75 : 0,
                    child: CustomIcon.add.copyWith(
                      color: CustomColor.customWhite,
                      size: sizeIcon,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Custom buttons that appear when the plus button is open
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
                    child: const CfqButton(),
                  ),
                const SizedBox(width: 30),
                if (isOpen)
                  AnimatedOpacity(
                    duration: durationAnimation200,
                    curve: Curves.fastOutSlowIn,
                    opacity: _showButtons ? 1 : 0,
                    child: const TurnButton(),
                  ),
              ],
            ),
          ),
        ],
      ),
      // Bottom navigation bar
      bottomNavigationBar: NavigationBar(
        backgroundColor: CustomColor
            .customBlack, // Make the NavigationBar background transparent
        elevation: 0, // Remove any shadow
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
            if (isOpen) {
              _handleTap();
            }
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
              selectedIcon: CustomIcon.home.copyWith(size: sizeIcon),
              icon: CustomIcon.home
                  .copyWith(color: CustomColor.grey600, size: sizeIcon),
              label: CustomString.emptyString,
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(right: paddinghorizontal, top: paddingTopIcon),
            child: NavigationDestination(
              selectedIcon: CustomIcon.map.copyWith(
                size: sizeIcon,
              ),
              icon: CustomIcon.map.copyWith(
                color: CustomColor.grey600,
                size: sizeIcon,
              ),
              label: CustomString.emptyString,
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: paddinghorizontal, top: paddingTopIcon),
            child: NavigationDestination(
              selectedIcon: CustomIcon.team.copyWith(
                color: CustomColor.customWhite,
                size: sizeIcon,
              ),
              icon: CustomIcon.team.copyWith(
                color: CustomColor.grey600,
                size: sizeIcon,
              ),
              label: CustomString.emptyString,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: paddingTopIcon),
            child: NavigationDestination(
              selectedIcon: CustomIcon.profile.copyWith(
                size: sizeIcon,
              ),
              icon: CustomIcon.profile.copyWith(
                color: CustomColor.grey600,
                size: sizeIcon,
              ),
              label: CustomString.emptyString,
            ),
          ),
        ],
      ),
      // Main body content based on current page index
      body: Stack(
        children: [
          // Corps principal de l'application (hors de la barre de navigation)
          GestureDetector(
            onTap: () {
              if (isOpen) {
                _handleTap();
              }
            }, // Capture les taps en dehors de la barre de navigation
            child: IndexedStack(
              index: currentPageIndex,
              children: const [
                ThreadScreen(),
                MapScreen(),
                TeamsScreen(),
                ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
