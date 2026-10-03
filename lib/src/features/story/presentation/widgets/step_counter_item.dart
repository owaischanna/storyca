import 'package:flutter/material.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';

class StepCounterItem extends StatelessWidget {
  const StepCounterItem({super.key, required this.step, required this.label, required this.isActive});

  final int step;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            gradient: isActive ? defaultGradientTTB : null,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 1,
              color: isActive
                  ? Colors.transparent
                  : Color.fromRGBO(157, 138, 187, 0.2),
            ),
          ),
          child: Center(child: Text(step.toString(), style: whiteF12TS)),
        ),
        if (isActive)
          ShaderMask(
            shaderCallback: (bounds) {
              return defaultGradientLTR.createShader(bounds);
            },
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        if (!isActive)
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
