import 'package:client/tools/audioManager.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/tools.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget to display quiz answers in a socket-based real-time quiz
class QuizSocketAnswers extends ConsumerStatefulWidget {
  const QuizSocketAnswers({
    super.key,
    required this.router,
    required this.user,
    required this.values,
    required this.onTimer,
  });

  final RouterNotifier router;
  final UserNotifier user;
  final Map<String, dynamic> values;
  final Function onTimer;

  @override
  QuizSocketAnswersState createState() => QuizSocketAnswersState();
}

class QuizSocketAnswersState extends ConsumerState<QuizSocketAnswers> {
  late final RouterNotifier router;
  late final UserNotifier user;
  bool isLoading = true;
  bool isAnswered = false;
  AudioManager? audioManager;

  bool showAnswer = false;

  String thumbnail = "";
  String title = "Loading...";
  int counter = 5;
  String state = "countdown";
  Map<String, dynamic> questionData = {
    "question": "Loading...",
    "options": [{}]
  };
  Map<String, dynamic> answer = {"option": "", "id": -1};

  @override
  void initState() {
    super.initState();
    _initStates();
    _setAnswer();
  }

  /// Initializes states such as quiz title and question data
  void _initStates() {
    audioManager = AudioManager();
    setState(() {
      title = widget.values['quiz']['title'];
      questionData = widget.values['quizQuestions']["questions"];
      isLoading = false;
    });
  }

  /// Sets the user's last answer, if available
  void _setAnswer() {
    final username = widget.values["username"];
    final players = widget.values["players"] as List<dynamic>;
    final player = players.firstWhere(
      (player) => player["username"] == username,
      orElse: () => null,
    );

    if (player != null &&
        player["answers"] is List &&
        player["answers"].isNotEmpty) {
      setState(() {
        answer = player["answers"].last;
      });
    }
  }

  @override
  void dispose() {
    audioManager!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                questionData['question'] == null
                    ? "No question found"
                    : Tools.fixEncoding(questionData['question']),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 350,
              height: 350,
              child: ListView.builder(
                itemCount: questionData['quizOptions'].length ?? 0,
                itemBuilder: (context, index) {
                  final option = questionData['quizOptions'][index];
                  final isCorrect = widget.values["lastCorrectAnswers"]
                      .contains(option['id']);
                  final isSelected = answer["id"] == option['id'];

                  if (isCorrect) {
                    audioManager!.playSoundEffect("finish.mp3");
                  } else if (isSelected) {
                    audioManager!.playSoundEffect("error.mp3");
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: isSelected
                          ? (isCorrect
                              ? Border.all(color: Colors.green)
                              : Border.all(color: Colors.red))
                          : (isCorrect
                              ? Border.all(color: Colors.green)
                              : Border.all(color: theme.primaryColor)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            option['option'] == null
                                ? ""
                                : Tools.fixEncoding(option['option']),
                            style: const TextStyle(fontSize: 16),
                            softWrap: true,
                            overflow: TextOverflow
                                .visible,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (widget.values["currentQuestionIndex"] + 1) /
                    widget.values["amountOfQuestions"],
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                'Question ${widget.values["currentQuestionIndex"] + 1} of ${widget.values["amountOfQuestions"]}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
