import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

/// Pull-to-refresh wrapper using the app's branded glowing purple book icon
/// instead of the default Material spinner.
class BrandedRefreshIndicator extends StatelessWidget {
  const BrandedRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
          builder:
              (
                context,
                refreshState,
                pulledExtent,
                refreshTriggerPullDistance,
                refreshIndicatorExtent,
              ) {
                final progress = (pulledExtent / refreshTriggerPullDistance)
                    .clamp(0.0, 1.0);
                final spinning =
                    refreshState == RefreshIndicatorMode.refresh ||
                    refreshState == RefreshIndicatorMode.armed;
                return Center(
                  child: Opacity(
                    opacity: progress,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: defaultGradientTTB,
                        boxShadow: [
                          BoxShadow(
                            color: Color(secondaryCOLR).withValues(alpha: 0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: spinning
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Remix.book_open_fill,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                );
              },
        ),
        SliverToBoxAdapter(child: child),
      ],
    );
  }
}
