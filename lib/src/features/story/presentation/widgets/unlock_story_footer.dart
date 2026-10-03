import 'package:dashed_border/dashed_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';

class UnlockStoryFooter extends StatefulWidget {
  const UnlockStoryFooter({
    super.key,
    required this.price,
    required this.onUnlock,
    this.unlocking = false,
  });

  final num? price;
  final bool unlocking;
  final void Function() onUnlock;

  @override
  State<UnlockStoryFooter> createState() => _UnlockStoryFooterState();
}

class _UnlockStoryFooterState extends State<UnlockStoryFooter> {
  num? _balance;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final token = await authService.getToken();
    if (token == null) return;
    try {
      final wallet = await walletRepository.getWallet(token);
      if (mounted) setState(() => _balance = wallet.balance);
    } on ApiException {
      // Best-effort — the balance row just stays blank.
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: DashedBorder(
              color: Color.fromRGBO(181, 77, 232, 0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Row(
                spacing: 8,
                children: [
                  GestureDetector(
                    onTap: () => context.push('/topup'),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Color.fromRGBO(181, 77, 232, 0.2),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        spacing: 4,
                        children: [
                          Image.asset(aCoinIMG, width: 16),
                          Column(
                            spacing: 2,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Coins', style: defaultTextStyle10),
                              Row(
                                spacing: 4,
                                children: [
                                  Text(
                                    _balance == null
                                        ? '—'
                                        : _balance!.toStringAsFixed(
                                            _balance! % 1 == 0 ? 0 : 1,
                                          ),
                                    style: whiteF16TS,
                                  ),
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        width: 1,
                                        color: Color.fromRGBO(
                                          181,
                                          77,
                                          232,
                                          0.1,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      Remix.add_fill,
                                      color: Color(secondaryCOLR),
                                      size: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.unlocking ? null : widget.onUnlock,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: defaultGradientTTB,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Icon(
                                    Remix.lock_2_line,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    widget.unlocking
                                        ? 'Unlocking…'
                                        : 'Unlock Story',
                                    style: whiteF16TS,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: defaultGradientTTB,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(6),
                                      bottomRight: Radius.circular(6),
                                    ),
                                  ),
                                  child: Row(
                                    spacing: 8,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(aCoinIMG, width: 16),
                                      Text(
                                        widget.price == null
                                            ? '—'
                                            : widget.price!.toStringAsFixed(
                                                widget.price! % 1 == 0 ? 0 : 1,
                                              ),
                                        style: whiteF16TS,
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.unlocking)
                                  Container(
                                    width: 70,
                                    height: 45.4,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(0, 0, 0, 0.15),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Remix.shield_check_line,
                    color: Color(secondaryCOLR),
                    size: 12,
                  ),
                  Text(
                    'Secure payment. Your progress is saved and synced.',
                    style: secondaryF10TS,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
