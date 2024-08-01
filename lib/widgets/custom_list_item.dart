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
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(),
                  Text(widget.trailingText,style: textSmallWhite(),textAlign: TextAlign.start),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 20),
                  Text(widget.titleText,style: textSmallWhite(),textAlign: TextAlign.start),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}