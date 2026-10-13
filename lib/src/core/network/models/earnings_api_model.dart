// Author earnings and withdrawals. Money is always naira; every figure shown
// on screen comes from a server *_label field. The bare numbers are for
// arithmetic only. rate_per_read is deliberately not modelled — it must never
// be displayed, and nothing in the app needs it.

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
num _num(dynamic v) => (v as num?) ?? 0;
String _str(dynamic v) => v?.toString() ?? '';

class EarningsPeriodSummary {
  EarningsPeriodSummary({
    required this.reads,
    required this.earningsLabel,
    this.key = '',
    this.label = '',
    this.from = '',
    this.to = '',
  });

  final int reads;
  final String earningsLabel;
  final String key;
  final String label;
  final String from;
  final String to;

  factory EarningsPeriodSummary.fromJson(Map<String, dynamic>? json) {
    final j = json ?? const {};
    return EarningsPeriodSummary(
      reads: _int(j['reads']),
      earningsLabel: _str(j['earnings_label']),
      key: _str(j['key']),
      label: _str(j['label']),
      from: _str(j['from']),
      to: _str(j['to']),
    );
  }
}

class WithdrawalWindow {
  WithdrawalWindow({
    required this.minimumLabel,
    required this.canWithdraw,
    required this.reasons,
    required this.windowOpen,
    required this.opens,
    required this.closes,
    required this.hasBankDetails,
    required this.arrival,
  });

  final String minimumLabel;

  /// The server's decision — the app never re-derives the rules.
  final bool canWithdraw;

  /// Already written for the author to read.
  final List<String> reasons;
  final bool windowOpen;
  final String opens;
  final String closes;
  final bool hasBankDetails;
  final String arrival;

