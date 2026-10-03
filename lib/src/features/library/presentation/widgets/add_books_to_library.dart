import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

class AddBooksToLibrary extends StatelessWidget {
  const AddBooksToLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/main/2'),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromRGBO(195, 132, 255, 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Icon(
              Remix.add_large_line,
              color: Color.fromRGBO(136, 66, 255, 0.5),
              size: 24,
            ),
            Text(
              'Add Books',
              style: TextStyle(
                color: Color.fromRGBO(136, 66, 255, 0.5),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
