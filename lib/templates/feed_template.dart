import 'package:flutter/material.dart';

class FeedTemplate extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget body;
  final String backgroundImageUrl;

  const FeedTemplate({
    required this.appBar,
    required this.body,
    required this.backgroundImageUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: body,
      ),
    );
  }
}
