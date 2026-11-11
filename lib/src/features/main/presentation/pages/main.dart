import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/widgets/age_question.dart';
import 'package:storryca/src/features/discover/presentation/pages/discover.dart';
import 'package:storryca/src/features/home/presentation/pages/home.dart';
import 'package:storryca/src/features/library/presentation/pages/library.dart';
import 'package:storryca/src/features/main/presentation/widgets/custom_bottom_nav.dart';
import 'package:storryca/src/features/profile/presentation/pages/profile.dart';
import 'package:storryca/src/features/rank/presentation/pages/rank.dart';

class Main extends StatefulWidget {
  const Main({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  late int _pageIndex;

  // Building all five tabs up front would fire every tab's initial network
  // calls at once on cold start, even for tabs the user hasn't opened yet —
  // competing for bandwidth with the one tab actually on screen. Instead,
  // each tab is only constructed the first time it's selected, and then kept
  // alive (so switching back preserves its state, same as before).
  late final Set<int> _builtIndices = {_pageIndex};

  static const List<Widget Function()> _pageBuilders = [
    Home.new,
    Library.new,
    Discover.new,
    Rank.new,
    Profile.new,
  ];

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialIndex;
    // Bookmarks on cards and "Add to Library" menus paint from this.
    authService.getToken().then(libraryRepository.ensureSavedIds);
    _checkAge();
  }

  /// Bumped when the reader confirms they're 18+, so the tabs reload with
  /// the 18+ books the server was hiding until then.
  int _contentEpoch = 0;

  /// Asks a signed-in reader the one-time age question (sign-in can land
  /// here on an existing shell, so this also runs on widget updates — it
  /// only reaches the server until the answer is known).
  void _checkAge() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final becameAdult = await askAgeIfNeeded(context);
      if (becameAdult && mounted) setState(() => _contentEpoch++);
    });
  }

  @override
  void didUpdateWidget(covariant Main oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAge();
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _pageIndex = widget.initialIndex;
        _builtIndices.add(_pageIndex);
      });
    }
  }

  void changeTab(int index) {
    setState(() {
      _pageIndex = index;
      _builtIndices.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: IndexedStack(
        index: _pageIndex,
        children: [
          for (var i = 0; i < _pageBuilders.length; i++)
            _builtIndices.contains(i)
                ? KeyedSubtree(
                    key: ValueKey('$i-$_contentEpoch'),
                    child: _pageBuilders[i](),
                  )
                : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        pageIndex: _pageIndex,
        onTap: changeTab,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: _pageIndex == 2 ? defaultGradientLTR : null,
          color: _pageIndex == 2
              ? Colors.white
              : Color.fromRGBO(255, 255, 255, 0.1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: RawMaterialButton(
          shape: CircleBorder(),
          onPressed: () => changeTab(2),
          elevation: 0,
          child: Icon(Remix.book_open_fill, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}
