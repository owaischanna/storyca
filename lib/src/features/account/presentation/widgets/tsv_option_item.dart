import 'package:flutter/material.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class TSVOptionItem extends StatelessWidget {
  const TSVOptionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color.fromRGBO(157, 138, 197, 0.2),
          ),
        ),
      ),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Color(0xff8343D5)),
              borderRadius: BorderRadius.circular(40),
              gradient: profileIconCardGradientCOLR,
            ),
            child: Icon(icon, size: 22, color: Color(0xffCF7FFA)),
          ),
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  caption,
                  style: TextStyle(color: Color(0xff9D8AC5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
