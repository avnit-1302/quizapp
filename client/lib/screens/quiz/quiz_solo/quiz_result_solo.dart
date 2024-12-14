import 'package:client/elements/loading.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/audioManager.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays the quiz results in solo mode.
class QuizResultSolo extends ConsumerStatefulWidget {
  const QuizResultSolo(
      {super.key,
      required this.token,
      required this.quizTaken,
      required this.quizData,
      required this.totalQuestions,
      required this.setScore});

  final Map<String, dynamic> quizTaken;
  final Map<String, dynamic> quizData;
  final String token;
  final int totalQuestions;
  final Function setScore;

  @override
  QuizResultSoloState createState() => QuizResultSoloState();
}

class QuizResultSoloState extends ConsumerState<QuizResultSolo> {
  late final RouterNotifier router;
  bool loading = true;
  Map<String, dynamic> quizScore = {};
  late final AudioManager audioManager;

  @override
  void initState() {
    super.initState();
    audioManager = AudioManager();
    audioManager.playSoundEffect("countup.mp3");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);
      _initCheck();
    });
  }

  Future<void> _initCheck() async {
    final response = await ApiHandler.checkQuiz(widget.token, widget.quizTaken);
    setState(() {
      widget.setScore(response["score"]);
      quizScore = response;
      loading = false;
    });
    final quiz = widget.quizTaken;
    quiz["score"] = response["score"];
    quiz["amountOfCorrect"] = response["amountOfCorrect"];
    _initPost(quiz);
  }

  Future<void> _initPost(Map<String, dynamic> quiz) async {
    await ApiHandler.playQuiz(widget.token, quiz);
  }

  String performanceComment() {
    if (quizScore["score"] >= widget.totalQuestions * 1000 * 0.9) {
      return "Excellent job! You're a quiz master!";
    } else if (quizScore["score"] >= widget.totalQuestions * 1000 * 0.7) {
      return "Great job! You did well!";
    } else if (quizScore["score"] >= widget.totalQuestions * 1000 * 0.5) {
      return "Good effort! But there's room for improvement.";
    } else {
      return "Keep trying! You'll do better next time!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: LogoLoading())
        : Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
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
                              "${performanceComment()} Scoring ${quizScore["score"]} out of ${widget.totalQuestions * 1000} shows your knowledge of ${Tools.fixEncoding(widget.quizData["title"] ?? "Unknown Title")}.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: quizScore["checks"].map<Widget>((check) {
                              final questionId = check["questionId"];
                              final answerCorrect = check["correct"] ?? false;
                              final questionData = widget
                                  .quizData["quizQuestions"]
                                  ?.firstWhere((q) => q["id"] == questionId,
                                      orElse: () => {});

                              final questionText = Tools.fixEncoding(
                                  questionData?["question"] ?? "No Question");

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: answerCorrect
                                        ? Colors.green
                                        : Colors.red,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${quizScore["checks"].indexOf(check) + 1}. $questionText",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Icon(
                                      answerCorrect
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: answerCorrect
                                          ? Colors.green
                                          : Colors.red,
                                      size: 28,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      final router = ref.read(routerProvider.notifier);
                      router.setPath(context, "home");
                    },
                    child: const Text(
                      "Leave Quiz",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
