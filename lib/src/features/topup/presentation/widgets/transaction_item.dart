import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.type,
    required this.date,
    required this.coin,
    required this.price,
  });

  final String type;
  final String date;

  /// Signed — negative means coins went out of the wallet. The row's color,
  /// sign and icon all follow this rather than [type], so a new transaction
  /// kind the app doesn't otherwise special-case still renders correctly.
  final num coin;
  final String price;

  @override
  Widget build(BuildContext context) {
    final isCredit = coin >= 0;
    final color = isCredit ? 0xff00FFAA : 0xffC23B3B;
    final symbol = isCredit ? '+' : '-';
    final icon = isCredit ? Remix.add_circle_line : Remix.indeterminate_circle_line;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Color.fromRGBO(181, 77, 232, 0.3)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 8,
            children: [
              ShaderMask(
                shaderCallback: (bounds) {
                  return defaultGradientLTR.createShader(bounds);
                },
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              Column(
                spacing: 2,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      color: Color(primaryTextCOLR),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              Text(
                '$symbol${coin.abs().toStringAsFixed(coin % 1 == 0 ? 0 : 1)} Coins',
                style: TextStyle(
                  color: Color(color),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (price.isNotEmpty)
                Text(
                  price,
                  style: TextStyle(color: Color(primaryTextCOLR), fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