  factory WithdrawalWindow.fromJson(Map<String, dynamic>? json) {
    final j = json ?? const {};
    final window = (j['window'] as Map<String, dynamic>?) ?? const {};
    return WithdrawalWindow(
      minimumLabel: _str(j['minimum_label']),
      canWithdraw: j['can_withdraw'] as bool? ?? false,
      reasons: (j['reasons'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      windowOpen: j['window_open'] as bool? ?? false,
      opens: _str(window['opens']),
      closes: _str(window['closes']),
      hasBankDetails: j['has_bank_details'] as bool? ?? false,
      arrival: _str(j['arrival']),
    );
  }
}

class EarningsDashboard {
  EarningsDashboard({
    required this.currencySymbol,
    required this.balanceLabel,
    required this.totalEarningsLabel,
    required this.availableLabel,
    required this.pendingLabel,
    required this.withdrawnLabel,
    required this.paidReads,
    required this.totalReads,
    required this.totalViews,
    required this.stories,
    required this.thisMonth,
    required this.thisYear,
    required this.period,
    required this.countryName,
    required this.countryChosen,
    required this.mayEarn,
    required this.withdrawal,
  });

  final String currencySymbol;
  final String balanceLabel;
  final String totalEarningsLabel;
  final String availableLabel;
  final String pendingLabel;
  final String withdrawnLabel;

  /// Genuine reads that earned money.
  final int paidReads;

  /// The public read figure — includes reads from before earnings existed,
  /// which pay nothing. Never multiply this by the rate.
  final int totalReads;
  final int totalViews;
  final int stories;
  final EarningsPeriodSummary thisMonth;
  final EarningsPeriodSummary thisYear;
  final EarningsPeriodSummary period;
  final String countryName;
  final bool countryChosen;

  /// False when StorryCa can't pay into the author's country — they earn
  /// nothing there.
  final bool mayEarn;
  final WithdrawalWindow withdrawal;

  factory EarningsDashboard.fromJson(Map<String, dynamic> j) =>
      EarningsDashboard(
        currencySymbol: _str(j['currency_symbol']).isEmpty
            ? '₦'
            : _str(j['currency_symbol']),
        balanceLabel: _str(j['balance_label']),
        totalEarningsLabel: _str(j['total_earnings_label']),
        availableLabel: _str(j['available_label']),
        pendingLabel: _str(j['pending_label']),
        withdrawnLabel: _str(j['withdrawn_label']),
        paidReads: _int(j['paid_reads']),
        totalReads: _int(j['total_reads']),
        totalViews: _int(j['total_views']),
        stories: _int(j['stories']),
        thisMonth: EarningsPeriodSummary.fromJson(
          j['this_month'] as Map<String, dynamic>?,
        ),
        thisYear: EarningsPeriodSummary.fromJson(
          j['this_year'] as Map<String, dynamic>?,
        ),
        period: EarningsPeriodSummary.fromJson(
          j['period'] as Map<String, dynamic>?,
        ),
        countryName: _str(j['country_name']),
        countryChosen: j['country_chosen'] as bool? ?? false,
        mayEarn: j['may_earn'] as bool? ?? true,
        withdrawal: WithdrawalWindow.fromJson(
          j['withdrawal'] as Map<String, dynamic>?,
        ),
      );
}

class StoryEarning {
  StoryEarning({
    required this.storyId,
    required this.title,
    required this.reads,
    required this.amount,
  });

  final int storyId;
  final String title;

  /// Paid reads, not the public figure on the story page.
  final int reads;

  /// Naira. This endpoint sends no label, so it is shown with the
  /// dashboard's currency symbol.
  final num amount;

  factory StoryEarning.fromJson(Map<String, dynamic> j) => StoryEarning(
    storyId: _int(j['story_id']),
    title: _str(j['title']),
    reads: _int(j['reads']),
    amount: _num(j['amount']),
  );
}

class PayoutCountry {
  PayoutCountry({
    required this.code,
    required this.name,
    required this.hasBankList,
  });

  final String code;
  final String name;
  final bool hasBankList;

  factory PayoutCountry.fromJson(Map<String, dynamic> j) => PayoutCountry(
    code: _str(j['code']),
    name: _str(j['name']),
    hasBankList: j['has_bank_list'] as bool? ?? false,
  );
}

class BankOption {
  BankOption({required this.code, required this.name});

  final String code;
  final String name;

  factory BankOption.fromJson(Map<String, dynamic> j) =>
      BankOption(code: _str(j['code']), name: _str(j['name']));
}

class BankList {
  BankList({
    required this.hasBankList,
    required this.needs,
    required this.banks,
  });

  final bool hasBankList;

  /// "swift_code", "routing_number", or "" when there is a bank list.
  final String needs;
  final List<BankOption> banks;

  factory BankList.fromJson(Map<String, dynamic> j) => BankList(
    hasBankList: j['has_bank_list'] as bool? ?? false,
    needs: _str(j['needs']),
    banks: (j['banks'] as List? ?? const [])
        .map((e) => BankOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class BankDetails {
  BankDetails({
    required this.hasBankDetails,
    this.accountName = '',
    this.accountNumberMasked = '',
    this.bankCode = '',
    this.bankName = '',
    this.country = '',
    this.countryName = '',
    this.swiftCode = '',
    this.routingNumber = '',
  });

  final bool hasBankDetails;
  final String accountName;

  /// Always masked by the server; editing means retyping the number.
  final String accountNumberMasked;
  final String bankCode;
  final String bankName;
  final String country;
  final String countryName;
  final String swiftCode;
  final String routingNumber;

  factory BankDetails.fromJson(Map<String, dynamic> j) => BankDetails(
    hasBankDetails: j['has_bank_details'] as bool? ?? false,
    accountName: _str(j['account_name']),
    accountNumberMasked: _str(j['account_number']),
    bankCode: _str(j['bank_code']),
    bankName: _str(j['bank_name']),
    country: _str(j['country']),
    countryName: _str(j['country_name']),
    swiftCode: _str(j['swift_code']),
    routingNumber: _str(j['routing_number']),
  );
}

class Withdrawal {
  Withdrawal({
    required this.id,
    required this.amountLabel,
    required this.status,
    required this.statusLabel,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.countryName,
    required this.countryFlag,
    required this.reference,
    required this.note,
    required this.requestedAt,
  });

  final int id;
  final String amountLabel;

  /// pending, processing, paid or failed.
  final String status;
  final String statusLabel;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String countryName;
  final String countryFlag;
  final String reference;

  /// The admin's reason when a withdrawal failed — the only explanation the
  /// author gets.
  final String note;
  final String requestedAt;

  factory Withdrawal.fromJson(Map<String, dynamic> j) => Withdrawal(
    id: _int(j['id']),
    amountLabel: _str(j['amount_label']),
    status: _str(j['status']),
    statusLabel: _str(j['status_label']),
    bankName: _str(j['bank_name']),
    accountName: _str(j['account_name']),
    accountNumber: _str(j['account_number']),
    countryName: _str(j['country_name']),
    countryFlag: _str(j['country_flag']),
    reference: _str(j['reference']),
    note: _str(j['note']),
    requestedAt: _str(j['requested_at']),
  );
}
