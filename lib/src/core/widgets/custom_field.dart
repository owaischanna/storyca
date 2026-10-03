import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.prefixIcon = Icons.email,
    this.suffixIcon = const Icon(
      Remix.eye_close_line,
      color: Color(0xFF9D8AC5),
    ),
    this.overrideIcon,
    required this.hideText,
    required this.hasPrefixIcon,
    required this.hasSuffixIcon,
    this.maxLines = 1,
    this.radius = 10,
    this.enabled = true,
    this.readOnly = false,
    this.textInputAction = TextInputAction.done,
    this.keyboardType = TextInputType.name,
    required this.onSubmitted,
    required this.suffixAction,
    this.maxLength,
    this.hideCounter = true,
    required this.onChange,
    this.borderColor = const Color.fromRGBO(145, 16, 222, 0.5),
  });

  final TextEditingController controller;
  final String placeholder;
  final IconData prefixIcon;
  final Widget suffixIcon;
  final bool hideText;
  final bool hasPrefixIcon;
  final bool hasSuffixIcon;
  final dynamic overrideIcon;
  final int maxLines;
  final double radius;
  final bool enabled;
  final bool readOnly;
  final TextInputAction textInputAction;
  final Function onSubmitted;
  final dynamic maxLength;
  final bool hideCounter;
  final Function suffixAction;
  final TextInputType keyboardType;
  final void Function(String) onChange;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Color(0xFF9D8AC5)),
      obscureText: hideText,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Color(0xff464D5E)),
        ),
        suffixIcon: hasSuffixIcon
            ? overrideIcon ??
                  GestureDetector(
                    onTap: () {
                      suffixAction();
                    },
                    child: suffixIcon,
                  )
            : null,
        prefixIcon: hasPrefixIcon
            ? overrideIcon ??
                  Icon(prefixIcon, color: Color(0xFF9D8AC5), size: 16)
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderColor),
        ),
        hintText: placeholder,
        hintStyle: TextStyle(
          color: Color.fromRGBO(157, 138, 197, 0.3),
          fontSize: 14,
        ),
        counterText: hideCounter ? '' : null,
      ),
      enabled: enabled,
      readOnly: readOnly,
      textInputAction: textInputAction,
      onSubmitted: (value) {
        onSubmitted();
      },
      onChanged: (value) {
        onChange(value);
      },
      maxLength: maxLength,
      keyboardType: keyboardType,
    );
  }
}
