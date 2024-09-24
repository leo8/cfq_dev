import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RepsonsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;
  const RepsonsiveLayout(
      {Key? key,
      required this.webScreenLayout,
      required this.mobileScreenLayout})
      : super(key: key);

  @override
  State<RepsonsiveLayout> createState() => _RepsonsiveLayoutState();
}

class _RepsonsiveLayoutState extends State<RepsonsiveLayout> {
  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > CustomDimension.webScreenSize) {
          return widget.webScreenLayout;
        }
        return widget.mobileScreenLayout;
      },
    );
  }
}
