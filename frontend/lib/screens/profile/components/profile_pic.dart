import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Safely resolves avatar URL
/// If avatar is already a full URL (starts with http), use it as-is
/// Otherwise, prepend the base URL
String resolveAvatarUrl(String? avatar) {
  if (avatar == null || avatar.isEmpty) return "";
  
  // If it's already a full URL, return as-is
  if (avatar.startsWith("http://") || avatar.startsWith("https://")) {
    return avatar;
  }
  
  // Otherwise, prepend the base URL
  const baseUrl = "http://127.0.0.1:8000";
  return "$baseUrl$avatar";
}

class ProfilePic extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;

  const ProfilePic({
    Key? key,
    this.imageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveAvatarUrl(imageUrl);

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: SizedBox(
        height: 120,
        width: 120,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Hero(
              tag: 'avatar_preview',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: resolvedUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: resolvedUrl,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 50,
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) => CircleAvatar(
                          radius: 50,
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => CircleAvatar(
                          radius: 50,
                          backgroundImage: const AssetImage(
                            "assets/images/Profile Image.png",
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundImage: const AssetImage(
                          "assets/images/Profile Image.png",
                        ),
                      ),
              ),
            ),
            Positioned(
              right: -16,
              bottom: 0,
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 400),
                child: SizedBox(
                  height: 46,
                  width: 46,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(color: Colors.white),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 4,
                    ),
                    onPressed: onTap,
                    child: SvgPicture.asset(
                      "assets/icons/Camera Icon.svg",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
