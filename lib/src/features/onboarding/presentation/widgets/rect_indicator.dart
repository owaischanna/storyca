import 'package:flutter/material.dart';

class RectIndicator extends StatelessWidget {
  const RectIndicator({super.key, this.isActive = false});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: 10,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : const Color.fromRGBO(0xD9, 0xD9, 0xD9, 0.2),
        borderRadius: BorderRadius.circular(32),
      ),
    );
  }
}
