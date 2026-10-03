import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class NetworkTab extends StatelessWidget {
  const NetworkTab({
    super.key,
    required this.selectedTab,
    required this.icon,
    required this.label,
    required this.count,
    required this.update,
  });

  final String selectedTab;
  final IconData icon;
  final String label;
  final int count;
  final void Function(String) update;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => update(label),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: selectedTab == label
                  ? Color(0xff5C09B4)
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(8),
            color: selectedTab == label
                ? Color.fromRGBO(92, 9, 180, 0.2)
                : Colors.transparent,
          ),
          child: Row(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Remix.group_line,
                size: 16,
                color: selectedTab == label
                    ? Color(0xff5C09B4)
                    : Color(primaryTextCOLR),
              ),
              Text(
                '$label ($count)',
                style: TextStyle(
                  color: selectedTab == label
                      ? Color(0xff5C09B4)
                      : Color(primaryTextCOLR),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
