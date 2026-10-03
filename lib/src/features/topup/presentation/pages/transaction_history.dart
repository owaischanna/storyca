import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/transaction_api_model.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/topup/presentation/widgets/has_transaction_history.dart';
import 'package:storryca/src/features/topup/presentation/widgets/no_transaction_history.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  num? _balance;
  List<TransactionApiModel>? _transactions;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final token = await authService.getToken();
    if (token == null) {
      setState(() => _error = 'Sign in to view your transactions.');
      return;
    }
    try {
      final results = await Future.wait<dynamic>([
        walletRepository.getWallet(token),
        walletRepository.transactions(token),
      ]);
      if (!mounted) return;
      setState(() {
        _balance = results[0].balance as num;
        _transactions = results[1] as List<TransactionApiModel>;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              spacing: 16,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: Icon(Remix.arrow_left_s_line),
                        color: Colors.white,
                        iconSize: 24,
                      ),
                      Text(
                        'Transaction History',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // SizedBox(width: 40),
                    ],
                  ),
                ),

                // WALLET
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Color(0xffB54DE8)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      spacing: 16,
                      children: [
                        Row(
                          spacing: 16,
                          children: [
                            Image.asset(walletIMG, width: 84),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wallet Balance',
                                  style: TextStyle(
                                    color: Color(0xff9D8AC5),
                                    fontSize: 18,
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _balance == null
                                          ? '—'
                                          : _balance!.toStringAsFixed(
                                              _balance! % 1 == 0 ? 0 : 1,
                                            ),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'coins',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.push('/topup'),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: defaultGradientTTB,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Remix.add_circle_line,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                Text(
                                  'Top Up Balance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // TRANSACTIONS
                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 300)
                else if (_transactions == null)
                  const LoadingState(height: 300)
                else if (_transactions!.isEmpty)
                  NoTransactionHistory()
                else
                  HasTransactionHistory(transactions: _transactions!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
