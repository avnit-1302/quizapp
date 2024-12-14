import 'package:client/elements/quiz_post.dart';
import 'package:flutter/material.dart';

/// A widget that displays a feed category
class FeedCategory extends StatelessWidget {
  const FeedCategory({
    super.key,
    required this.category,
    required this.quizzes,
  });

  final String category;
  final List<Map<String, dynamic>> quizzes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            category,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        quizzes.isNotEmpty ? SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return QuizPost(
                id: quiz['id'] ?? '',
                profilePicture: quiz['profile_picture'] ?? '',
                title: quiz['title'] ?? '',
                username: quiz['username'] ?? '',
                createdAt: quiz['createdAt']
              );
            },
          ),
        )
        : SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'No quizzes found',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
