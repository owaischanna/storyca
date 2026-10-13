import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/earnings_api_model.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/earnings/presentation/widgets/picker_sheet.dart';

/// Where withdrawals are paid. The country comes first: it decides the form
/// (a bank picked from a list, or a typed bank with SWIFT/IBAN or a US
/// routing number) and whether the author earns at all. Pops `true` once
/// saved so the earnings screen reloads.
class BankDetailsPage extends StatefulWidget {
  const BankDetailsPage({super.key});

  @override
  State<BankDetailsPage> createState() => _BankDetailsPageState();
}

class _BankDetailsPageState extends State<BankDetailsPage> {
  String? _token;
  List<PayoutCountry>? _countries;
  BankDetails? _saved;
  String? _loadError;

  PayoutCountry? _country;
  BankList? _bankList;
  bool _loadingBanks = false;
  String? _banksError;
  BankOption? _bank;

  final _accountNumber = TextEditingController();
  final _accountName = TextEditingController();
  final _bankName = TextEditingController();
  final _swift = TextEditingController();
  final _routing = TextEditingController();

  Timer? _resolveDebounce;
  bool _resolving = false;
  String? _resolveNote;

  bool _saving = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _resolveDebounce?.cancel();
    _accountNumber.dispose();
    _accountName.dispose();
    _bankName.dispose();
    _swift.dispose();
    _routing.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadError = null);
    final token = await authService.getToken();
    if (!mounted) return;
    if (token == null) {
      setState(() => _loadError = 'Sign in to manage your bank details.');
      return;
    }
    _token = token;
    try {
      final results = await Future.wait<dynamic>([
        earningsRepository.countries(token),
        earningsRepository.bankDetails(token),
      ]);
      if (!mounted) return;
      final countries = results[0] as List<PayoutCountry>;
      final saved = results[1] as BankDetails;
      setState(() {
        _countries = countries;
        _saved = saved;
      });
      if (saved.hasBankDetails) {
        _accountName.text = saved.accountName;
        _bankName.text = saved.bankName;
        _swift.text = saved.swiftCode;
        _routing.text = saved.routingNumber;
        final match = countries.where((c) => c.code == saved.country);
        if (match.isNotEmpty) await _selectCountry(match.first, keepBank: true);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _loadError = e.message);
    }
  }

  Future<void> _pickCountry() async {
    final countries = _countries;
    if (countries == null) return;
    final picked = await showPickerSheet<PayoutCountry>(
      context,
      title: 'Country of your bank account',
      items: countries,
      label: (c) => c.name,
      selected: _country?.name,
    );
    if (picked != null && picked.code != _country?.code) {
      await _selectCountry(picked);
    }
  }

  Future<void> _selectCountry(
    PayoutCountry country, {
    bool keepBank = false,
  }) async {
    final token = _token;
    if (token == null) return;
    setState(() {
      _country = country;
      _bankList = null;
      _banksError = null;
      _loadingBanks = true;
      _formError = null;
      _resolveNote = null;
      if (!keepBank) {
        _bank = null;
        _bankName.clear();
        _swift.clear();
        _routing.clear();
      }
    });
    try {
      final list = await earningsRepository.banks(country.code, token);
      if (!mounted || _country?.code != country.code) return;
      setState(() {
        _bankList = list;
        _loadingBanks = false;
        if (keepBank && list.hasBankList) {
          final code = _saved?.bankCode ?? '';
          final match = list.banks.where((b) => b.code == code);
          _bank = match.isEmpty ? null : match.first;
        }
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loadingBanks = false;
          _banksError = e.message;
        });
      }
    }
  }

  Future<void> _pickBank() async {
    final banks = _bankList?.banks;
    if (banks == null || banks.isEmpty) return;
    final picked = await showPickerSheet<BankOption>(
      context,
      title: 'Choose your bank',
      items: banks,
      label: (b) => b.name,
      selected: _bank?.name,
    );
    if (picked != null) {
      setState(() => _bank = picked);
      _scheduleResolve();
    }
  }

  /// Once both the bank and the account number are in, look up the real
  /// account name — it catches a mistyped digit before any money moves.
  void _scheduleResolve() {
    _resolveDebounce?.cancel();
    if (!(_bankList?.hasBankList ?? false)) return;
    if (_bank == null || _accountNumber.text.trim().length < 6) return;
    _resolveDebounce = Timer(const Duration(milliseconds: 700), _resolve);
  }

  Future<void> _resolve() async {
    final token = _token;
    final bank = _bank;
    final number = _accountNumber.text.trim();
    if (token == null || bank == null || number.isEmpty) return;
    setState(() {
      _resolving = true;
      _resolveNote = null;
    });
    try {
      final name = await earningsRepository.resolveAccountName(
        accountNumber: number,
        bankCode: bank.code,
        token: token,
      );
      if (!mounted) return;
      setState(() {
        _resolving = false;
        if (name.isNotEmpty) {
          _accountName.text = name;
          _resolveNote = 'Name confirmed with your bank.';
        }
      });
    } on ApiException {
      // Never blocks saving — an admin checks the account before paying.
      if (mounted) {
        setState(() {
          _resolving = false;
          _resolveNote =
              'We couldn\'t confirm the name automatically. Type it exactly '
              'as it appears at your bank.';
        });
      }
    }
  }

  Future<void> _save() async {
    final token = _token;
    final country = _country;
    final list = _bankList;
    if (token == null || country == null || list == null || _saving) return;
    final fields = <String, String>{
      if (list.hasBankList) ...{
        'bank_code': _bank?.code ?? '',
        'bank_name': _bank?.name ?? '',
      } else
        'bank_name': _bankName.text.trim(),
      if (list.needs == 'swift_code') 'swift_code': _swift.text.trim(),
      if (list.needs == 'routing_number')
        'routing_number': _routing.text.trim(),
    };
    setState(() {
      _saving = true;
      _formError = null;
    });
    try {
      final message = await earningsRepository.saveBankDetails(
        country: country.code,
        accountName: _accountName.text.trim(),
        accountNumber: _accountNumber.text.trim(),
        fields: fields,
        token: token,
      );
      if (!mounted) return;
      AppSnackbar.success(context, message);
      context.pop(true);
    } on ApiException catch (e) {
      // 422s are written for the author ("no bank chosen", "routing number
      // must be 9 digits"…) — shown as sent.
      if (mounted) setState(() => _formError = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
              _Header(title: 'Bank Details', onBack: () => context.pop()),
              Expanded(
                child: _loadError != null
                    ? ErrorState(message: _loadError!, onRetry: _load)
                    : _countries == null
                    ? const LoadingState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                        child: _form(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form() {
    final list = _bankList;
    final saved = _saved;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          'Withdrawals are paid into this account. Choose the country your '
          'bank account is in first.',
          style: TextStyle(color: Color(primaryTextCOLR), fontSize: 12),
        ),
        _Labelled(
          label: 'Country',
          child: _PickerField(
            text: _country?.name,
            placeholder: 'Select country',
            icon: Remix.global_line,
            onTap: _pickCountry,
          ),
        ),
        if (_loadingBanks)
          const LoadingState(height: 120)
        else if (_banksError != null)
          Text(_banksError!, style: const TextStyle(color: Color(0xffC23B3B)))
        else if (list != null) ...[
          if (list.hasBankList)
            _Labelled(
              label: 'Bank',
              child: _PickerField(
                text: _bank?.name,
                placeholder: 'Select your bank',
                icon: Remix.bank_line,
                onTap: _pickBank,
              ),
            )
          else
            _Labelled(
              label: 'Bank name',
              child: _field(_bankName, 'e.g. NatWest'),
            ),
          _Labelled(
            label: list.needs == 'swift_code'
                ? 'Account number or IBAN'
                : 'Account number',
            hint:
                (saved?.hasBankDetails ?? false) &&
                    saved!.accountNumberMasked.isNotEmpty
                ? 'Saved: ${saved.accountNumberMasked} — retype it to save changes.'
                : null,
            child: _field(
              _accountNumber,
              list.needs == 'swift_code'
                  ? 'Account number or IBAN'
                  : 'Account number',
              keyboard: list.needs == 'swift_code'
                  ? TextInputType.text
                  : TextInputType.number,
              onChange: (_) => _scheduleResolve(),
            ),
          ),
          _Labelled(
            label: 'Account name',
            hint: _resolving
                ? 'Checking the name with your bank…'
                : _resolveNote,
            child: _field(_accountName, 'Name on the account'),
          ),
          if (list.needs == 'swift_code')
            _Labelled(
              label: 'SWIFT / BIC',
              child: _field(_swift, '8 to 11 characters'),
            ),
          if (list.needs == 'routing_number')
            _Labelled(
              label: 'Routing number',
              child: _field(
                _routing,
                '9 digits',
                keyboard: TextInputType.number,
              ),
            ),
          if (_formError != null)
            Text(
              _formError!,
              style: const TextStyle(color: Color(0xffC23B3B), fontSize: 13),
            ),
          GradientButton(
            label: _saving ? 'Saving…' : 'Save Bank Details',
            onPressed: _save,
          ),
        ],
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String placeholder, {
    TextInputType keyboard = TextInputType.text,
    void Function(String)? onChange,
  }) {
    return CustomTextField(
      controller: controller,
      placeholder: placeholder,
      hideText: false,
      hasPrefixIcon: false,
      hasSuffixIcon: false,
      keyboardType: keyboard,
      onSubmitted: () {},
      suffixAction: () {},
      onChange: onChange ?? (_) {},
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Remix.arrow_left_s_line),
            color: Colors.white,
            iconSize: 24,
          ),
          Text(
            title,
            style: GoogleFonts.playfair(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child, this.hint});

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        child,
        if (hint != null)
          Text(
            hint!,
            style: TextStyle(color: Color(primaryTextCOLR), fontSize: 11),
          ),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.text,
    required this.placeholder,
    required this.icon,
    required this.onTap,
  });

  final String? text;
  final String placeholder;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromRGBO(145, 16, 222, 0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          spacing: 8,
          children: [
            Icon(icon, color: const Color(0xFF9D8AC5), size: 16),
            Expanded(
              child: Text(
                text ?? placeholder,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: text == null
                      ? const Color.fromRGBO(157, 138, 197, 0.3)
                      : const Color(0xFF9D8AC5),
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Remix.arrow_down_s_line,
              color: Color(0xff994FFF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
