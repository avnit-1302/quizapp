import 'package:client/elements/counter.dart';
import 'package:client/elements/loading.dart';
import 'package:client/tools/audioManager.dart';
import 'package:client/screens/quiz/quiz_solo/quiz_question_solo.dart';
import 'package:client/screens/quiz/quiz_solo/quiz_result_solo.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A stateful widget for managing a solo quiz game session
class QuizGameSolo extends ConsumerStatefulWidget {
  const QuizGameSolo({super.key});

  @override
  QuizGameSoloState createState() => QuizGameSoloState();
}

class QuizGameSoloState extends ConsumerState<QuizGameSolo>
    with TickerProviderStateMixin {
  QuizGameSoloState();

  // Router and user-related notifiers
  late final RouterNotifier router;
  late final UserNotifier user;

  // Audio manager for background music and sound effects
  late final AudioManager audioManager;

  // Data structures to manage quiz data and progress
  Map<String, dynamic>? quizData;
  Map<String, dynamic> quizTaken = {};

  // UI components and state variables
  Widget? counter;
  int currentQuestionIndex = 0;
  int duration = 0;
  DateTime? questionStartTime;
  String page = "question";
  bool loading = true;

  // Score animation variables
  AnimationController? scoreAnimationController;
  Animation<int>? scoreAnimation;

  @override
  void initState() {
    super.initState();
    audioManager = AudioManager();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);
      user = ref.read(userProvider.notifier);


      quizData = router.getValues!["quizData"];

      quizTaken = {
        "quizId": quizData!["id"],
        "timer": quizData!["timer"],
        "answers": [{
          "questionId": quizData!["quizQuestions"][0]["id"],
          "optionId": null,
          "optionText": null,
          "responseTime": 0,
        }],
      };

      setState(() {
        duration = quizData!["timer"];
        counter = Counter(
          key: ValueKey<int>(currentQuestionIndex),
          onCountdownComplete: _handleNextClick,
          duration: duration,
          height: 70,
          width: 70,
          color: Colors.white,
        );
        questionStartTime = DateTime.now();
        loading = false;
      });
    });

    audioManager.playBackgroundAudio(
        ['audio.mp3', 'audio1.mp3', 'audio2.mp3', 'audio3.mp3']);
  }

  @override
  void dispose() {
    super.dispose();
    audioManager.dispose();
  }

  void setScore(int score) {
    setState(() {
      scoreAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2, milliseconds: 500),
      );
      scoreAnimation = IntTween(begin: 0, end: score).animate(
        CurvedAnimation(
          parent: scoreAnimationController!,
          curve: Curves.easeOut,
        ),
      );
    });
    scoreAnimationController!.forward();
  }

  void _handleOptionTap(String optionText, int optionId) {
    setState(() {
      quizTaken["answers"][currentQuestionIndex] = {
        "questionId": quizData!["quizQuestions"][currentQuestionIndex]["id"],
        "optionId": optionId,
        "optionText": optionText,
        "responseTime": 0,
      };
    });
  }

  void _handleNextClick() {

    if (quizTaken["answers"][currentQuestionIndex]["optionId"] == null) {
      audioManager.playSoundEffect("error.mp3");
    } else {
      audioManager.playSoundEffect("next.mp3");
    }

    setState(() {
      quizTaken["answers"][currentQuestionIndex]["responseTime"] =
          DateTime.now().difference(questionStartTime!).inMilliseconds / 1000;

      if (currentQuestionIndex < quizData!["quizQuestions"].length - 1) {
        quizTaken["answers"].add({
          "questionId": quizData!["quizQuestions"][currentQuestionIndex + 1]
              ["id"],
          "optionId": null,
          "optionText": null,
          "responseTime": 0,
        });
        currentQuestionIndex++;
        questionStartTime = DateTime.now();
        counter = Counter(
          key: ValueKey<int>(currentQuestionIndex),
          onCountdownComplete: _handleNextClick,
          duration: duration,
          height: 70,
          width: 70,
          color: Colors.white,
        );
      } else {
        audioManager.stopAudio();
        audioManager.playSoundEffect("finish.mp3");
        page = "result";
      }
    });
  }

  Widget _getPage() {
    if (loading) {
      return const Center(
        child: LogoLoading(),
      );
    } else {
      if (page == "question") {
        List<Map<String, dynamic>> options = (quizData!["quizQuestions"]
                [currentQuestionIndex]["quizOptions"] as List)
            .map((option) => option as Map<String, dynamic>)
            .toList();
        return QuizQuestionSolo(
          key: ValueKey<int>(currentQuestionIndex),
          quizId: quizData!["id"],
          questionText: quizData!["quizQuestions"][currentQuestionIndex]
              ["question"],
          options: options,
          onOptionTap: _handleOptionTap,
          onNextTap: _handleNextClick,
          totalQuestions: quizData!["quizQuestions"].length,
          currentQuestionIndex: currentQuestionIndex,
        );
      } else if (page == "result") {
        return QuizResultSolo(
            token: user.token!,
            quizTaken: quizTaken,
            quizData: quizData!,
            totalQuestions: quizData!["quizQuestions"].length,
            setScore: setScore);
      } else {
        return const Center(
          child: Text("Error: Invalid page"),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          quizData?["title"] ?? "Untitled Quiz",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              router.goBack(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              quizData == null
                  ? Center(
                      child: LogoLoading(),
                    )
                  : Center(
                      child: Image.network(
                        '${ApiHandler.url}/api/quiz/thumbnail/${quizData!["id"]}',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
              page == "question"
                  ? Positioned(
                      bottom: 10,
                      child: counter != null ? counter! : Container(),
                    )
                  : Positioned(
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Your Total Score",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            scoreAnimationController == null
                                ? Text(
                                    "0",
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : AnimatedBuilder(
                                    animation: scoreAnimationController!,
                                    builder: (context, child) {
                                      return Text(
                                        "${scoreAnimation!.value}",
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                            const SizedBox(height: 10),
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 36,
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
          Expanded(child: _getPage()),
        ],
      ),
    );
  }
}
