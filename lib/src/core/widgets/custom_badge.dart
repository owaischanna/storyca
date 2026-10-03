import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  const CustomBadge({
    super.key,
    required this.label,
    this.bgColor = const Color(0xFFC23B3B),
    this.textColor = Colors.white,
    this.fontSize = 12,
    this.radius = 5,
    this.borderColor = Colors.transparent,
  });

  final String label;
  final Color bgColor;
  final Color textColor;
  final double fontSize;
  final double radius;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(width: 1, color: borderColor),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
    );
  }
}
