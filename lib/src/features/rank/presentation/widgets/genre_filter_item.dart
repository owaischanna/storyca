import 'package:flutter/material.dart';

class GenreFilterItem extends StatelessWidget {
  const GenreFilterItem({
    super.key,
    required this.selectedGenre,
    required this.item,
    required this.updateGenre,
    required this.setSheetModal,
  });

  final String selectedGenre;
  final String item;
  final void Function(String) updateGenre;
  final void Function(void Function()) setSheetModal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setSheetModal(() {
          updateGenre(item);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: selectedGenre == item
              ? Color.fromRGBO(153, 79, 255, 0.1)
              : Colors.transparent,
          boxShadow: [
            if (selectedGenre == item)
              BoxShadow(
                color: Color.fromRGBO(145, 16, 222, 0.3),
                blurRadius: 10,
              ),
          ],
          border: Border.all(
            width: 1,
            color: selectedGenre == item
                ? Color(0xff994FFF)
                : Color.fromRGBO(175, 145, 231, 0.5),
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          item,
          style: TextStyle(
            color: selectedGenre == item
                ? Colors.white
                : Color.fromRGBO(175, 145, 231, 0.5),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
