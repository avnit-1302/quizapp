import 'dart:convert';
import 'dart:developer' as developer;
import 'package:client/elements/button.dart';
import 'package:client/elements/counter.dart';
import 'package:client/screens/quiz/socket/quiz_socket_answers.dart';
import 'package:client/screens/quiz/socket/quiz_socket_question.dart';
import 'package:client/screens/quiz/socket/quiz_socket_score.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/error_message.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// A stateful widget for managing the Quiz game logic over a WebSocket connection.
class QuizGameSocket extends ConsumerStatefulWidget {
  const QuizGameSocket({super.key});

  @override
  QuizGameSocketState createState() => QuizGameSocketState();
}

class QuizGameSocketState extends ConsumerState<QuizGameSocket>
    with TickerProviderStateMixin {
  late RouterNotifier router;
  late UserNotifier user;

  // WebSocket client
  StompClient? stompClient;

  // Game state and properties
  String username = "";
  String thumbnail = "";
  String title = "Loading...";
  int timer = 0;
  String state = "countdown";
  int questionNumber = 0;
  bool isLoading = true;
  String message = "";
  late final AnimationController scoreAnimationController;

  Map<String, dynamic> values = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);
      user = ref.read(userProvider.notifier);
      if (user.token == null) {
        router.setPath(context, 'login');
        return;
      }
      _initUsername();
      _initStates();
      _connectToSocket();
      scoreAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2, milliseconds: 500),
      );

      if (state == "end") {
        scoreAnimationController.forward();
      }
    });
  }

  /// Initializes the username by fetching it from the API.
  Future<void> _initUsername() async {
    username = await ApiHandler.getProfile(user.token!)
        .then((value) => value['username']);
  }

  /// Initializes the states and properties of the game.
  void _initStates() {
    if (router.getValues == null) {
      router.setPath(context, 'join');
      return;
    }
    if (router.getValues!['token'] == null) {
      router.setPath(context, 'join');
      return;
    }

    // Set initial state values
    setState(() {
      title = router.getValues!['quiz']['title'];
      timer = router.getValues!['quiz']['timer'];
      thumbnail = router.getValues!['thumbnail'];
      values = router.getValues!;
      values['message'] = {"message": "firstCountDown"};
      values['username'] = username;
      isLoading = false;
    });
  }

  /// Establishes a connection to the WebSocket server.
  void _connectToSocket() {
    stompClient = StompClient(
      config: StompConfig(
        url: '${ApiHandler.url}/socket',
        onConnect: _onConnect,
        beforeConnect: () async {
          print('Connecting...');
        },
        onWebSocketError: (dynamic error) =>
            ErrorHandler.showOverlayError(context, 'WebSocket Error: $error'),
        onStompError: (dynamic error) =>
            ErrorHandler.showOverlayError(context, 'STOMP Error: $error'),
        onDisconnect: (frame) {
          developer.log('Disconnected');
        },
        webSocketConnectHeaders: {'Origin': ApiHandler.url},
        useSockJS: true,
      ),
    );

    stompClient!.activate();
  }
  
  /// Handles WebSocket connection setup.
  void _onConnect(StompFrame frame) {
    stompClient!.subscribe(
      destination: "/topic/quiz/game/session/${router.getValues!['token']}",
      callback: (StompFrame frame) {
        if (frame.body != null) {
          var result = json.decode(frame.body!);
          setState(() {
            state = result['state'];
            title = result["quiz"]['title'];
            timer = result["quiz"]['timer'];
            message = result['message'];
            values = result;
            values['username'] = username;
          });
          _displaySelectedScene();
        } else {
          ErrorHandler.showOverlayError(context, 'Error: No body');
        }
      },
    );
  }

  /// Handles the quiz timer logic and progresses the game state.
  Future<void> _handleQuizTimer(bool showAnswers) async {
    stompClient!.send(
      destination: "/app/quiz/game",
      body: json.encode({
        "token": router.getValues!['token'],
        "message": {
          "message": "next",
          "quizState": showAnswers ? "showAnswer" : "quiz"
        },
        "userToken": user.token,
        "quizId": router.getValues!['quiz']['id'],
      }),
    );
    _displaySelectedScene();
  }

  /// Progresses to the next state in the game.
  Future<void> _handleNext() async {
    stompClient!.send(
      destination: "/app/quiz/game",
      body: json.encode({
        "token": router.getValues!['token'],
        "message": {"message": "next"},
        "userToken": user.token,
        "quizId": router.getValues!['quiz']['id'],
      }),
    );
    _displaySelectedScene();
  }

  /// Handles the answer submission process.
  _handleAnswer(Map<String, dynamic> data) async {
    final String answer = data['answer'];
    final int answerId = data['answerId'];

    final Map<String, dynamic> message = {
      "message": "answer",
      "answer": answer,
      "answerId": answerId,
    };

    final Map<String, dynamic> answerMap = {
      "token": router.getValues!['token'],
      "userToken": user.token,
      "quizId": router.getValues!['quiz']['id'],
      "answerId": answerId,
      "message": message,
    };
    stompClient!.send(
      destination: "/app/quiz/game",
      body: json.encode(answerMap),
    );
  }

  /// Displays the appropriate UI component based on the game state.
  Widget _displaySelectedScene() {
    if (state == "quiz") {
      if (message == "showAnswer") {
        return QuizSocketAnswers(
          router: router,
          user: user,
          values: values,
          onTimer: (data) => {_handleQuizTimer(data)},
        );
      } else {
        return QuizSocketQuestion(
          router: router,
          user: user,
          values: values,
          onTimer: (data) => {_handleQuizTimer(data)},
          onClick: (data) => _handleAnswer(data),
        );
      }
    } else if (state == "score") {
      return ScoreScreen(
        router: router,
        user: user,
        values: values,
        username: username,
      );
    } else if (state == "end") {
      stompClient!.deactivate();
      return ScoreScreen(
        router: router,
        user: user,
        values: values,
        username: username,
      );
    } else {
      return Counter(
          onCountdownComplete: _handleNext, duration: 5, marginTop: 16);
    }
  }

  /// Retrieves the animation controller for displaying the final score.
  Animation<int> getScoreAnimationController(AnimationController controller) {
    final finalScore = values['players']
        .firstWhere((element) => element['username'] == username)['score'];

    return IntTween(begin: 0, end: finalScore).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);	
    if (state == "end" && !scoreAnimationController.isAnimating) {
      scoreAnimationController.forward();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          state == "score" && username == values['leaderUsername']
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedTextButton(
                    text: "Next",
                    onPressed: _handleNext,
                    height: 30,
                    width: 70,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                )
              : const SizedBox(width: 0),
          state == "end"
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedTextButton(
                    text: "Leave",
                    onPressed: () {
                      router.setPath(context, 'join');
                    },
                    height: 30,
                    width: 70,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                )
              : const SizedBox(width: 0),
        ],
      ),
      body: Column(
        children: [
          isLoading
              ? const SizedBox(
                  height: 200,
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      '${ApiHandler.url}/api/quiz/thumbnail/${values['quiz']['id']}',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    if (state == "quiz") ...[
                      if (message == "showAnswer")
                        Positioned(
                          bottom: 10,
                          child: Counter(
                            key: UniqueKey(),
                            height: 70,
                            width: 70,
                            color: Colors.white,
                            onCountdownComplete: _handleNext,
                            duration: 5,
                            marginTop: 16,
                          ),
                        )
                      else
                        Positioned(
                          bottom: 10,
                          child: Counter(
                            key: UniqueKey(),
                            height: 70,
                            width: 70,
                            color: Colors.white,
                            onCountdownComplete: _handleNext,
                            duration: timer,
                            marginTop: 16,
                          ),
                        ),
                    ] else if (state == "end") ...[
                      Positioned(
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.5),
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
                              AnimatedBuilder(
                                animation: scoreAnimationController,
                                builder: (context, child) {
                                  return Text(
                                    "${getScoreAnimationController(scoreAnimationController).value}",
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
                  ],
                ),
          _displaySelectedScene(),
        ],
      ),
    );
  }
}
