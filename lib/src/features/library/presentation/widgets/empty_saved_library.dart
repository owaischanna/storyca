import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storryca/src/core/constants/images.const.dart';

class EmptySavedLibrary extends StatelessWidget {
  const EmptySavedLibrary({super.key, this.isLoggedIn = true});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .5,
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(emptySavedLibraryIMG, width: 100, height: 100),
          Column(
            spacing: 8,
            children: [
              Text(
                'Save books to build your collection',
                style: GoogleFonts.playfair(color: Colors.white, fontSize: 24),
              ),
              Text(
                'Bookmark the books you want to come back to later.',
                style: TextStyle(
                  color: Color.fromRGBO(195, 132, 255, 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              if (isLoggedIn) {
                context.push('/main/2');
              } else {
                context.push('/signin');
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Color.fromRGBO(195, 132, 255, 0.2),
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                isLoggedIn ? 'Browse Books' : 'Log In / Register',
                style: TextStyle(
                  color: Color.fromRGBO(233, 210, 255, 0.7),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
