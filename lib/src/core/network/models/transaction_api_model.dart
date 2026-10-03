class TransactionApiModel {
  TransactionApiModel({
    required this.id,
    required this.kind,
    required this.coins,
    required this.balanceAfter,
    required this.description,
    required this.currency,
    required this.amount,
    required this.createdAt,
  });

  final int id;

  /// One of `topup`, `purchase`, `reward`, `bonus`.
  final String kind;

  /// Negative when coins went out of the wallet.
  final num coins;
  final num balanceAfter;
  final String description;

  /// What was actually paid, in the reader's own currency — only present on
  /// `topup` rows, null everywhere else.
  final String? currency;
  final String? amount;
  final String createdAt;

  factory TransactionApiModel.fromJson(Map<String, dynamic> json) =>
      TransactionApiModel(
        id: json['id'] as int,
        kind: json['kind'] as String? ?? '',
        coins: json['coins'] as num? ?? 0,
        balanceAfter: json['balance_after'] as num? ?? 0,
        description: json['description'] as String? ?? '',
        currency: json['currency'] as String?,
        amount: json['amount'] as String?,
        createdAt: json['created_at'] as String? ?? '',
      );
}
