import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/transaction_api_model.dart';
import 'package:storryca/src/core/network/models/wallet_api_model.dart';

class TopupResult {
  TopupResult({
    required this.reference,
    required this.link,
    required this.coins,
    required this.currency,
    required this.amount,
    required this.display,
  });

  final String reference;
  final String link;
  final num coins;
  final String currency;
  final num amount;
  final String display;

  factory TopupResult.fromJson(Map<String, dynamic> json) => TopupResult(
    reference: json['reference'] as String? ?? '',
    link: json['link'] as String? ?? '',
    coins: json['coins'] as num? ?? 0,
    currency: json['currency'] as String? ?? 'NGN',
    amount: json['amount'] as num? ?? 0,
    display: json['display'] as String? ?? '',
  );
}

class VerifyResult {
  VerifyResult({
    required this.balance,
    required this.coins,
    required this.alreadyCredited,
  });

  final num balance;
  final num coins;
  final bool alreadyCredited;

  factory VerifyResult.fromJson(Map<String, dynamic> json) => VerifyResult(
    balance: json['balance'] as num? ?? 0,
    coins: json['coins'] as num? ?? 0,
    alreadyCredited: json['already_credited'] as bool? ?? false,
  );
}

class UnlockResult {
  UnlockResult({
    required this.balance,
    required this.unlocked,
    required this.charged,
    required this.price,
  });

  final num balance;
  final bool unlocked;

  /// False when the reader already owned the book, or is its own author —
  /// not an error, just nothing to charge.
  final bool charged;
  final num price;

  factory UnlockResult.fromJson(Map<String, dynamic> json) => UnlockResult(
    balance: json['balance'] as num? ?? 0,
    unlocked: json['unlocked'] as bool? ?? false,
    charged: json['charged'] as bool? ?? false,
    price: json['price'] as num? ?? 0,
  );
}

class AdRewardResult {
  AdRewardResult({required this.balance, required this.coins, required this.nextAt});

  final num balance;
  final num coins;
  final String? nextAt;

  factory AdRewardResult.fromJson(Map<String, dynamic> json) => AdRewardResult(
    balance: json['balance'] as num? ?? 0,
    coins: json['coins'] as num? ?? 0,
    nextAt: json['next_at'] as String?,
  );
}

class WalletRepository {
  WalletRepository(this._client);

  final ApiClient _client;

  Future<WalletApiModel> getWallet(String token) async {
    final data = await _client.get('/wallet', token: token) as Map<String, dynamic>;
    return WalletApiModel.fromJson(data);
  }

  Future<List<TransactionApiModel>> transactions(
    String token, {
    int limit = 50,
  }) async {
    final data =
        await _client.get(
              '/wallet/transactions',
              query: {'limit': limit},
              token: token,
            )
            as Map<String, dynamic>;
    final items = data['transactions'] as List? ?? [];
    return items
        .map((e) => TransactionApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TopupResult> topup(int coins, String token) async {
    final data =
        await _client.post('/wallet/topup', body: {'coins': coins}, token: token)
            as Map<String, dynamic>;
    return TopupResult.fromJson(data);
  }

  Future<VerifyResult> verify({
    required String transactionId,
    required String reference,
    required String token,
  }) async {
    final data =
        await _client.post(
              '/wallet/verify',
              body: {'transaction_id': transactionId, 'reference': reference},
              token: token,
            )
            as Map<String, dynamic>;
    return VerifyResult.fromJson(data);
  }

  /// Verifies a Google Play purchase (Android's coin packs go through Play
  /// Billing rather than Flutterwave — see `PlayBillingService`) and credits
  /// the coins, same as [verify] does for a Flutterwave payment.
  Future<VerifyResult> playVerify({
    required String productId,
    required String purchaseToken,
    required String token,
  }) async {
    final data =
        await _client.post(
              '/wallet/play-verify',
              body: {'product_id': productId, 'purchase_token': purchaseToken},
              token: token,
            )
            as Map<String, dynamic>;
    return VerifyResult.fromJson(data);
  }

  Future<UnlockResult> unlock(int storyId, String token) async {
    final data =
        await _client.post(
              '/wallet/unlock',
              body: {'story_id': storyId},
              token: token,
            )
            as Map<String, dynamic>;
    return UnlockResult.fromJson(data);
  }

  Future<AdRewardResult> claimAdReward(String token) async {
    final data =
        await _client.post('/wallet/ad-reward', token: token)
            as Map<String, dynamic>;
    return AdRewardResult.fromJson(data);
  }
}
