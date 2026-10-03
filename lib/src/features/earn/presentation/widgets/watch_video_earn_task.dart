import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/repositories/wallet_repository.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

/// The real Android rewarded unit from the client's AdMob console. No iOS
/// unit has been provided yet, so iOS still falls back to Google's shared
/// test unit — always fills, never pays real money — until one is.
String get _rewardedAdUnitId => Platform.isIOS
    ? 'ca-app-pub-3940256099942544/1712485313'
    : 'ca-app-pub-1179647671645751/3340326195';

class WatchVideoEarnTask extends StatefulWidget {
  const WatchVideoEarnTask({
    super.key,
    required this.coins,
    required this.available,
    required this.nextAt,
    required this.onClaimed,
  });

  final num coins;
  final bool available;

  /// When the ad reward can next be claimed — null while [available] is true.
  final String? nextAt;
  final void Function(AdRewardResult result) onClaimed;

  @override
  State<WatchVideoEarnTask> createState() => _WatchVideoEarnTaskState();
}

class _WatchVideoEarnTaskState extends State<WatchVideoEarnTask> {
  bool _loadingAd = false;

  String get _resetLabel {
    final nextAt = widget.nextAt;
    if (nextAt == null) return '';
    final at = DateTime.tryParse(nextAt);
    if (at == null) return '';
    final remaining = at.difference(DateTime.now());
    if (remaining.isNegative) return '';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    return 'Resets in ${hours}h ${minutes}m';
  }

  Future<void> _watchAd() async {
    final token = await authService.getToken();
    if (!mounted) return;
    if (token == null) {
      AppSnackbar.warning(context, 'Sign in to earn coins.');
      return;
    }
    if (_loadingAd || !widget.available) return;
    setState(() => _loadingAd = true);
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _loadingAd = false);
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
          );
          ad.show(
            onUserEarnedReward: (ad, reward) => _claimAdCoin(token),
          );
        },
        onAdFailedToLoad: (error) {
          if (!mounted) return;
          setState(() => _loadingAd = false);
          AppSnackbar.error(context, 'No ad available right now.');
        },
      ),
    );
  }

  Future<void> _claimAdCoin(String token) async {
    try {
      final result = await walletRepository.claimAdReward(token);
      if (mounted) AppSnackbar.success(context, 'You earned ${result.coins} coin.');
      widget.onClaimed(result);
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.warning(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Color.fromRGBO(181, 77, 232, 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Expanded(
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Color(0xff8343D5)),
                    borderRadius: BorderRadius.circular(6),
                    gradient: profileIconCardGradientCOLR,
                  ),
                  child: Image.asset(watchVideoIMG, width: 40),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          Flexible(
                            child: Text(
                              'Watch Ad Video',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfair(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(153, 79, 255, 0.1),
                              border: Border.all(
                                width: 0.1,
                                color: Color(0xFF994FFF),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Daily',
                              style: TextStyle(
                                color: Color(0xFF994FFF),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Watch a short video and earn coins!',
                        style: defaultTextStyle,
                      ),
                      if (!widget.available && _resetLabel.isNotEmpty)
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                  color: Color.fromRGBO(181, 77, 232, 0.3),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                spacing: 4,
                                children: [
                                  Icon(
                                    Remix.time_line,
                                    size: 10,
                                    color: Color(secondaryCOLR),
                                  ),
                                  Text(_resetLabel, style: secondaryF10TS),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                spacing: 8,
                children: [
                  Image.asset(aCoinIMG, width: 20),
                  Text('+${widget.coins}', style: secondaryF16TS),
                ],
              ),
              SizedBox(
                width: 120,
                height: 30,
                child: GradientButton(
                  label: _loadingAd
                      ? 'Loading…'
                      : widget.available
                      ? 'Watch Video'
                      : 'Watched Today',
                  hasIcon: true,
                  icon: Remix.movie_2_ai_line,
                  fontSize: 12,
                  iconSize: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  radius: 4,
                  onPressed: (_loadingAd || !widget.available)
                      ? () {}
                      : _watchAd,
                ),
              ),
              Text(
                widget.available ? '0/1 watched today' : '1/1 watched today',
                style: defaultTextStyle10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
