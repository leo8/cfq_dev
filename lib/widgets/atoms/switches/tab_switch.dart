import 'package:flutter/material.dart';

class CustomTabSwitch extends StatelessWidget {
  final List<String> tabs;
  final List<Widget> tabViews;
  final TabController? controller;

  const CustomTabSwitch({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.controller,
  }) : assert(tabs.length == tabViews.length,
            'Tabs and views must have the same length');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          bottom: TabBar(
            controller: controller,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(width: 2.0, color: Colors.white),
              insets: EdgeInsets.symmetric(horizontal: 40.0),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: tabViews,
        ),
      ),
    );
  }
}
