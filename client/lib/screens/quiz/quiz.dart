import 'package:client/dummy_data.dart';
import 'package:client/elements/bottom_navbar.dart';
import 'package:client/elements/button.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/error_message.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/tools.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A screen displaying details about a selected quiz.
/// Users can choose to play the quiz solo or with friends.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends ConsumerState<QuizScreen> {
  late final RouterNotifier router;
  late final UserNotifier user;
  bool isLoading = true;

  late Map<String, dynamic> quiz;
  late List<dynamic> createdAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);
      user = ref.read(userProvider.notifier);
      
      if (router.getValues == null || router.getValues!['id'] == null) {
        ErrorHandler.showOverlayError(context, 'No quiz found.');
        router.setPath(context, 'home');
      } else {
        _getQuiz();
      }
    });
  }
  
  /// Fetches the quiz details from the server.
  ///
  /// Retrieves the quiz data using the API handler and sets the state.
  /// If the response is empty, shows an error and redirects to the home page.
  Future<void> _getQuiz() async {
    final response =
        await ApiHandler.getQuiz(int.parse(router.getValues!['id'].toString()));

    if (response.isEmpty) {
      ErrorHandler.showOverlayError(context, 'Failed to load quiz.');
      router.setPath(context, 'home');
    } else {
      final profilePicture =
          await ApiHandler.getProfilePicture(response['username']);

      setState(() {
        quiz = response;
        quiz['pfp'] = profilePicture;
        createdAt = quiz['createdAt'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              router.goBack(context);
            },
          ),
        ],
      ),
      body: Container(
        color: theme.canvasColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? SizedBox(height: 250)
                : Center(
                    child: Image.network(
                      '${ApiHandler.url}/api/quiz/thumbnail/${router.getValues!['id']}',
                      height: 250,
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                    ),
                  ),
            const SizedBox(height: 4),
            Row(
              children: [
                ClipOval(
                  child: Image.network(
                    isLoading ? DummyData.profilePicture : quiz['pfp'],
                    width: 49,
                    height: 49,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading ? "" : quiz['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(isLoading ? "" : quiz['username'].toString()),
                        const SizedBox(width: 4),
                        const Text("|"),
                        const SizedBox(width: 4),
                        Text(isLoading
                            ? ""
                            : Tools.formatCreatedAt(createdAt)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.grey,
              height: 0.5,
            ),
            const SizedBox(height: 8),
            SizedTextButton(
              text: "Play",
              onPressed: () => router.setPath(context, "quiz/solo", values: {
                'quizData': quiz,
              }),
              width: double.infinity,
              height: 50,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            SizedTextButton(
              text: "Play with friends",
              onPressed: () => router.setPath(context, "quiz/lobby", values: {
                'id': int.parse(quiz['id'].toString()),
                'create': true
              }),
              width: double.infinity,
              inversed: true,
              height: 50,
              textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.grey,
              height: 0.5,
            ),
            const SizedBox(height: 8),
            Text(
              isLoading ? "" : quiz['description'],
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(path: "quiz"),
    );
  }
}
