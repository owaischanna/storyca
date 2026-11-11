import 'package:dashed_border/dashed_border.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/models/story_api_model.dart';
import 'package:storryca/src/core/utils/trailer_file.dart';
import 'package:storryca/src/core/widgets/border_gradient_button.dart';

/// The optional "Novel Trailer" field on the Cover step: empty, a newly
/// picked file, or (when editing) the trailer the novel already has.
class TrailerPicker extends StatelessWidget {
  const TrailerPicker({
    super.key,
    required this.picked,
    required this.existing,
    required this.error,
    required this.checking,
    required this.onPick,
    required this.onClear,
  });

  /// A new file, waiting to be uploaded on save.
  final PickedTrailer? picked;

  /// The trailer already on the server — shown when nothing new is picked.
  final StoryTrailer? existing;

  /// Why the last picked file was refused, shown under the field.
  final String? error;
  final bool checking;
  final VoidCallback onPick;
  final VoidCallback onClear;

  static const _rules =
      '16:9 landscape (e.g. 1920 x 1080) • MP4 or WebM • Max size: 50MB';

  @override
  Widget build(BuildContext context) {
    final hasTrailer = picked != null || existing != null;
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: 'Novel Trailer', style: whiteF12TS),
                  TextSpan(
                    text: ' (optional)',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            Text(
              'A short video readers see on your novel page.',
              style: TextStyle(color: Colors.white70, fontSize: 8),
            ),
          ],
        ),
        hasTrailer ? _selected() : _empty(),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Color(0xFFC23B3B), fontSize: 10),
          ),
        Text(_rules, style: TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _empty() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: DashedBorder(
          dashGap: 2,
          dashLength: 2,
          color: Color(0xff9110DE),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        spacing: 12,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                defaultGradientTTB.createShader(bounds),
            child: Icon(Remix.film_line, size: 32, color: Colors.white),
          ),
          Text(
            'Upload a trailer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            width: 120,
            height: 40,
            child: BorderGradientButton(
              label: checking ? 'Checking…' : 'Browse Files',
              padding: EdgeInsets.all(0),
              radius: 6,
              onPressed: checking ? () {} : onPick,
            ),
          ),
        ],
      ),
    );
  }

  Widget _selected() {
    final file = picked;
    final title = file != null ? 'New trailer' : 'Current trailer';
    final details = file != null
        ? [
            if (file.width > 0) '${file.width} x ${file.height}',
            file.sizeLabel,
          ].join(' • ')
        : existing!.durationLabel;
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: DashedBorder(
          dashGap: 2,
          dashLength: 2,
          color: Color(0xFF9110DE),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        spacing: 12,
        children: [
          Row(
            spacing: 8,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(145, 16, 222, 0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      defaultGradientTTB.createShader(bounds),
                  child: Icon(Remix.film_line, color: Colors.white, size: 20),
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: whiteF12TS,
                    ),
                    if (details.isNotEmpty)
                      Text(details, style: defaultTextStyle10),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color.fromRGBO(194, 59, 59, 0.1),
                  ),
                  child: Center(
                    child: Icon(
                      Remix.delete_bin_5_line,
                      color: Color(0xFFC23B3B),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 150,
            height: 40,
            child: BorderGradientButton(
              label: checking ? 'Checking…' : 'Change Trailer',
              hasIcon: true,
              icon: Remix.pencil_line,
              radius: 6,
              padding: EdgeInsets.all(0),
              onPressed: checking ? () {} : onPick,
            ),
          ),
        ],
      ),
    );
  }
}
