class CoinPackApiModel {
  CoinPackApiModel({
    required this.coins,
    required this.naira,
    required this.currency,
    required this.amount,
    required this.display,
  });

  final num coins;
  final num naira;
  final String currency;
  final num amount;

  /// The price already formatted for the reader's location (e.g.
  /// `'₦1,000.00'`) — print as is, never reformat [amount] locally.
  final String display;

  factory CoinPackApiModel.fromJson(Map<String, dynamic> json) =>
      CoinPackApiModel(
        coins: json['coins'] as num? ?? 0,
        naira: json['naira'] as num? ?? 0,
        currency: json['currency'] as String? ?? 'NGN',
        amount: json['amount'] as num? ?? 0,
        display: json['display'] as String? ?? '',
      );
}

class AdRewardApiModel {
  AdRewardApiModel({
    required this.coins,
    required this.available,
    required this.nextAt,
  });

  final num coins;
  final bool available;

  /// When the ad reward can next be claimed, as the server's raw
  /// `'YYYY-MM-DD HH:MM:SS'` string — null while [available] is true.
  final String? nextAt;

  factory AdRewardApiModel.fromJson(Map<String, dynamic> json) =>
      AdRewardApiModel(
        coins: json['coins'] as num? ?? 0,
        available: json['available'] as bool? ?? false,
        nextAt: json['next_at'] as String?,
      );
}

class WalletApiModel {
  WalletApiModel({
    required this.balance,
    required this.currency,
    required this.symbol,
    required this.bookPrice,
    required this.packs,
    required this.adReward,
  });

  final num balance;
  final String currency;
  final String symbol;
  final num bookPrice;
  final List<CoinPackApiModel> packs;
  final AdRewardApiModel adReward;

  factory WalletApiModel.fromJson(Map<String, dynamic> json) => WalletApiModel(
    balance: json['balance'] as num? ?? 0,
    currency: json['currency'] as String? ?? 'NGN',
    symbol: json['symbol'] as String? ?? '',
    bookPrice: json['book_price'] as num? ?? 0,
    packs: (json['packs'] as List? ?? [])
        .map((e) => CoinPackApiModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    adReward: AdRewardApiModel.fromJson(
      json['ad_reward'] as Map<String, dynamic>? ?? const {},
    ),
  );
}
