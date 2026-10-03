import 'package:flutter/material.dart';

class TrendingSearchItem extends StatelessWidget {
  const TrendingSearchItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final String item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Color.fromRGBO(153, 79, 255, 0.1),
          boxShadow: [
            BoxShadow(color: Color.fromRGBO(145, 16, 222, 0.3), blurRadius: 10),
          ],
          border: Border.all(width: 1, color: Color(0xff994FFF)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(item, style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }
}
