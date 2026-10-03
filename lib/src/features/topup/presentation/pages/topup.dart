import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/wallet_api_model.dart';
import 'package:storryca/src/core/network/play_billing_products.dart';
import 'package:storryca/src/core/network/play_billing_service.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/topup/presentation/pages/checkout_webview.dart';
import 'package:storryca/src/features/topup/presentation/widgets/topup_item.dart';

/// Coin packs come back from `/wallet` in this fixed order; matched by
/// position to the pre-shipped coin-stack artwork (there is no `image` field
/// in the API response, since art is a client concern, not a server one).
final List<String> _packImages = [
  coin1IMG,
  coin2IMG,
  coin3IMG,
  coin4IMG,
  coin5IMG,
  coin6IMG,
];

class Topup extends StatefulWidget {
  const Topup({super.key});

  @override
  State<Topup> createState() => _TopupState();
}

class _TopupState extends State<Topup> {
  WalletApiModel? _wallet;
  String? _error;
  String? _token;
  int? _purchasingCoins;

  /// Play Store's own listings for the 6 coin packs, keyed by product ID —
  /// Android only. Populated best-effort; the buy button still falls back to
  /// the wallet API's price display if this hasn't loaded yet.
  Map<String, ProductDetails> _playProducts = {};
  StreamSubscription<PlayBillingOutcome>? _playOutcomes;

  @override
  void initState() {
    super.initState();
    _load();
    if (Platform.isAndroid) {
      _playOutcomes = playBillingService.outcomes.listen(_onPlayOutcome);
      _loadPlayProducts();
      // Picks up any purchase that was charged but never got verified and
      // consumed — e.g. a dropped connection to the backend mid-purchase —
      // so it retries here instead of leaving the reader stuck seeing
      // "You already own this item" on every future attempt.
      playBillingService.restorePurchases();
    }
  }

