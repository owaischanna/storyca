import 'package:flutter/material.dart';

class QuickStartTHItem extends StatelessWidget {
  const QuickStartTHItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
  });

  final String label;
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Color.fromRGBO(181, 77, 232, 0.3),
          ),
          borderRadius: BorderRadius.circular(5),
          color: isSelected
              ? Color.fromRGBO(181, 77, 232, 1)
              : Colors.transparent,
        ),
        child: Column(
          spacing: 4,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Color(0xffDFBDFF),
              size: 16,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xffDFBDFF),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
