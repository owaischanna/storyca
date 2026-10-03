import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/wallet_api_model.dart';
import 'package:storryca/src/features/earn/presentation/widgets/complete_registation_earn_task.dart';
import 'package:storryca/src/features/earn/presentation/widgets/enable_notification_earn_task.dart';
import 'package:storryca/src/features/earn/presentation/widgets/rate_us_earn_task.dart';
import 'package:storryca/src/features/earn/presentation/widgets/watch_video_earn_task.dart';

class Earn extends StatefulWidget {
  const Earn({super.key});

  @override
  State<Earn> createState() => _EarnState();
}

class _EarnState extends State<Earn> {
  WalletApiModel? _wallet;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await authService.getToken();
    if (token == null) return;
    try {
      final wallet = await walletRepository.getWallet(token);
      if (mounted) setState(() => _wallet = wallet);
    } on ApiException {
      // The rest of the screen is still usable without a balance to show.
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = _wallet;
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        'Earn Rewards',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/transaction-history'),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(255, 255, 255, 0.5),
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            spacing: 8,
                            children: [
                              Image.asset(aCoinIMG, width: 24),
                              Text(
                                wallet == null
                                    ? '—'
                                    : wallet.balance.toStringAsFixed(
                                        wallet.balance % 1 == 0 ? 0 : 1,
                                      ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // HERO
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 16,
                    children: [
                      Image.asset(rewardChestIMG, width: 200),
                      Column(
                        spacing: 2,
                        children: [
                          Text(
                            'Complete tasks and earn coins',
                            style: GoogleFonts.playfair(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Use coins to unlock premium stories and exclusive content.',
                            style: defaultTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // OPTIONS
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 16,
                    children: [
                      WatchVideoEarnTask(
                        coins: wallet?.adReward.coins ?? 0.1,
                        available: wallet?.adReward.available ?? false,
                        nextAt: wallet?.adReward.nextAt,
                        onClaimed: (result) {
                          setState(() {
                            _wallet = wallet == null
                                ? null
                                : WalletApiModel(
                                    balance: result.balance,
                                    currency: wallet.currency,
                                    symbol: wallet.symbol,
                                    bookPrice: wallet.bookPrice,
                                    packs: wallet.packs,
                                    adReward: AdRewardApiModel(
                                      coins: wallet.adReward.coins,
                                      available: false,
                                      nextAt: result.nextAt,
                                    ),
                                  );
                          });
                        },
                      ),
                      RateUsEarnTask(),
                      EnableNotificationEarnTask(),
                      CompleteRegistationEarnTask(),
                    ],
                  ),
                ),

                // SPACING
                SizedBox(height: 50),

                // INFO
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Color.fromRGBO(181, 77, 232, 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Color.fromRGBO(181, 77, 232, 0.1),
                    ),
                    child: Row(
                      spacing: 16,
                      children: [
                        Image.asset(coinsIMG, width: 50),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What are coins?',
                                style: GoogleFonts.playfair(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Coins can be used to unlock premium stories, episodes, and exclusive content on the app.',
                                style: defaultTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // SPACING
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
