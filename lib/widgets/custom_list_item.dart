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
    return Center(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width*0.16 
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(10.0),
          child: Text("${widget.trailingText}   ${widget.titleText}",style: textSmallWhite(),textAlign: TextAlign.start),
        ),
      ),
    );
  }
}