  @override
  void dispose() {
    _playOutcomes?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    _token = await authService.getToken();
    final token = _token;
    if (token == null) {
      setState(() => _error = 'Sign in to use your wallet.');
      return;
    }
    try {
      final wallet = await walletRepository.getWallet(token);
      if (mounted) setState(() => _wallet = wallet);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _loadPlayProducts() async {
    try {
      final products = await playBillingService.queryProducts();
      if (mounted) setState(() => _playProducts = products);
    } catch (_) {
      // Best-effort — buying still works once queried again; only the
      // Play-Store-formatted price display is missing until then.
    }
  }

  String? _productIdForCoins(int coins) {
    for (final product in playBillingProducts) {
      if (product.coins == coins) return product.id;
    }
    return null;
  }

  void _onPlayOutcome(PlayBillingOutcome outcome) {
    if (!mounted) return;
    switch (outcome.type) {
      case PlayBillingOutcomeType.pending:
        break;
      case PlayBillingOutcomeType.success:
        setState(() => _purchasingCoins = null);
        AppSnackbar.success(
          context,
          outcome.alreadyCredited
              ? 'Balance is up to date.'
              : 'Coins added to your wallet.',
        );
        _load();
      case PlayBillingOutcomeType.error:
        setState(() => _purchasingCoins = null);
        AppSnackbar.error(context, outcome.message ?? 'The purchase failed.');
    }
  }

  Future<void> _buy(CoinPackApiModel pack) async {
    final token = _token;
    if (token == null) {
      AppSnackbar.warning(context, 'Sign in to top up your wallet.');
      return;
    }
    if (_purchasingCoins != null) return;
    if (Platform.isAndroid) {
      await _buyViaPlayBilling(pack);
    } else {
      await _buyViaFlutterwave(pack, token);
    }
  }

  /// Starts a Play Billing purchase. Play policy requires digital goods
  /// bought inside an Android app to go through Play Billing, not
  /// Flutterwave, so this is the only path Android takes. The outcome
  /// arrives later on `playBillingService.outcomes` — see [_onPlayOutcome] —
  /// since the store confirms the payment asynchronously.
  Future<void> _buyViaPlayBilling(CoinPackApiModel pack) async {
    final productId = _productIdForCoins(pack.coins.toInt());
    final product = _playProducts[productId];
    if (product == null) {
      AppSnackbar.error(context, 'This coin pack is not available right now.');
      return;
    }
    setState(() => _purchasingCoins = pack.coins.toInt());
    try {
      await playBillingService.buy(product);
    } catch (_) {
      if (mounted) {
        setState(() => _purchasingCoins = null);
        AppSnackbar.error(context, 'Could not start the purchase.');
      }
    }
  }

  Future<void> _buyViaFlutterwave(CoinPackApiModel pack, String token) async {
    setState(() => _purchasingCoins = pack.coins.toInt());
    try {
      final started = await walletRepository.topup(pack.coins.toInt(), token);
      if (!mounted) return;
      final result = await Navigator.of(context).push<Map<String, String?>>(
        MaterialPageRoute(
          builder: (_) => CheckoutWebview(link: started.link),
        ),
      );
      if (result == null) {
        // Reader backed out of the checkout without paying.
        return;
      }
      final transactionId = result['transaction_id'];
      if (transactionId == null) return;
      final verified = await walletRepository.verify(
        transactionId: transactionId,
        reference: started.reference,
        token: token,
      );
      if (!mounted) return;
      AppSnackbar.success(
        context,
        verified.alreadyCredited
            ? 'Balance is up to date.'
            : 'Coins added to your wallet.',
      );
      await _load();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _purchasingCoins = null);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Icon(Remix.arrow_left_s_line),
                  color: Colors.white,
                  iconSize: 24,
                ),

                // HERO
                Center(
                  child: Column(
                    spacing: 2,
                    children: [
                      Text(
                        'Top Up',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 34,
                        ),
                      ),
                      Text(
                        'Top up your balance and get coins to enjoy premium features.',
                        style: TextStyle(
                          color: Color(primaryTextCOLR),
                          fontSize: 12,
                        ),
                      ),
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
                    child: Row(
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
                                  _wallet == null
                                      ? '—'
                                      : _wallet!.balance.toStringAsFixed(
                                          _wallet!.balance % 1 == 0 ? 0 : 1,
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
                  ),
                ),

                // OPTIONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SPACING
                      SizedBox(height: 16),

                      Text(
                        'CHOOSE TOP UP AMOUNT',
                        style: TextStyle(
                          color: Color(secondaryCOLR),
                          fontSize: 16,
                        ),
                      ),
                      if (_error != null)
                        ErrorState(message: _error!, onRetry: _load, height: 200)
                      else if (_wallet == null)
                        const LoadingState(height: 200)
                      else
                        Column(
                          spacing: 16,
                          children: [
                            ..._wallet!.packs.asMap().entries.map((entry) {
                              final pack = entry.value;
                              final image =
                                  _packImages[entry.key % _packImages.length];
                              // On Android, coins are actually bought at
                              // Play's own price, not Flutterwave's — show
                              // that once it's loaded rather than a number
                              // the reader won't be charged.
                              final playPrice = Platform.isAndroid
                                  ? _playProducts[_productIdForCoins(
                                      pack.coins.toInt(),
                                    )]?.price
                                  : null;
                              return TopupItem(
                                coin: pack.coins.toString(),
                                image: image,
                                price: playPrice ?? pack.display,
                                busy: _purchasingCoins != null,
                                onTap: () => _buy(pack),
                              );
                            }),
                          ],
                        ),
                    ],
                  ),
                ),

                // INFO STATEMENT
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Remix.shield_check_line,
                      color: Color(secondaryCOLR),
                      size: 14,
                    ),
                    Text(
                      'Manage your preferences and account',
                      style: TextStyle(
                        color: Color(primaryTextCOLR),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // SPACING
                SizedBox(height: 32),

                // TOPUP HISTORY
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => context.push('/transaction-history'),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Color.fromRGBO(181, 77, 232, 0.1),
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              Icon(
                                Remix.file_list_3_line,
                                color: Color(secondaryCOLR),
                                size: 24,
                              ),
                              Text(
                                'View Top Up History',
                                style: TextStyle(
                                  color: Color(primaryTextCOLR),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Remix.arrow_right_s_line,
                            color: Color(primaryTextCOLR),
                            size: 24,
                          ),
                        ],
                      ),
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
