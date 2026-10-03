import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/image_url.dart';
import 'package:storryca/src/core/network/models/follow_api_model.dart';
import 'package:storryca/src/core/widgets/app_image.dart';

class NetworkUserItem extends StatelessWidget {
  const NetworkUserItem({
    super.key,
    required this.user,
    required this.id,
    required this.image,
    required this.name,
    required this.caption,
    required this.isAuthor,
    required this.followers,
    required this.isFollowing,
    required this.isSelf,
    required this.isUpdating,
    required this.onToggleFollow,
  });

  /// Passed through to the reader's profile screen since there's no public
  /// endpoint yet to fetch a non-author's profile by id — the fields already
  /// present on this row are all we can honestly show there.
  final FollowUserApiModel user;
  final int id;
  final String? image;
  final String name;
  final String caption;
  final bool isAuthor;
  final int followers;
  final bool isFollowing;
  final bool isSelf;
  final bool isUpdating;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => isAuthor
          ? context.push('/author-profile/$id')
          : context.push('/user-profile', extra: user),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Color.fromRGBO(181, 77, 232, 0.1),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 16,
          children: [
            Expanded(
              child: Row(
                spacing: 8,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(70),
                    child: AppImage(avatarUrl(image), width: 70, height: 70),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 2,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isAuthor)
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff9110DE),
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: ShaderMask(
                                  shaderCallback: ((bounds) {
                                    return authorLeadGradient.createShader(
                                      bounds,
                                    );
                                  }),
                                  child: Icon(
                                    Remix.leaf_fill,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (caption.isNotEmpty)
                          Text(
                            caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(primaryTextCOLR),
                              fontSize: 12,
                            ),
                          ),
                        Text(
                          '$followers Followers',
                          style: TextStyle(
                            color: Color(secondaryCOLR),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!isSelf)
              GestureDetector(
                onTap: isUpdating ? null : onToggleFollow,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: isFollowing ? null : defaultGradientTTB,
                    border: isFollowing
                        ? Border.all(
                            width: 1,
                            color: Color.fromRGBO(181, 77, 232, 0.4),
                          )
                        : null,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: isUpdating
                      ? SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isFollowing ? 'Following' : 'Follow',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
