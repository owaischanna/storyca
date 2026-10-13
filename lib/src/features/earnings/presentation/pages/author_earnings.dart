import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/earnings_api_model.dart';
import 'package:storryca/src/core/network/repositories/earnings_repository.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/branded_refresh_indicator.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';

const Color _cardBorder = Color.fromRGBO(181, 77, 232, 0.3);
const Color _red = Color(0xffC23B3B);

/// Author Earnings: what reads have earned, the bank account withdrawals go
/// to, and withdrawals. Every money figure is a server *_label; the rate per
/// read is never shown (it changes often); withdrawal rules and the window
/// are the server's call, read from `withdrawal.can_withdraw` / `reasons`.
class AuthorEarnings extends StatefulWidget {
  const AuthorEarnings({super.key});

  @override
  State<AuthorEarnings> createState() => _AuthorEarningsState();
}

class _AuthorEarningsState extends State<AuthorEarnings> {
  static const _periods = <(String, String)>[
    ('this_month', 'This month'),
    ('last_month', 'Last month'),
    ('this_year', 'This year'),
    ('last_year', 'Last year'),
    ('all', 'All time'),
    ('custom', 'Custom'),
  ];

  String? _token;
  EarningsPeriod _period = const EarningsPeriod('this_month');
  EarningsDashboard? _dashboard;
  List<StoryEarning>? _stories;
  List<Withdrawal>? _withdrawals;
  BankDetails? _bank;
  String? _error;
  bool _periodLoading = false;

