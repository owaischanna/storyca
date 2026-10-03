class PlayBillingProduct {
  const PlayBillingProduct({required this.id, required this.coins});

  /// The Play Console product ID.
  final String id;

  /// The coin pack it corresponds to — matches one of the packs `/wallet`
  /// returns, so a Play purchase always lands as the same kind of wallet
  /// transaction a Flutterwave top-up would.
  final int coins;
}

/// The six coin packs as configured in Google Play Console, in the same
/// 2/4/10/30/50/100 order the wallet API returns them in. Only Android uses
/// these — every other platform still buys coins through Flutterwave via
/// the wallet API's own coin packs, since Play Billing is an Android-only
/// requirement.
const List<PlayBillingProduct> playBillingProducts = [
  PlayBillingProduct(id: 'coins_2', coins: 2),
  PlayBillingProduct(id: 'coins_4', coins: 4),
  PlayBillingProduct(id: 'coins_10', coins: 10),
  PlayBillingProduct(id: 'coins_30', coins: 30),
  PlayBillingProduct(id: 'coins_50', coins: 50),
  PlayBillingProduct(id: 'coins_100', coins: 100),
];

Set<String> get playBillingProductIds =>
    playBillingProducts.map((p) => p.id).toSet();
