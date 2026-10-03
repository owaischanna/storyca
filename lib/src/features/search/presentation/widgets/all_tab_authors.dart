import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/widgets/app_image.dart';

class AllTabAuthors extends StatelessWidget {
  const AllTabAuthors({
    super.key,
    required this.id,
    required this.image,
    required this.name,
    required this.stories,
  });

  final int id;
  final String image;
  final String name;
  final int stories;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/author-profile/$id'),
      child: Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.5,
      ),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: Color.fromRGBO(89, 16, 222, 0.5)),
        borderRadius: BorderRadius.circular(10),
        color: Color(0xff0E0319),
      ),
      child: Column(
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(50),
                child: AppImage(image, width: 50, height: 50),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      '$stories Books',
                      style: TextStyle(
                        color: Color(primaryTextCOLR),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: defaultGradientTTB,
            ),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Remix.add_large_line, size: 10, color: Colors.white),
                Text(
                  'Follow',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
