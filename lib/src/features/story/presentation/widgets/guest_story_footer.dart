import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

/// The book page's bottom bar for someone not signed in: the "Under Popular"
/// badge and Sign In / Sign Up, as on the website.
class GuestStoryFooter extends StatelessWidget {
  const GuestStoryFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF14081F),
            border: Border.all(
              width: 1,
              color: const Color.fromRGBO(181, 77, 232, 0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            spacing: 12,
            children: [
              const Expanded(child: _PopularBadge()),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/signin'),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: defaultGradientTTB,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Icon(Remix.user_add_line, size: 18, color: Colors.white),
                        Flexible(
                          child: Text(
                            'Sign In / Sign Up',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularBadge extends StatelessWidget {
  const _PopularBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CustomPaint(size: Size(16, 40), painter: _Laurel(left: true)),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('🔥', style: TextStyle(fontSize: 18)),
              Text(
                'Under Popular',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        const CustomPaint(size: Size(16, 40), painter: _Laurel(left: false)),
      ],
    );
  }
}

/// A small laurel branch curving up beside the badge.
class _Laurel extends CustomPainter {
  const _Laurel({required this.left});

  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    if (!left) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final paint = Paint()
      ..color = const Color(0xFFBDB6C8)
      ..style = PaintingStyle.fill;
    final stem = Paint()
      ..color = const Color(0xFFBDB6C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Stem: from the bottom inner corner, bowing out and up.
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.9, h)
      ..quadraticBezierTo(0, h * 0.75, w * 0.45, 0);
    canvas.drawPath(path, stem);

    // Leaves along the stem, pointing outward and up.
    for (var i = 0; i < 5; i++) {
      final t = 0.12 + i * 0.19;
      final metric = path.computeMetrics().first;
      final pos = metric.getTangentForOffset(metric.length * t)!;
      canvas.save();
      canvas.translate(pos.position.dx, pos.position.dy);
      canvas.rotate(pos.angle - math.pi / 4);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-3, 0), width: 7, height: 3.2),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _Laurel oldDelegate) => oldDelegate.left != left;
}
