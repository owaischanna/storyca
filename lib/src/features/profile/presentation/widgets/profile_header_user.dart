import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/image_url.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';

class ProfileHeaderUser extends StatelessWidget {
  const ProfileHeaderUser({
    super.key,
    required this.image,
    required this.name,
    required this.email,
    required this.identifier,
    required this.joinedSinceLabel,
    required this.followers,
    required this.followings,
    required this.onEdited,
  });

  final String? image;
  final String? name;
  final String email;
  final String identifier;
  final String joinedSinceLabel;
  final int followers;
  final int followings;
  final VoidCallback onEdited;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: AppImage(
                    avatarUrl(image),
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () async {
                      await context.push('/edit-profile');
                      onEdited();
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Color(0xff8343D5)),
                        borderRadius: BorderRadius.circular(30),
                        color: Color(0xff120333),
                      ),
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: ((bounds) {
                            return defaultGradientTTB.createShader(bounds);
                          }),
                          child: Icon(
                            Remix.camera_4_fill,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Row(
                  spacing: 16,
                  children: [
                    Text(
                      (name != null && name!.isNotEmpty) ? name! : email,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await context.push('/edit-profile');
                        onEdited();
                      },
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Color(0xff9110DE),
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Icon(
                          Remix.edit_2_line,
                          color: Color(0xff9110DE),
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (name != null && name!.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(color: Color(0xff9D8AC5), fontSize: 12),
                  ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          width: 1,
                          color: Color.fromRGBO(145, 16, 222, 0.5),
                        ),
                      ),
                      child: Row(
                        spacing: 8,
                        children: [
                          Text(
                            'ID: $identifier',
                            style: TextStyle(
                              color: Color(0xff9D8AC5),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Clipboard.setData(
                                ClipboardData(text: identifier),
                              );
                              AppSnackbar.success(context, 'Copied');
                            },
                            child: Icon(
                              Remix.file_copy_line,
                              color: Color(0xff9D8AC5),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 4,
                  children: [
                    Icon(
                      Remix.calendar_event_line,
                      color: Color(0xff9110DE),
                      size: 12,
                    ),
                    Text(
                      joinedSinceLabel,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Color(0xff9D8AC5), fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  spacing: 16,
                  children: [
                    // FOLLOWERS
                    GestureDetector(
                      onTap: () => context.push('/network/Followers'),
                      child: Row(
                        spacing: 4,
                        children: [
                          Icon(
                            Remix.group_line,
                            color: Color(0xff9110DE),
                            size: 24,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$followers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Followers',
                                style: TextStyle(
                                  color: Color(0xff9D8AC5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 35,
                      width: 1,
                      color: Color.fromRGBO(157, 138, 197, 0.2),
                    ),
                    // FOLLOWING
                    GestureDetector(
                      onTap: () => context.push('/network/Following'),
                      child: Row(
                        spacing: 4,
                        children: [
                          Icon(
                            Remix.user_line,
                            color: Color(0xff9110DE),
                            size: 24,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$followings',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Following',
                                style: TextStyle(
                                  color: Color(0xff9D8AC5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
