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
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
      ),
      child: ListTile(
        dense: false,
        contentPadding: EdgeInsets.zero,
        leading: Text(widget.trailingText,style: normalTextStyle,textAlign: TextAlign.center),
        title: Text(widget.titleText,style: normalTextStyle,textAlign: TextAlign.center),
        visualDensity: VisualDensity.compact,
        minVerticalPadding: 0,
        horizontalTitleGap: 0,
        minLeadingWidth: 0,
        isThreeLine: false,
        onTap: widget.onTap,
      ),
    );
  }
}