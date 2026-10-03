import 'package:flutter/material.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class TopupItem extends StatelessWidget {
  const TopupItem({
    super.key,
    required this.image,
    required this.coin,
    required this.price,
    this.onTap,
    this.busy = false,
  });

  final String image;
  final String coin;
  final String price;
  final void Function()? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Opacity(
        opacity: busy ? 0.5 : 1,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Color.fromRGBO(181, 77, 232, 0.3),
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 16,
                children: [
                  Image.asset(image, width: 30),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: coin,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' coin',
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(181, 77, 232, 0.1),
                  border: Border.all(
                    width: 1,
                    color: Color.fromRGBO(181, 77, 232, 0.1),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  price,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
