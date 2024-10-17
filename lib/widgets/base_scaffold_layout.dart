import 'package:flutter/material.dart';
import 'package:flutter_games_collection/common/styles.dart';

// Base Scaffold Layout for All Pages
class BaseScaffoldLayout extends StatelessWidget {
  const BaseScaffoldLayout({super.key,required this.child,this.appbar, this.extendBehindAppBar, this.showScrollBar, this.bodyContentAlignment});
  final Widget child;
  final AppBar? appbar;
  final bool? extendBehindAppBar;
  final bool? showScrollBar;
  final Alignment? bodyContentAlignment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      extendBodyBehindAppBar: extendBehindAppBar??false,
      appBar: appbar,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(10),
        alignment: bodyContentAlignment??Alignment.center,
        child: showScrollBar==true
        ?Scrollbar(
          interactive: true,
          thickness: 10,
          radius: const Radius.circular(8),
          child: SingleChildScrollView(
            child: child,
          ),
        )
        : SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }
}