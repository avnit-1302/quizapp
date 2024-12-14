import 'package:client/elements/button.dart';
import 'package:client/elements/quiz_post.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The main profile page
class MainProfile extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> quizzes;
  final List<Map<String, dynamic>> history;
  const MainProfile({super.key, required this.quizzes, required this.history});

  @override
  MainProfileState createState() => MainProfileState();
}

class MainProfileState extends ConsumerState<MainProfile> {
  late final RouterNotifier router;
  late final UserNotifier user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);
      user = ref.read(userProvider.notifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Your quizzes" section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your quizzes",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedTextButton(
                  text: "View all",
                  onPressed: () => print("View"),
                  height: 32,
                  width: 73,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            widget.quizzes.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = widget.quizzes[index];
                        return Stack(
                          children: [
                            // Quiz post content
                            QuizPost(
                              id: quiz['id'] ?? '',
                              profilePicture: quiz['profile_picture'] ?? '',
                              title: quiz['title'] ?? '',
                              username: quiz['username'] ?? '',
                              createdAt: quiz['createdAt'],
                            ),

                            // Three dots menu button in bottom-right corner
                            Positioned(
                              right: 8,
                              bottom: 30,
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (String result) {
                                  switch (result) {
                                    case 'Edit':
                                      print("Edit quiz ${quiz['id']}");
                                      break;
                                    case 'Delete':
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Delete Quiz'),
                                            content: const Text(
                                                'Are you sure you want to delete this quiz?'),
                                            actions: [
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                              TextButton(
                                                child: const Text('Delete'),
                                                onPressed: () async {
                                                  try {
                                                    await ApiHandler.deleteQuiz(
                                                        user.token!,
                                                        quiz['id']);
                                                    Navigator.of(context).pop();

                                                    setState(() {
                                                      widget.quizzes.removeWhere((q) =>
                                                          q['id'] ==
                                                          quiz['id']);
                                                    });

                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Quiz deleted successfully')),
                                                    );
                                                  } catch (e) {
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              e.toString())),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      break;
                                    case 'Share':
                                      print("Share quiz ${quiz['id']}");
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'Edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'Delete',
                                    child: Text('Delete'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'Share',
                                    child: Text('Share'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text("No quizzes found"),
                    ),
                  ),
            const SizedBox(height: 16),

            // "History" section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "History",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedTextButton(
                  text: "View all",
                  onPressed: () => print("View"),
                  height: 32,
                  width: 73,
                  textStyle: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            widget.history.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.history.length,
                      itemBuilder: (context, index) {
                        final quiz = widget.history[index];
                        return QuizPost(
                          id: quiz['id'] ?? '',
                          profilePicture: quiz['profile_picture'] ?? '',
                          title: quiz['title'] ?? '',
                          username: quiz['username'] ?? '',
                          createdAt: quiz['createdAt'],
                        );
                      },
                    ),
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text("No history found"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
