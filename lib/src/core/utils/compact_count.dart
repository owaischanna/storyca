/// Big counts shortened for display: under 1000 as-is, then 1k, 10k,
/// 620.1k, 1.2M. Rounds down to one decimal so 999,999 reads "999.9k",
/// never "1000k".
String compactCount(num value) {
  final n = value.toInt();
  String oneDecimal(int whole, int unit) {
    final tenths = (whole * 10) ~/ unit;
    final text = (tenths / 10).toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  if (n >= 1000000) return '${oneDecimal(n, 1000000)}M';
  if (n >= 1000) return '${oneDecimal(n, 1000)}k';
  return '$n';
}

/// [compactCount] for counts that arrive as text; anything that isn't a
/// number (e.g. "-") is shown unchanged.
String compactCountText(String value) {
  final n = num.tryParse(value);
  return n == null ? value : compactCount(n);
}
