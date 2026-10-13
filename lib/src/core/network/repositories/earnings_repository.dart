import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/earnings_api_model.dart';

/// `period` is one of today, this_month, last_month, this_year, last_year,
/// all, custom (custom takes from/to as YYYY-MM-DD).
class EarningsPeriod {
  const EarningsPeriod(this.key, {this.from, this.to});

  final String key;
  final String? from;
  final String? to;

  Map<String, dynamic> get query => {
    'period': key,
    if (key == 'custom') 'from': from,
    if (key == 'custom') 'to': to,
  };
}

/// Authors only — a reader's token gets 403 from every call here.
class EarningsRepository {
  EarningsRepository(this._client);

  final ApiClient _client;

  Future<EarningsDashboard> dashboard(
    String token, {
    EarningsPeriod period = const EarningsPeriod('this_month'),
  }) async {
    final data =
        await _client.get('/earnings', query: period.query, token: token)
            as Map<String, dynamic>;
    return EarningsDashboard.fromJson(data);
  }

  /// Best earner first.
  Future<List<StoryEarning>> stories(
    String token, {
    EarningsPeriod period = const EarningsPeriod('this_month'),
  }) async {
    final data = await _client.get(
      '/earnings/stories',
      query: period.query,
      token: token,
    );
    return (data as List? ?? const [])
        .map((e) => StoryEarning.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// The countries StorryCa can pay into, sorted for a picker. Never
  /// hard-coded — the client may add countries.
  Future<List<PayoutCountry>> countries(String token) async {
    final data = await _client.get('/earnings/countries', token: token);
    return (data as List? ?? const [])
        .map((e) => PayoutCountry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BankList> banks(String countryCode, String token) async {
    final data =
        await _client.get(
              '/earnings/banks',
              query: {'country': countryCode},
              token: token,
            )
            as Map<String, dynamic>;
    return BankList.fromJson(data);
  }

  /// The real account name at the bank. Only for countries with a bank list.
  Future<String> resolveAccountName({
    required String accountNumber,
    required String bankCode,
    required String token,
  }) async {
    final data =
        await _client.post(
              '/earnings/resolve',
              body: {'account_number': accountNumber, 'bank_code': bankCode},
              token: token,
            )
            as Map<String, dynamic>;
    return data['account_name'] as String? ?? '';
  }

  Future<BankDetails> bankDetails(String token) async {
    final data =
        await _client.get('/earnings/bank', token: token)
            as Map<String, dynamic>;
    return BankDetails.fromJson(data);
  }

  /// Returns the server's message. [fields] carries whichever of bank_code,
  /// bank_name, swift_code and routing_number the country's form uses.
  Future<String> saveBankDetails({
    required String country,
    required String accountName,
    required String accountNumber,
    required Map<String, String> fields,
    required String token,
  }) async {
    final body =
        await _client.post(
              '/earnings/bank',
              body: {
                'country': country,
                'account_name': accountName,
                'account_number': accountNumber,
                ...fields,
              },
              token: token,
              includeEnvelope: true,
            )
            as Map<String, dynamic>;
    return body['message'] as String? ?? 'Bank details saved.';
  }

  /// Returns the server's message, which already says how long payment takes.
  Future<String> withdraw(num amount, String token) async {
    final body =
        await _client.post(
              '/earnings/withdraw',
              body: {'amount': amount},
              token: token,
              includeEnvelope: true,
            )
            as Map<String, dynamic>;
    return body['message'] as String? ?? 'Withdrawal requested.';
  }

  /// Newest first.
  Future<List<Withdrawal>> withdrawals(String token) async {
    final data = await _client.get('/earnings/withdrawals', token: token);
    return (data as List? ?? const [])
        .map((e) => Withdrawal.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
