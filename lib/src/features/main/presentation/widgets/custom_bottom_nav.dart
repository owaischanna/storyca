import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/features/main/contents/navbar.content.dart';

class CustomBottomNav extends StatelessWidget {
  final int pageIndex;
  final void Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.pageIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 1.0),
        child: BottomAppBar(
          color: Color.fromRGBO(225, 225, 225, 0.05),
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          shadowColor: Colors.transparent,
          notchMargin: 16.0,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...List.generate(navbarItems.length, (index) {
                  if (index == 2) return SizedBox(width: 50);

                  return NavItem(
                    pageIndex: pageIndex,
                    index: index,
                    label: navbarItems[index].label,
                    icon: navbarItems[index].icon,
                    onTap: onTap,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.pageIndex,
    required this.index,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final int pageIndex;
  final int index;
  final String label;
  final IconData icon;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        spacing: 4,
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              if (pageIndex == index) {
                return defaultGradientLTR.createShader(bounds);
              } else {
                return whiteGradientCOLR.createShader(bounds);
              }
            },
            child: Icon(icon, color: Colors.white),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              if (pageIndex == index) {
                return defaultGradientLTR.createShader(bounds);
              } else {
                return whiteGradientCOLR.createShader(bounds);
              }
            },
            child: Text(label, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
