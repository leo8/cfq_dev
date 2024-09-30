import 'package:cfq_dev/screens/add_post_screen.dart';
import 'package:cfq_dev/screens/profile_screen.dart';
import 'package:cfq_dev/screens/thread_screen.dart';
import 'package:cfq_dev/utils/home_screen_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/styles/colors.dart';
import '../utils/styles/icons.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int currentPageIndex = 0;
  bool isClicked = false;
  bool isOpen = false;
  double _width = 45.0;
  final double _height = 45.0;
  double _yPositionPlusButtonClose = 0.95;
  double _yPositionPlusButtonOpen = 0.80;
  double _yPositionPlusButton = 0.95;
  bool _showButtons = false;

  void _handleTap() {
    if (isClicked) {
      return;
    }
    isClicked = true;

    if (isOpen) {
      // Fermer horizontalement puis descendre
      setState(() {
        _width = 45; // Fermer horizontalement d'abord
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _yPositionPlusButton = _yPositionPlusButtonClose; // Descendre ensuite
          isClicked = false;
        });
      });
      _showButtons = false;
    } else {
      // Monter d'abord, puis ouvrir horizontalement
      setState(() {
        _yPositionPlusButton = _yPositionPlusButtonOpen; // Monter d'abord
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _width = 200; // Ouvrir horizontalement ensuite
        });
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _showButtons = true; // Afficher les boutons
          isClicked = false;
        });
      });
    }

    // Inverser l'état après les actions
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
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: _handleTap,
              child: AnimatedContainer(
                width: _width,
                height: _height,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(isOpen ? 10.0 : 0.0),
                ),
                // Define how long the animation should take.
                duration: const Duration(milliseconds: 500),
                // Provide an optional curve to make the animation feel smoother.
                curve: Curves.easeInOut,
                child: Transform.rotate(
                  alignment: Alignment.center,
                  angle: isOpen ? 0.75 : 0,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30.0,
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
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.fastOutSlowIn,
                    opacity: _showButtons ? 1 : 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      splashColor: Colors.black.withAlpha(0),
                      onPressed: () {
                        print("click edit");
                      },
                    ),
                  ),
                const SizedBox(width: 90),
                if (isOpen)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.fastOutSlowIn,
                    opacity: _showButtons ? 1 : 0,
                    child: IconButton(
                      splashColor: Colors.black.withAlpha(0),
                      focusColor: Colors.black.withAlpha(0),
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
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
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: const Icon(
              CustomIcon.languageOutlined,
              color: Colors.black,
            ),
            label: '',
          ),
          Padding(
            padding: EdgeInsets.only(right: 40.0),
            child: NavigationDestination(
              icon: const Icon(
                CustomIcon.locationOnOutlined,
                color: Colors.black,
              ),
              label: '',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 40.0),
            child: NavigationDestination(
              icon: const Icon(
                CustomIcon.calendarTodayOutlined,
                color: Colors.black,
              ),
              label: '',
            ),
          ),
          NavigationDestination(
            icon: const Icon(
              CustomIcon.personOutlined,
              color: Colors.black,
            ),
            label: '',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        ThreadScreen(),
        Center(child: Text('Map')),
        AddPostScreen(),
        Center(child: Text('Calendar')),
        ProfileScreen()
      ][currentPageIndex],
    );
  }
}
