import 'package:flutter/material.dart';
import 'package:flutter_games_collection/common/styles.dart';

// Base Scaffold Layout for All Pages
class BaseScaffoldLayout extends StatelessWidget {
  const BaseScaffoldLayout({super.key,required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }
}