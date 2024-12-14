import 'package:client/tools/audioManager.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/tools.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget to display and manage quiz questions in a socket-based quiz
class QuizSocketQuestion extends ConsumerStatefulWidget {
  const QuizSocketQuestion(
      {super.key,
      required this.router,
      required this.user,
      required this.values,
      required this.onClick,
      required this.onTimer});

  final RouterNotifier router;
  final UserNotifier user;
  final Map<String, dynamic> values;
  final Function onClick;
  final Function onTimer;

  @override
  QuizSocketQuestionState createState() => QuizSocketQuestionState();
}

class QuizSocketQuestionState extends ConsumerState<QuizSocketQuestion> {
  late final RouterNotifier router;
  late final UserNotifier user;
  bool isLoading = true;
  bool isAnswered = false;
  Map<String, dynamic> answer = {"option": "", "id": -1};
  AudioManager? audioManager;

  bool showAnswer = false;

  String thumbnail = "";
  String title = "Loading...";
  int counter = 0;
  String state = "countdown";
  Map<String, dynamic> questionData = {
    "question": "Loading...",
    "options": [{}]
  };

  @override
  void initState() {
    super.initState();
    audioManager = AudioManager();
    List<String> sounds = [
      "audio.mp3",
      "audio1.mp3",
      "audio2.mp3",
      "audio3.mp3"
    ];
    audioManager!.playBackgroundAudio(sounds);
    _initStates();
  }

  @override
  void dispose() {
    audioManager?.dispose();
    super.dispose();
  }

  void _initStates() {
    setState(() {
      title = widget.values['quiz']['title'];
      counter = widget.values['quiz']['timer'];
      questionData = widget.values['quizQuestions']["questions"];
    });
    setState(() {
      isLoading = false;
    });
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
            isAnswered
                ? SizedBox(
                    width: 350,
                    height: 350,
                    child: ListView.builder(
                      itemCount: questionData['quizOptions'].length ?? 0,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: answer["option"] ==
                                    questionData['quizOptions'][index]["option"]
                                ? Colors.white
                                : Colors.grey[200],
                            border: Border.all(
                                color: answer["option"] ==
                                        questionData['quizOptions'][index]
                                            ["option"]
                                    ? theme.primaryColor
                                    : Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            // Use Column for better text wrapping
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                questionData['quizOptions'][index]['option'] ==
                                        null
                                    ? ""
                                    : Tools.fixEncoding(
                                        questionData['quizOptions'][index]
                                            ['option']),
                                style: const TextStyle(fontSize: 16),
                                softWrap: true,
                                overflow: TextOverflow
                                    .visible, // Allow text to wrap naturally
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox(
                    width: 350,
                    height: 350,
                    child: ListView.builder(
                      itemCount: questionData['quizOptions'].length ?? 0,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              answer = questionData['quizOptions'][index];
                              isAnswered = true;
                            });
                            widget.onClick({
                              "answer": questionData['quizOptions'][index]
                                  ['option'],
                              "answerId": questionData['quizOptions'][index]
                                  ['id'],
                            });
                          },
                          child: Container(
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: theme.primaryColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              questionData['quizOptions'][index]['option'] ==
                                      null
                                  ? ""
                                  : Tools.fixEncoding(
                                      questionData['quizOptions'][index]
                                          ['option']),
                              style: TextStyle(fontSize: 16),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
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
