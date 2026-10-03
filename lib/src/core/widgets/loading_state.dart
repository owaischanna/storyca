import 'package:flutter/material.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: CircularProgressIndicator(color: Color(secondaryCOLR)),
      ),
    );
  }
}
