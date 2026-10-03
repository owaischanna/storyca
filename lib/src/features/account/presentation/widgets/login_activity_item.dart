import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class LoginActivityItem extends StatelessWidget {
  const LoginActivityItem({
    super.key,
    required this.isApp,
    required this.deviceLabel,
    required this.platformLabel,
    required this.locationAndTime,
    required this.isCurrent,
    required this.isSuccess,
    required this.isLast,
  });

  final bool isApp;
  final String deviceLabel;
  final String platformLabel;
  final String locationAndTime;
  final bool isCurrent;
  final bool isSuccess;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
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
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
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
              isApp ? Remix.smartphone_line : Remix.computer_line,
              size: 22,
              color: Color(0xffCF7FFA),
            ),
          ),
          Expanded(
            child: Column(
              spacing: 2,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Flexible(
                      child: Text(
                        deviceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Color(0xff00FFAA),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Current session',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xff00FFAA),
                            fontSize: 8,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  platformLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(primaryTextCOLR), fontSize: 12),
                ),
                Text(
                  locationAndTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(primaryTextCOLR), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            isCurrent ? 'This device' : (isSuccess ? 'Success' : 'Failed'),
            style: TextStyle(
              color: isCurrent || isSuccess
                  ? Color(0xff00FFAA)
                  : Color(0xffC23B3B),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
