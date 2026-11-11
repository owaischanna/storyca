import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/models/transaction_api_model.dart';
import 'package:storryca/src/features/topup/contents/quick_start_th_items.dart';
import 'package:storryca/src/features/topup/presentation/widgets/date_select_filter_th.dart';
import 'package:storryca/src/features/topup/presentation/widgets/quick_start_th_item.dart';
import 'package:storryca/src/features/topup/presentation/widgets/transaction_item.dart';

/// Maps the server's `kind` to the label + signed-coin display the row
/// widgets already speak, and back for the "Top Up"/"Story Unlock" filter.
String kindLabel(String kind) => switch (kind) {
  'topup' => 'Top Up',
  'purchase' => 'Story Unlock',
  'reward' => 'Reward',
  'bonus' => 'Bonus',
  _ => kind,
};

String? _formattedDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw.isEmpty ? null : raw;
  return DateFormat('MMM d, yyyy').format(parsed);
}

String _priceLabel(TransactionApiModel item) {
  if (item.currency == null || item.amount == null) return '';
  return '${item.currency} ${item.amount}';
}

class HasTransactionHistory extends StatefulWidget {
  const HasTransactionHistory({super.key, required this.transactions});

  final List<TransactionApiModel> transactions;

  @override
  State<HasTransactionHistory> createState() => _HasTransactionHistoryState();
}

class _HasTransactionHistoryState extends State<HasTransactionHistory> {
  List<String> sortBys = ['All Transactions', 'Top Up', 'Story Unlock'];

  late String selectedItem = sortBys.first;

  String selectedQuickStart = '';

  String startDate = '';
  String endDate = '';

  void updateSelectedQuickStart(String date) {
    setState(() {
      selectedQuickStart = date;
    });
  }

  void updateStartDate(String date) {
    setState(() {
      startDate = date;
    });
  }

  void updateEndDate(String date) {
    setState(() {
      endDate = date;
    });
  }

  void clearDate() {
    setState(() {
      startDate = '';
      endDate = '';
    });
  }

  void applyFilter() {
    setState(() {
      context.pop();
    });
  }

  void resetFilter() {
    setState(() {
      startDate = '';
      endDate = '';
      selectedQuickStart = '';
    });
  }

  List<TransactionApiModel> get _filteredTransactions {
    if (selectedItem == 'All Transactions') return widget.transactions;
    return widget.transactions
        .where((t) => kindLabel(t.kind) == selectedItem)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        // SORT & FILTER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopupMenuButton(
                color: Color.fromRGBO(23, 0, 45, 0.99),
                menuPadding: EdgeInsets.all(0),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 0),
                ),
                position: PopupMenuPosition.under,
                onSelected: (value) {
                  setState(() {
                    selectedItem = value;
                  });
                },
                itemBuilder: (context) {
                  return [
                    ...sortBys.map((item) {
                      return PopupMenuItem(
                        height: 40,
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      );
                    }),
                  ];
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Color.fromRGBO(181, 77, 232, 0.3),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    spacing: 4,
                    children: [
                      Text(
                        selectedItem,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Icon(
                        Remix.arrow_down_s_line,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showTransactionFilter(context);
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Color.fromRGBO(181, 77, 232, 0.3),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(Remix.calendar_line, size: 16, color: Colors.white),
                      Text(
                        'Filter by Date',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // FILTER
        if (startDate.isNotEmpty || endDate.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(181, 77, 232, 0.3),
                    border: Border.all(
                      width: 1,
                      color: Color.fromRGBO(181, 77, 232, 0.3),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(
                        Remix.calendar_line,
                        color: Color(secondaryCOLR),
                        size: 16,
                      ),
                      Text(
                        startDate,
                        style: TextStyle(
                          color: Color(primaryTextCOLR),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '-  $endDate',
                        style: TextStyle(
                          color: Color(primaryTextCOLR),
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => clearDate(),
                        child: Icon(
                          Remix.close_large_line,
                          color: Color(secondaryCOLR),
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // TRANSACTION ITEMS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 8,
            children: [
              ..._filteredTransactions.map((item) {
                return TransactionItem(
                  type: kindLabel(item.kind),
                  coin: item.coins,
                  date: _formattedDate(item.createdAt) ?? '',
                  price: _priceLabel(item),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Future<dynamic> showTransactionFilter(BuildContext context) {
    return showModalBottomSheet(
      barrierColor: Color.fromRGBO(255, 255, 255, 0.1),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetModal) {
            return Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff0E0318),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 16,
                  children: [
                    // DRAGGER
                    Container(
                      width: 100,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(195, 132, 255, 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    // DIVIDER
                    Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                    ),

                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter By Date',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Icon(
                            Remix.close_large_line,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),

                    // QUICK SELECT
                    Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Select',
                          style: TextStyle(
                            color: Color(0xffDFBDFF),
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          spacing: 8,
                          children: [
                            ...quickStartTHItems.map((item) {
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setSheetModal(() {
                                      updateSelectedQuickStart(item.label);
                                    });
                                  },
                                  child: QuickStartTHItem(
                                    label: item.label,
                                    icon: item.icon,
                                    isSelected:
                                        item.label == selectedQuickStart,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),

                    // DIVIDER
                    Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                    ),

                    // DATE RANGE
                    Column(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Date Range (Optional)',
                          style: TextStyle(
                            color: Color(0xffDFBDFF),
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          spacing: 16,
                          children: [
                            DateSelectFilterTH(
                              date: startDate,
                              type: 'Start',
                              update: updateStartDate,
                              setSheetModal: setSheetModal,
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Color.fromRGBO(195, 132, 255, 0.3),
                              ),
                            ),
                            DateSelectFilterTH(
                              date: endDate,
                              type: 'End',
                              update: updateEndDate,
                              setSheetModal: setSheetModal,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.information_line,
                              size: 16,
                              color: Color(0xff9110DE),
                            ),
                            Expanded(
                              child: Text(
                                'if only one date is selected, results will be filtered from that date.',
                                style: TextStyle(
                                  color: Color(primaryTextCOLR),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // DIVIDER
                    Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                    ),

                    // ACTIONS
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSheetModal(() {
                                resetFilter();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                  color: Color.fromRGBO(195, 132, 255, 0.5),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Text(
                                    'Reset',
                                    style: TextStyle(
                                      color: Color.fromRGBO(195, 132, 255, 0.5),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => applyFilter(),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: defaultGradientTTB,
                                border: Border.all(
                                  width: 0.5,
                                  color: Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Text(
                                    'Apply',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // SPACING
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
