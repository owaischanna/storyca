import 'package:flutter/material.dart';

class RankingCriteriaItem extends StatelessWidget {
  const RankingCriteriaItem({
    super.key,
    required this.selectedRanking,
    required this.setSheetModal,
    required this.updateRanking,
    required this.label,
    required this.icon,
    required this.isLast,
  });

  final String selectedRanking;
  final void Function(void Function()) setSheetModal;
  final void Function(String) updateRanking;
  final String label;
  final IconData icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: isLast
                ? Colors.transparent
                : Color.fromRGBO(195, 132, 255, 0.1),
          ),
        ),
      ),
      child: RadioGroup(
        groupValue: selectedRanking,
        onChanged: (value) {
          setSheetModal(() {
            updateRanking(value ?? '');
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    radioTheme: RadioThemeData(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  child: Transform.scale(
                    scale: 0.8,
                    child: Radio<String>(
                      value: label,
                      fillColor: WidgetStateProperty.resolveWith<Color?>((
                        states,
                      ) {
                        if (selectedRanking == label) {
                          return Color(0xff994FFF);
                        } else {
                          return Color.fromRGBO(195, 132, 255, 0.5);
                        }
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    setSheetModal(() {
                      updateRanking(label);
                    });
                  },
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedRanking == label
                          ? Color(0xffE1CCFF)
                          : Color.fromRGBO(225, 204, 225, 0.5),
                    ),
                  ),
                ),
              ],
            ),
            Icon(icon, size: 12, color: Color(0xff994FFF)),
          ],
        ),
      ),
    );
  }
}
