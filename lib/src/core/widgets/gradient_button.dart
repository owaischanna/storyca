import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.hasIcon = false,
    this.icon = Remix.question_mark,
    required this.onPressed,
    this.fontSize = 16,
    this.iconSize = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    this.radius = 10,
    this.reverse = false,
  });

  final String label;
  final bool hasIcon;
  final IconData icon;
  final void Function() onPressed;
  final double fontSize;
  final double iconSize;
  final EdgeInsets padding;
  final double radius;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: defaultGradientTTB,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: padding,
          ),
          child: Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: reverse
                ? [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: fontSize),
                      ),
                    ),
                    if (hasIcon)
                      Icon(icon, color: Colors.white, size: iconSize),
                  ]
                : [
                    if (hasIcon)
                      Icon(icon, color: Colors.white, size: iconSize),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: fontSize),
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
