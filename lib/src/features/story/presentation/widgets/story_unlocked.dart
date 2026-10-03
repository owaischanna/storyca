import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

class StoryUnlocked extends StatefulWidget {
  const StoryUnlocked({super.key, required this.storyId});

  final int storyId;

  @override
  State<StoryUnlocked> createState() => _StoryUnlockedState();
}

class _StoryUnlockedState extends State<StoryUnlocked> {
  bool firstTimeRead = true;
  String selectedChapter = 'Chapter 1';

  /// The chapter to open on "Start Reading"/"Continue Reading" — the reader's
  /// saved progress if there is one, otherwise the book's first chapter.
  /// Resolved from the API rather than assumed, so this never sends every
  /// story to `/read/1`.
  int? _chapterId;

  @override
  void initState() {
    super.initState();
    _resolveChapter();
  }

  Future<void> _resolveChapter() async {
    final token = await authService.getToken();
    if (token != null) {
      try {
        final progress = await libraryRepository.progress(widget.storyId, token);
        if (progress?.chapterId != null) {
          if (mounted) {
            setState(() {
              _chapterId = progress!.chapterId;
              firstTimeRead = false;
            });
          }
          return;
        }
      } on ApiException {
        // Fall through to the book's first chapter below.
      }
    }
    try {
      final chapters = await chaptersRepository.byStoryId(
        widget.storyId,
        token: token,
      );
      if (chapters.isNotEmpty && mounted) {
        setState(() => _chapterId = chapters.first.id);
      }
    } on ApiException {
      // Leave it null — the button then does nothing rather than opening a
      // guessed chapter.
    }
  }

  void _openReader() {
    final chapterId = _chapterId;
    if (chapterId == null) return;
    context.push('/read/$chapterId');
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: firstTimeRead,
      replacement: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Continue Reading', style: whiteF14TS),
              Row(
                spacing: 4,
                children: [
                  Text('From', style: whiteF10TS),
                  PopupMenuButton(
                    color: Color.fromRGBO(23, 0, 45, 0.95),
                    menuPadding: EdgeInsets.all(0),
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 0),
                    ),
                    position: PopupMenuPosition.under,
                    onSelected: (value) {
                      setState(() {
                        selectedChapter = value;
                      });
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          height: 40,
                          value: 'Chapter 1',
                          child: Text(
                            'Chapter 1',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        PopupMenuItem(
                          height: 40,
                          value: 'Chapter 2',
                          child: Text(
                            'Chapter 2',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        PopupMenuItem(
                          height: 40,
                          value: 'Chapter 3',
                          child: Text(
                            'Chapter 3',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        PopupMenuItem(
                          height: 40,
                          value: 'Chapter 4',
                          child: Text(
                            'Chapter 4',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ];
                    },
                    child: Row(
                      children: [
                        Text(selectedChapter, style: secondaryF10TS),
                        Icon(
                          Remix.arrow_down_s_line,
                          size: 10,
                          color: Color(secondaryCOLR),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: SizedBox(
                  height: 5,
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Color(0xff8842FF),
                          Color.fromRGBO(255, 255, 255, 0.5),
                        ],
                      ).createShader(bounds);
                    },
                    child: LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(5),
                      value: 0.1,
                      backgroundColor: Color.fromRGBO(217, 217, 217, 0.1),
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ),
              Text('10%', style: whiteF10TS),
            ],
          ),
          SizedBox(
            height: 35,
            child: GradientButton(
              label: 'Continue Reading',
              hasIcon: true,
              icon: Remix.book_read_line,
              fontSize: 12,
              iconSize: 14,
              radius: 6,
              padding: EdgeInsets.symmetric(vertical: 2),
              onPressed: _openReader,
            ),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Color.fromRGBO(181, 77, 232, 0.1),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          height: 45,
          child: GradientButton(
            label: 'Start Reading',
            padding: EdgeInsets.symmetric(vertical: 2),
            onPressed: _openReader,
          ),
        ),
      ),
    );
  }
}
