import 'package:flutter/material.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class Template extends StatefulWidget {
  const Template({super.key});

  @override
  State<Template> createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SingleChildScrollView(
          child: SafeArea(child: Column(spacing: 16, children: [
               
              ],
            )),
        ),
      ),
    );
  }
}
