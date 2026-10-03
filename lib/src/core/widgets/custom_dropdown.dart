import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.controller,
    required this.items,
    this.radius = 10,
    this.borderColor = const Color.fromRGBO(145, 16, 222, 0.5),
    this.iconColor = const Color(0xff994FFF),
    this.prefixIcon,
  });

  final TextEditingController controller;
  final List items;
  final double radius;
  final Color borderColor;
  final Color iconColor;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DropdownMenu(
        controller: controller,
        textStyle: TextStyle(color: Color(0xff9D8AC5), fontSize: 12),
        width: MediaQuery.of(context).size.width * 0.95,
        menuHeight: 400,
        menuStyle: MenuStyle(
          shape: WidgetStateProperty.resolveWith((states) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            );
          }),
          backgroundColor: WidgetStateColor.resolveWith((states) {
            return Color.fromRGBO(23, 0, 45, 0.99);
          }),
          padding: WidgetStateProperty.resolveWith((states) {
            return EdgeInsets.all(0);
          }),
        ),
        decorationBuilder: (context, controller) {
          return InputDecoration(
            prefixIcon: prefixIcon != null
                ? ShaderMask(
                    shaderCallback: (bounds) {
                      return defaultGradientTTB.createShader(bounds);
                    },
                    child: Icon(prefixIcon, size: 16, color: Colors.white),
                  )
                : null,
            suffixIcon: Icon(
              Remix.arrow_down_s_line,
              color: iconColor,
              size: 14,
            ),
            hintStyle: TextStyle(color: Color(0xff9D8AC5), fontSize: 12),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(width: 1, color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(width: 1, color: borderColor),
            ),
          );
        },
        dropdownMenuEntries: [
          ...List.generate(items.length, (index) {
            final item = items[index];
            return DropdownMenuEntry(
              value: item,
              label: item,
              style: ButtonStyle(
                padding: WidgetStateProperty.resolveWith((states) {
                  return EdgeInsets.symmetric(horizontal: 20);
                }),
                foregroundColor: WidgetStateColor.resolveWith((state) {
                  return Colors.white;
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}
