import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/auth_service.dart';
import 'package:storryca/src/core/network/play_billing_products.dart';
import 'package:storryca/src/core/network/repositories/wallet_repository.dart';

enum PlayBillingOutcomeType { pending, success, error }

/// What happened to one purchase, once this service has finished acting on
/// it. `topup.dart` listens to a stream of these to show a snackbar and
/// refresh the wallet balance — it never touches `PurchaseDetails` or the
/// verify/consume bookkeeping directly.
class PlayBillingOutcome {
  const PlayBillingOutcome._(
    this.type,
    this.productId, {
    this.balance,
    this.coins,
    this.alreadyCredited = false,
    this.message,
  });

  factory PlayBillingOutcome.pending(String productId) =>
      PlayBillingOutcome._(PlayBillingOutcomeType.pending, productId);

  factory PlayBillingOutcome.success(
    String productId, {
    required num balance,
    required num coins,
    required bool alreadyCredited,
  }) => PlayBillingOutcome._(
    PlayBillingOutcomeType.success,
    productId,
    balance: balance,
    coins: coins,
    alreadyCredited: alreadyCredited,
  );

  factory PlayBillingOutcome.error(String productId, String message) =>
      PlayBillingOutcome._(
        PlayBillingOutcomeType.error,
        productId,
        message: message,
      );

  final PlayBillingOutcomeType type;
  final String productId;
  final num? balance;
  final num? coins;
  final bool alreadyCredited;
  final String? message;
}

/// Wraps `package:in_app_purchase` for the Android coin packs. Google Play
/// policy requires digital goods bought inside an Android app to go through
/// Play Billing, so this is what the top-up screen calls on Android instead
/// of the Flutterwave checkout used on every other platform.
class PlayBillingService {
  PlayBillingService(this._wallet, this._auth);

  final WalletRepository _wallet;
  final AuthService _auth;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _listening = false;

  final StreamController<PlayBillingOutcome> _outcomes =
      StreamController<PlayBillingOutcome>.broadcast();
  Stream<PlayBillingOutcome> get outcomes => _outcomes.stream;

  /// Starts listening to the purchase stream. Safe to call once at app
  /// startup, and safe to call again.
  ///
  /// Subscribing alone only catches a purchase that completes *during this
  /// session* (i.e. live, right after [buy]) — Android's Billing Library
  /// does not replay a purchase from an earlier, already-ended session just
  /// because something is listening again. [restorePurchases] is what
  /// actually asks Play "what does this account currently own but hasn't
  /// been consumed yet" and feeds any answer back through the same stream,
  /// which is what lets a purchase that was charged but never verified in a
  /// previous session (the app was killed mid-purchase, or the backend was
  /// briefly unreachable) get retried automatically instead of leaving the
  /// reader stuck on "You already own this item" forever.
  void start() {
    if (_listening || !Platform.isAndroid) return;
    _listening = true;
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {},
    );
    unawaited(restorePurchases());
  }

  /// Re-queries Play for anything this account owns but hasn't been consumed
  /// — see [start]'s doc for why this is necessary on Android. Also worth
  /// calling whenever the top-up screen opens, not just at cold start, in
  /// case a purchase got stuck earlier in the same running session (e.g. the
  /// backend was down for that one verify call).
  Future<void> restorePurchases() async {
    if (!Platform.isAndroid) return;
    try {
      await _iap.restorePurchases();
    } catch (_) {
      // Best-effort — a failed restore just means a stuck purchase (if any)
      // waits for the next attempt rather than breaking the topup screen.
    }
  }

  void dispose() {
    _subscription?.cancel();
    _outcomes.close();
  }

  Future<bool> isAvailable() => _iap.isAvailable();

  /// Looks up the 6 coin packs' live Play Store listings — price, title,
  /// description — keyed by product ID.
  Future<Map<String, ProductDetails>> queryProducts() async {
    final response = await _iap.queryProductDetails(playBillingProductIds);
    return {for (final p in response.productDetails) p.id: p};
  }

  /// Starts a purchase. `autoConsume: false` is deliberate — the purchase is
  /// only consumed once the backend has actually credited the coins (see
  /// [_verifyAndConsume]), not the moment Play reports it as bought, so a
  /// failed verify never leaves a reader both charged and short a purchase
  /// they could otherwise retry. The result arrives later on [outcomes],
  /// once the purchase stream delivers it — this call only starts the flow.
  Future<void> buy(ProductDetails product) => _iap.buyConsumable(
    purchaseParam: PurchaseParam(productDetails: product),
    autoConsume: false,
  );

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _outcomes.add(PlayBillingOutcome.pending(purchase.productID));
        case PurchaseStatus.error:
          _outcomes.add(
            PlayBillingOutcome.error(
              purchase.productID,
              purchase.error?.message ?? 'The purchase failed.',
            ),
          );
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
        case PurchaseStatus.canceled:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndConsume(purchase);
      }
    }
  }

  Future<void> _verifyAndConsume(PurchaseDetails purchase) async {
    final token = await _auth.getToken();
    if (token == null) {
      // No signed-in reader to credit — leave the purchase unfinished so
      // it's redelivered once they sign back in, rather than discarded.
      return;
    }
    try {
      final result = await _wallet.playVerify(
        productId: purchase.productID,
        purchaseToken: purchase.verificationData.serverVerificationData,
        token: token,
      );
      await _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
          .consumePurchase(purchase);
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      _outcomes.add(
        PlayBillingOutcome.success(
          purchase.productID,
          balance: result.balance,
          coins: result.coins,
          alreadyCredited: result.alreadyCredited,
        ),
      );
    } on ApiException catch (e) {
      if (_isTerminal(e)) {
        // No amount of retrying fixes a cancelled/refunded purchase or one
        // for a product we don't sell — leaving it unfinished would just
        // mean the same dead purchase gets redelivered and re-fails on
        // every app start from now on. Dismiss it instead.
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
      // Otherwise deliberately left un-completed and un-consumed: Play
      // redelivers this purchase the next time the stream is subscribed to
      // (e.g. reopening the app), giving a dropped connection, a down
      // backend, or Google's own not-yet-propagated confirmation another
      // chance to verify instead of losing the purchase outright.
      _outcomes.add(PlayBillingOutcome.error(purchase.productID, e.message));
    }
  }

  /// True for a 422 the backend will never turn into a credit no matter how
  /// many times it's retried — as opposed to "Google Play could not confirm
  /// that purchase yet" or "That payment has not completed yet", which are
  /// worth trying again once Google's own side catches up.
  bool _isTerminal(ApiException e) {
    if (!e.isUnprocessable) return false;
    final message = e.message.toLowerCase();
    return message.contains('cancelled') ||
        message.contains('canceled') ||
        message.contains('refunded') ||
        message.contains('not a coin pack');
  }
}
