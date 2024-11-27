import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import 'package:flutter/cupertino.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  late PageController _pageController;
  double _lastOverscroll = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageEnd() {
    Navigator.of(context).pop(); // Changed this line
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.customBlack,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is OverscrollNotification &&
              _pageController.page == 2) {
            _lastOverscroll = notification.overscroll;
          } else if (notification is ScrollEndNotification &&
              _pageController.page == 2) {
            if (_lastOverscroll > 10) {
              _handlePageEnd();
              _lastOverscroll = 0;
              return true;
            }
          } else {
            _lastOverscroll = 0;
          }
          return false;
        },
        child: PageView.builder(
          physics: const ClampingScrollPhysics(),
          controller: _pageController,
          itemCount: 3,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (index == 2) {
                  _handlePageEnd();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Image.asset(
                'assets/images/onBoardingStep${index + 1}.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          },
        ),
      ),
    );
  }
}
