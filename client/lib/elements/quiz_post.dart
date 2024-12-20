import 'package:client/dummy_data.dart';
import 'package:client/elements/profile_picture.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that displays a quiz post
class QuizPost extends ConsumerWidget {
  const QuizPost({
    super.key,
    required this.id,
    required this.profilePicture,
    required this.title,
    required this.username,
    required this.createdAt,
  });

  final int id;
  final String profilePicture;
  final String title;
  final String username;
  final List<dynamic> createdAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          router.setPath(context, "quiz", values: {"id": id});
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey), // Add a grey border
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(
                image: NetworkImage("${ApiHandler.url}/api/quiz/thumbnail/$id"),
                height: 96,
                width: 212,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: ProfilePicture(
                      url: profilePicture.isEmpty
                          ? DummyData.profilePicture
                          : "${ApiHandler.url}/api/user/pfp/$username?t=${DateTime.now().millisecondsSinceEpoch}",
                      size: 50,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(username),
                          const SizedBox(width: 4),
                          const Text("|"),
                          const SizedBox(width: 4),
                          Text(Tools.formatCreatedAt(createdAt)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
