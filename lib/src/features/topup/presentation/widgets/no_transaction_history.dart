import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';

class NoTransactionHistory extends StatelessWidget {
  const NoTransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(emptyTransactionHistoryIMG, width: 150),
          Column(
            children: [
              Text(
                'No Transactions yet',
                style: GoogleFonts.playfair(color: Colors.white, fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  textAlign: TextAlign.center,
                  'You haven’t made any transactions yet. Your transactions will appear here.',
                  style: TextStyle(color: Color(primaryTextCOLR), fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
