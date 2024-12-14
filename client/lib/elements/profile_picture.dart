import 'package:flutter/material.dart';

/// A profile picture widget
class ProfilePicture extends StatelessWidget {
  final String url;
  final double size;
  final BoxFit? fit;

  const ProfilePicture({super.key, required this.url, this.size = 79, this.fit});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image(
        image: NetworkImage(url),
        width: size,
        height: size,
        fit: fit ?? BoxFit.cover,
      ),
    );
  }
}