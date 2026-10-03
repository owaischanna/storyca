import 'package:flutter/material.dart';
import 'package:storryca/src/features/rank/types/sort_order_types.dart';

class SortOrderItem extends StatelessWidget {
  const SortOrderItem({
    super.key,
    required this.setSheetModal,
    required this.updateSortOrder,
    required this.selectedSortOrder,
    required this.item,
  });

  final void Function(void Function()) setSheetModal;
  final void Function(String) updateSortOrder;
  final String selectedSortOrder;
  final SortOrderTypes item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setSheetModal(() {
          updateSortOrder(item.label);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: selectedSortOrder == item.label
              ? Color.fromRGBO(153, 79, 255, 0.1)
              : Colors.transparent,
          boxShadow: [
            if (selectedSortOrder == item.label)
              BoxShadow(
                color: Color.fromRGBO(145, 16, 222, 0.3),
                blurRadius: 10,
              ),
          ],
          border: Border.all(
            width: 1,
            color: selectedSortOrder == item.label
                ? Color(0xff994FFF)
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            spacing: 2,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: selectedSortOrder == item.label
                    ? Colors.white
                    : Color(0xffAF91E7),
                size: 12,
              ),
              Text(
                item.label,
                style: TextStyle(
                  color: selectedSortOrder == item.label
                      ? Colors.white
                      : Color(0xffAF91E7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
