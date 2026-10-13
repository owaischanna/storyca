import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

/// A searchable list in a bottom sheet — the bank list alone runs to 700+
/// entries for Nigeria, too many for a plain dropdown. Returns the picked
/// item, or null if dismissed.
Future<T?> showPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> items,
  required String Function(T) label,
  String? selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    barrierColor: const Color.fromRGBO(255, 255, 255, 0.1),
    builder: (_) => _PickerSheet<T>(
      title: title,
      items: items,
      label: label,
      selected: selected,
    ),
  );
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.label,
    this.selected,
  });

  final String title;
  final List<T> items;
  final String Function(T) label;
  final String? selected;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty
        ? widget.items
        : widget.items
              .where((i) => widget.label(i).toLowerCase().contains(q))
              .toList();
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xff0E0318),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          spacing: 12,
          children: [
            Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(195, 132, 255, 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Text(
              widget.title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            TextField(
              autofocus: widget.items.length > 20,
              style: const TextStyle(color: Color(0xFF9D8AC5)),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  color: Color.fromRGBO(157, 138, 197, 0.3),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Remix.search_line,
                  color: Color(0xFF9D8AC5),
                  size: 16,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(145, 16, 222, 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(145, 16, 222, 0.5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: shown.isEmpty
                  ? Center(
                      child: Text(
                        'No matches',
                        style: TextStyle(color: Color(primaryTextCOLR)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: shown.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Color.fromRGBO(195, 132, 255, 0.1),
                      ),
                      itemBuilder: (context, index) {
                        final item = shown[index];
                        final text = widget.label(item);
                        final isSelected = text == widget.selected;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            text,
                            style: TextStyle(
                              color: isSelected
                                  ? Color(secondaryCOLR)
                                  : Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Remix.check_line,
                                  color: Color(secondaryCOLR),
                                  size: 18,
                                )
                              : null,
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
