import 'package:flutter/material.dart';
import 'package:flutter_games_collection/common/styles.dart';

class CustomListItem extends StatefulWidget {
  const CustomListItem({super.key,required this.trailingText,required this.titleText,required this.onTap});

  final String trailingText;
  final String titleText;
  final VoidCallback onTap;

  @override
  State<CustomListItem> createState() => _CustomListItemState();
}

class _CustomListItemState extends State<CustomListItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.only(top:10.0,bottom: 10.0,left:40.0,right:10.0),
        child: Text("${widget.trailingText}   ${widget.titleText}",style: textSmallWhite(),textAlign: TextAlign.start),
      ),
    );
  }
}