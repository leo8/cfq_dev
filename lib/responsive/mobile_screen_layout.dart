import 'package:cfq_dev/screens/profile_screen.dart';
import 'package:cfq_dev/screens/thread_screen.dart';
import 'package:cfq_dev/utils/logger.dart';
import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  // State variables for managing the state of the plus button and navigation
  bool isClicked = false; // Prevent multiple rapid clicks
  bool isOpen = false; // Track if the floating button is expanded
  bool _showButtons =
      false; // Show additional buttons (edit, camera) when expanded
  int currentPageIndex = 0; // Track the current page selected
  double _yPositionPlusButton =
      0.95; // Y position of the plus button (floating action button)
  double _width = 45.0; // Initial width of the plus button
  final double _height = 45.0; // Height of the plus button
  final double _yPositionPlusButtonClose = 0.95; // Y position when closed
  final double _yPositionPlusButtonOpen = 0.80; // Y position when opened
  final Duration durationAnimation200 =
      const Duration(milliseconds: 200); // Short animation duration
  final Duration durationAnimation500 =
      const Duration(milliseconds: 500); // Longer animation duration
  final double paddingTopIcon =
      10; // Top padding for icons in the bottom navigation bar
  final double paddinghorizontal =
      40; // Horizontal padding for icons in the navigation bar
  final double sizeIcon = 30; // Size of icons

  // Handle the tap on the plus button
  void _handleTap() {
    if (isClicked) {
      return; // Prevent further clicks while handling the current one
    }
    isClicked = true; // Block further taps

    if (isOpen) {
      // If the button is open, close it
      setState(() {
        _width = 45; // Shrink the button horizontally
      });
      Future.delayed(durationAnimation200, () {
        setState(() {
          _yPositionPlusButton = _yPositionPlusButtonClose; // Move button down
          isClicked = false; // Allow new clicks
        });
      });
      _showButtons = false; // Hide additional buttons
    } else {
      // If the button is closed, open it
      setState(() {
        _yPositionPlusButton = _yPositionPlusButtonOpen; // Move button up
      });
      Future.delayed(durationAnimation200, () {
        setState(() {
          _width = 200; // Expand the button horizontally
        });
      });
      Future.delayed(durationAnimation500, () {
        setState(() {
          _showButtons = true; // Show additional buttons
          isClicked = false; // Allow new clicks
        });
      });
    }
    isOpen = !isOpen; // Toggle open state
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBody:
          true, // Extend the body to allow floating action button over content
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // Position the floating button at the bottom center
      floatingActionButton: Stack(
        children: [
          // Floating action button (plus button) with animation for position and size
          AnimatedAlign(
            alignment: Alignment(
                0, _yPositionPlusButton), // Change position dynamically
            duration: durationAnimation500,
            curve: Curves.easeInOut, // Smooth animation curve
            child: GestureDetector(
              onTap: _handleTap, // Handle tap to toggle open/close state
              child: AnimatedContainer(
                width: _width, // Width changes based on open/close state
                height: _height, // Fixed height
                decoration: BoxDecoration(
                  color: CustomColor.black, // Button background color
                  borderRadius: BorderRadius.circular(
                      isOpen ? 10.0 : 0.0), // Rounded corners when open
                ),
                duration:
                    durationAnimation500, // Duration for container width change
                curve: Curves.easeInOut, // Smooth transition curve
                child: Transform.rotate(
                  alignment: Alignment.center, // Rotate the plus icon when open
                  angle: isOpen ? 0.75 : 0,
                  child: Icon(
                    Icons.add, // Plus icon
                    color: CustomColor.white,
                    size: sizeIcon,
                  ),
                ),
              ),
            ),
          ),
          // Buttons (edit, camera) that appear when the plus button is open
          Align(
            alignment: Alignment(0,
                _yPositionPlusButton), // Align the buttons to the floating action button
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isOpen) // Show only when the button is open
                  AnimatedOpacity(
                    duration: durationAnimation200,
                    curve: Curves.fastOutSlowIn,
                    opacity: _showButtons ? 1 : 0, // Fade in/out animation
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: CustomColor.white,
                      ),
                      splashColor:
                          CustomColor.transparent, // Disable splash effect
                      onPressed: () {
                        AppLogger.debug("click edit");
                      },
                    ),
                  ),
                const SizedBox(
                    width: 90), // Space between edit and camera buttons
                if (isOpen)
                  AnimatedOpacity(
                    duration: durationAnimation200,
                    curve: Curves.fastOutSlowIn,
                    opacity: _showButtons ? 1 : 0, // Fade in/out animation
                    child: IconButton(
                      splashColor: CustomColor.transparent,
                      focusColor:
                          CustomColor.transparent, // Disable focus effect
                      icon: const Icon(
                        Icons.camera_alt,
                        color: CustomColor.white,
                      ),
                      onPressed: () {
                        AppLogger.debug("click photo");
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // Bottom navigation bar
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex =
                index; // Update page index on navigation selection
          });
        },
        indicatorColor: CustomColor.transparent, // Disable indicator color
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (_) => CustomColor.transparent, // Disable overlay effect
        ),
        selectedIndex: currentPageIndex, // Track current page
        destinations: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: paddingTopIcon),
            child: NavigationDestination(
              selectedIcon: Icon(
                CustomIcon.languageOutlined,
                color: CustomColor.white,
                size: sizeIcon,
              ),
              icon: Icon(
                CustomIcon.languageOutlined,
                color: CustomColor.black,
                size: sizeIcon,
              ),
              label: '', // No label
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(right: paddinghorizontal, top: paddingTopIcon),
            child: NavigationDestination(
              selectedIcon: Icon(
                CustomIcon.locationOnOutlined,
                color: CustomColor.white,
                size: sizeIcon,
              ),
              icon: Icon(
                CustomIcon.locationOnOutlined,
                color: CustomColor.black,
                size: sizeIcon,
              ),
              label: '', // No label
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: paddinghorizontal, top: paddingTopIcon),
            child: NavigationDestination(
              selectedIcon: Icon(
                CustomIcon.calendarTodayOutlined,
                color: CustomColor.white,
                size: sizeIcon,
              ),
              icon: Icon(
                CustomIcon.calendarTodayOutlined,
                color: CustomColor.black,
                size: sizeIcon,
              ),
              label: '', // No label
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: paddingTopIcon),
            child: NavigationDestination(
              selectedIcon: Icon(
                CustomIcon.personOutlined,
                color: CustomColor.white,
                size: sizeIcon,
              ),
              icon: Icon(
                CustomIcon.personOutlined,
                color: CustomColor.black,
                size: sizeIcon,
              ),
              label: '', // No label
            ),
          ),
        ],
      ),
      // Main body content based on current page index
      body: <Widget>[
        const ThreadScreen(), // Home thread screen
        const Center(child: Text('Map')), // Map screen
        const Center(child: Text('Friends')), // Friends screen
        const ProfileScreen(), // Profile screen
      ][currentPageIndex], // Display content based on selected page
    );
  }
}
