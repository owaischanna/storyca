import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class ActiveSessionItem extends StatelessWidget {
  const ActiveSessionItem({
    super.key,
    required this.type,
    required this.title,
    required this.device,
    required this.location,
    required this.isLast,
    required this.onLogout,
  });

  final String type;
  final String title;
  final String device;
  final String location;
  final bool isLast;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: isLast
                ? Colors.transparent
                : Color.fromRGBO(157, 138, 197, 0.2),
          ),
        ),
      ),
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            child: Row(
              spacing: 8,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Color.fromRGBO(131, 67, 213, 0.3),
                    ),
                    borderRadius: BorderRadius.circular(6),
                    gradient: profileIconCardGradientCOLR,
                  ),
                  child: Icon(
                    type == 'computer'
                        ? Remix.computer_line
                        : Remix.smartphone_line,
                    size: 22,
                    color: Color(0xffCF7FFA),
                  ),
                ),
                // Without Expanded here, the Column sizes to its widest
                // child — and an IPv6 address in `location` is easily wider
                // than the card, pushing the row past the "Log Out" button
                // instead of wrapping or truncating.
                Expanded(
                  child: Column(
                    spacing: 2,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        device,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(primaryTextCOLR),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(primaryTextCOLR),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onLogout,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.5,
                  color: Color.fromRGBO(181, 77, 232, 0.2),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Log Out',
                style: TextStyle(color: Color(secondaryCOLR), fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
