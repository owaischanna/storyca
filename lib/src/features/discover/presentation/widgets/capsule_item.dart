import 'package:flutter/material.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class CapsuleItem extends StatelessWidget {
  const CapsuleItem({
    super.key,
    required this.selectedCategory,
    required this.category,
    required this.update,
  });

  final String selectedCategory;
  final String category;
  final void Function(String) update;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => update(category),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
          gradient: selectedCategory == category
              ? defaultGradientTTB
              : capsuleGradient,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: selectedCategory == category
                ? Colors.white
                : Color.fromRGBO(255, 255, 255, 0.7),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