  final _count = NumberFormat.decimalPattern('en');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final token = await authService.getToken();
    if (!mounted) return;
    if (token == null) {
      setState(() => _error = 'Sign in to see your earnings.');
      return;
    }
    _token = token;
    try {
      final results = await Future.wait<dynamic>([
        earningsRepository.dashboard(token, period: _period),
        earningsRepository.stories(token, period: _period),
        earningsRepository.withdrawals(token),
        earningsRepository.bankDetails(token),
      ]);
      if (!mounted) return;
      setState(() {
        _dashboard = results[0] as EarningsDashboard;
        _stories = results[1] as List<StoryEarning>;
        _withdrawals = results[2] as List<Withdrawal>;
        _bank = results[3] as BankDetails;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(
        () => _error = e.isForbidden
            ? 'Author Earnings is for authors. Become an author to earn from '
                  'your stories.'
            : e.message,
      );
    }
  }

  /// A period change only redraws the period summary and per-story list.
  Future<void> _setPeriod(EarningsPeriod period) async {
    final token = _token;
    if (token == null) return;
    setState(() {
      _period = period;
      _periodLoading = true;
    });
    try {
      final results = await Future.wait<dynamic>([
        earningsRepository.dashboard(token, period: period),
        earningsRepository.stories(token, period: period),
      ]);
      if (!mounted || _period != period) return;
      setState(() {
        _dashboard = results[0] as EarningsDashboard;
        _stories = results[1] as List<StoryEarning>;
      });
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _periodLoading = false);
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month),
        end: now,
      ),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xff9110DE),
            secondary: Color(0xff9110DE),
            surface: Color(0xff0E0318),
          ),
          datePickerTheme: const DatePickerThemeData(
            backgroundColor: Color(0xff0E0318),
            headerBackgroundColor: Color(0xff0E0318),
            rangePickerBackgroundColor: Color(0xff0E0318),
            rangePickerHeaderBackgroundColor: Color(0xff0E0318),
            rangeSelectionBackgroundColor: Color.fromRGBO(145, 16, 222, 0.3),
          ),
        ),
        child: child!,
      ),
    );
    if (range == null) return;
    final fmt = DateFormat('yyyy-MM-dd');
    await _setPeriod(
      EarningsPeriod(
        'custom',
        from: fmt.format(range.start),
        to: fmt.format(range.end),
      ),
    );
  }

  Future<void> _openBankDetails() async {
    final saved = await context.push<bool>('/author-earnings/bank');
    if (saved == true) _load();
  }

  Future<void> _withdraw() async {
    final dashboard = _dashboard;
    final token = _token;
    if (dashboard == null || token == null) return;
    final message = await showDialog<String>(
      context: context,
      builder: (_) => _WithdrawDialog(dashboard: dashboard, token: token),
    );
    if (message == null || !mounted) return;
    AppSnackbar.success(context, message);
    // Available and pending both change.
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Remix.arrow_left_s_line),
                      color: Colors.white,
                      iconSize: 24,
                    ),
                    Text(
                      'Author Earnings',
                      style: GoogleFonts.playfair(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _error != null
                    ? ErrorState(message: _error!, onRetry: _load)
                    : _dashboard == null
                    ? const LoadingState()
                    : BrandedRefreshIndicator(
                        onRefresh: _load,
                        // The indicator is already the scroll view — a
                        // nested ListView would get unbounded height.
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _content(_dashboard!),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(EarningsDashboard d) {
    final w = d.withdrawal;
    return [
      if (!d.mayEarn) ...[
        _Notice(
          color: _red,
          icon: Remix.error_warning_line,
          text:
              'Earnings are paused for your country. StorryCa cannot send '
              'money there at the moment, so reads of your stories are not '
              'earning. Your stories, reads and views are unaffected.',
        ),
        const SizedBox(height: 16),
      ] else if (!d.countryChosen || !w.hasBankDetails) ...[
        _Notice(
          color: Color(secondaryCOLR),
          icon: Remix.bank_line,
          text: 'Add your bank details so you can withdraw what you earn.',
          action: 'Add bank details',
          onAction: _openBankDetails,
        ),
        const SizedBox(height: 16),
      ],

      // HEADLINE
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: const Color(0xffB54DE8)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            const Text(
              'Available for Withdrawal',
              style: TextStyle(color: Color(0xff9D8AC5), fontSize: 16),
            ),
            Text(
              d.availableLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Opacity(
              opacity: w.canWithdraw ? 1 : 0.4,
              child: SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: 'Withdraw',
                  hasIcon: true,
                  icon: Remix.bank_card_line,
                  onPressed: w.canWithdraw ? _withdraw : () {},
                ),
              ),
            ),
            if (!w.canWithdraw)
              ...w.reasons.map(
                (r) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Icon(
                      Remix.information_line,
                      size: 14,
                      color: Color(primaryTextCOLR),
                    ),
                    Expanded(child: Text(r, style: defaultTextStyle)),
                  ],
                ),
              ),
            if (w.arrival.isNotEmpty)
              Text(
                'Payments arrive in about ${w.arrival} after they are processed.',
                style: defaultTextStyle10,
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // MONEY
      _Grid(
        children: [
          _Stat(label: 'Current Balance', value: d.balanceLabel),
          _Stat(label: 'Total Earnings', value: d.totalEarningsLabel),
          _Stat(label: 'Pending Payments', value: d.pendingLabel),
          _Stat(label: 'Total Withdrawals', value: d.withdrawnLabel),
        ],
      ),
      const SizedBox(height: 12),

      // READS — total_reads is the public figure (much of it predates
      // earnings and pays nothing); paid_reads is what actually earned.
      _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text('Total Reads', style: defaultTextStyle),
            Text(
              _count.format(d.totalReads),
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
            Text(
              '${_count.format(d.paidReads)} of them earned, across '
              '${_count.format(d.stories)} '
              '${d.stories == 1 ? 'story' : 'stories'}',
              style: defaultTextStyle10,
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _Grid(
        children: [
          _Stat(label: 'Total Views', value: _count.format(d.totalViews)),
          _Stat(
            label: "This Month's Reads",
            value: _count.format(d.thisMonth.reads),
          ),
          _Stat(
            label: "This Month's Earnings",
            value: d.thisMonth.earningsLabel,
          ),
          _Stat(
            label: "This Year's Reads",
            value: _count.format(d.thisYear.reads),
          ),
          _Stat(label: "This Year's Earnings", value: d.thisYear.earningsLabel),
        ],
      ),
      const SizedBox(height: 24),

      // PERIOD + PER STORY
      _SectionTitle('Earnings by Story'),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: _periods.map((p) {
            final selected = _period.key == p.$1;
            return GestureDetector(
              onTap: () => p.$1 == 'custom'
                  ? _pickCustomRange()
                  : _setPeriod(EarningsPeriod(p.$1)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: selected ? defaultGradientTTB : null,
                  color: selected
                      ? null
                      : const Color.fromRGBO(255, 255, 255, 0.05),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  p.$2,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 12),
      if (_periodLoading)
        const LoadingState(height: 120)
      else ...[
        _Card(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      d.period.label,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    if (d.period.from.isNotEmpty || d.period.to.isNotEmpty)
                      Text(
                        '${d.period.from} – ${d.period.to}',
                        style: defaultTextStyle10,
                      ),
                    Text(
                      '${_count.format(d.period.reads)} paid '
                      '${d.period.reads == 1 ? 'read' : 'reads'}',
                      style: defaultTextStyle,
                    ),
                  ],
                ),
              ),
              Text(
                d.period.earningsLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if ((_stories ?? const []).isEmpty)
          _Empty('No earnings from your stories in this period yet.')
        else
          ..._stories!.map(
            (s) => _StoryRow(story: s, symbol: d.currencySymbol),
          ),
      ],
      const SizedBox(height: 24),

      // BANK
      _SectionTitle('Bank Details'),
      const SizedBox(height: 12),
      _BankCard(bank: _bank, onEdit: _openBankDetails),
      const SizedBox(height: 24),

      // HISTORY
      _SectionTitle('Withdrawal History'),
      const SizedBox(height: 12),
      if ((_withdrawals ?? const []).isEmpty)
        _Empty('No withdrawals yet.')
      else
        ..._withdrawals!.map((w) => _WithdrawalRow(withdrawal: w)),
    ];
  }
}

class _WithdrawDialog extends StatefulWidget {
  const _WithdrawDialog({required this.dashboard, required this.token});

  final EarningsDashboard dashboard;
  final String token;

  @override
  State<_WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<_WithdrawDialog> {
  final _amount = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final amount = num.tryParse(_amount.text.replaceAll(',', '').trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter the amount to withdraw.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final message = await earningsRepository.withdraw(amount, widget.token);
      if (mounted) Navigator.pop(context, message);
    } on ApiException catch (e) {
      // The server says exactly why (window shut, below minimum, more than
      // available, no bank details).
      if (mounted) {
        setState(() {
          _sending = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dashboard;
    return AlertDialog(
      backgroundColor: const Color(0xff0E0318),
      title: const Text('Withdraw', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            'Available: ${d.availableLabel}\n'
            'Minimum: ${d.withdrawal.minimumLabel}',
            style: TextStyle(color: Color(primaryTextCOLR), fontSize: 13),
          ),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixText: '${d.currencySymbol} ',
              prefixStyle: const TextStyle(color: Colors.white),
              hintText: 'Amount',
              hintStyle: const TextStyle(
                color: Color.fromRGBO(157, 138, 197, 0.3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(145, 16, 222, 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xff9110DE)),
              ),
            ),
          ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: _red, fontSize: 13)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xff9D8AC5)),
          ),
        ),
        TextButton(
          onPressed: _sending ? null : _send,
          child: Text(
            _sending ? 'Sending…' : 'Withdraw',
            style: const TextStyle(color: Color(0xffB54DE8)),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: _cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children
              .map((c) => SizedBox(width: width, child: c))
              .toList(),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(label, style: defaultTextStyle10),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.playfair(color: Colors.white, fontSize: 18),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Text(text, style: defaultTextStyle, textAlign: TextAlign.center),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.color,
    required this.icon,
    required this.text,
    this.action,
    this.onAction,
  });

  final Color color;
  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(width: 1, color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Icon(icon, color: color, size: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                if (action != null)
                  GestureDetector(
                    onTap: onAction,
                    child: Text(
                      action!,
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryRow extends StatelessWidget {
  const _StoryRow({required this.story, required this.symbol});

  final StoryEarning story;
  final String symbol;

  // The per-story endpoint sends a bare naira amount with no label.
  static final _money = NumberFormat('#,##0.00', 'en');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => context.push('/story/${story.storyId}'),
        child: _Card(
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfair(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${NumberFormat.decimalPattern('en').format(story.reads)} '
                      'paid ${story.reads == 1 ? 'read' : 'reads'}',
                      style: defaultTextStyle10,
                    ),
                  ],
                ),
              ),
              Text(
                '$symbol${_money.format(story.amount)}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  const _BankCard({required this.bank, required this.onEdit});

  final BankDetails? bank;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final b = bank;
    if (b == null || !b.hasBankDetails) {
      return _Card(
        child: Column(
          spacing: 12,
          children: [
            Text(
              'No bank account added yet.',
              style: defaultTextStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                label: 'Add Bank Details',
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: onEdit,
              ),
            ),
          ],
        ),
      );
    }
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  b.bankName,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(b.accountName, style: defaultTextStyle),
                Text(b.accountNumberMasked, style: defaultTextStyle),
                Text(b.countryName, style: defaultTextStyle10),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Row(
              spacing: 4,
              children: [
                Icon(Remix.edit_line, size: 14, color: Color(secondaryCOLR)),
                Text(
                  'Edit',
                  style: TextStyle(color: Color(secondaryCOLR), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawalRow extends StatelessWidget {
  const _WithdrawalRow({required this.withdrawal});

  final Withdrawal withdrawal;

  Color get _statusColor => switch (withdrawal.status) {
    'paid' => const Color(0xff00B076),
    'processing' => const Color(0xff4D9DE8),
    'failed' => _red,
    _ => const Color(0xffF8B231),
  };

  @override
  Widget build(BuildContext context) {
    final w = withdrawal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    w.amountLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    border: Border.all(width: 0.5, color: _statusColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    w.statusLabel,
                    style: TextStyle(color: _statusColor, fontSize: 11),
                  ),
                ),
              ],
            ),
            Text('${w.bankName} · ${w.accountNumber}', style: defaultTextStyle),
            Text(
              '${w.countryFlag} ${w.countryName}'.trim(),
              style: defaultTextStyle10,
            ),
            Text('Requested ${w.requestedAt}', style: defaultTextStyle10),
            if (w.status == 'failed' && w.note.isNotEmpty)
              Text(w.note, style: const TextStyle(color: _red, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
