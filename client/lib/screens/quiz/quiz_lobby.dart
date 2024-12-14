import 'dart:async';
import 'dart:convert';
import 'package:client/elements/button.dart';
import 'package:client/screens/quiz/quiz_message_handler.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/error_message.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// A stateful widget to manage the quiz lobby interactions and WebSocket connections.
class QuizLobby extends ConsumerStatefulWidget {
  const QuizLobby({super.key});

  @override
  QuizLobbyState createState() => QuizLobbyState();
}

class QuizLobbyState extends ConsumerState<QuizLobby> {
  // Router and user-related objects
  late RouterNotifier router;
  late UserNotifier user;

  // WebSocket client
  StompClient? stompClient;

  // Lobby-specific properties
  String quizToken = '';
  String? leader;
  List<String> players = [];
  Completer<void> quizIdCompleter = Completer<void>();

  // User and quiz-specific data
  String username = "";
  String quizName = "";
  String quizId = "";
  int quizTimer = 0;
  int questionCount = 0;

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
      _connect();
    });
  }

  /// Initializes the username by fetching it from the API.
  Future<void> _initUsername() async {
    String userString = await ApiHandler.getProfile(user.token!)
          .then((value) => value['username']);
    setState(() {
      username = userString;
    });
  }

  @override
  void dispose() {
    stompClient?.deactivate();
    super.dispose();
  }

  /// Establishes a WebSocket connection and sets up subscriptions.
  Future<void> _connect() async {
    await _initUsername();
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
        onDisconnect: (frame) => _leaveQuiz,
        webSocketConnectHeaders: {'Origin': ApiHandler.url},
        useSockJS: true,
      ),
    );

    stompClient!.activate();
  }

  /// Callback for WebSocket connection. Subscribes to appropriate topics and sends messages.
  Future<void> _onConnect(StompFrame frame) async {
    if (bool.parse(router.getValues!["create"].toString())) {
      _subscribeToCreate();
      await _createQuiz();
      await quizIdCompleter.future;
      _subscribeToJoin(quizToken);
      setState(() {
        players.add(username);
      });
    } else {
      setState(() {
        quizToken = router.getValues!['id'].toString();
      });
      _subscribeToJoin(quizToken);
      _joinQuiz();
    }
  }

  /// Subscribes to the topic for quiz creation updates.
  void _subscribeToCreate() {
    stompClient!.subscribe(
      destination: "/topic/quiz/create/$username",
      callback: (StompFrame frame) {
        if (frame.body != null) {
          var result = json.decode(frame.body!);
          setState(() {
            quizToken = result['token'].toString();
            leader = result['leaderUsername'];
            quizName = result['quiz']['title'];
            quizId = result["quiz"]['id'].toString();
            quizTimer = result['quiz']['timer'];
            questionCount = result['amountOfQuestions'];
          });
          quizIdCompleter.complete();
        } else {
        }
      },
    );
  }

  /// Subscribes to the topic for quiz session updates.
  void _subscribeToJoin(String quizId) {
    stompClient!.subscribe(
      destination: "/topic/quiz/session/$quizId",
      callback: (StompFrame frame) {
        if (frame.body != null) {
          var result = json.decode(frame.body!);
          if (result['message'] == "join" || result['message'] == "update") {
            var mapPlayers = List<Map<String, dynamic>>.from(result['players']);
            if (mounted) {
              setState(() {
                players =
                    mapPlayers.map((p) => p['username'] as String).toList();
                quizName = result['quiz']['title'];
                leader = result['leaderUsername'];
                this.quizId = result["quiz"]['id'].toString();
                quizTimer = result['quiz']['timer'];
              });
            }
          } else if (result['message'].toString().startsWith("leave")) {
            if (mounted) {
              setState(() {
                players.remove(QuizMessageHandler.handleLobbyMessages(
                    context, router, result, username, stompClient!));
              });
            }
          } else {
            result['thumbnail'] =
                '${ApiHandler.url}/api/quiz/thumbnail/$quizId';
            result["username"] = username;
            QuizMessageHandler.handleLobbyMessages(
                context, router, result, username, stompClient!);
          }
        } else {
          ErrorHandler.showOverlayError(context, 'Empty body');
          router.setPath(context, 'home');
        }
      },
    );
  }

  /// Sends a message to create a new quiz.
  Future<void> _createQuiz() async {
    stompClient!.send(
      destination: '/app/quiz/create',
      body: json.encode(
          {'quizId': router.getValues!['id'], "userToken": user.token!}),
    );
  }

  /// Sends a message to join an existing quiz.
  void _joinQuiz() {
    stompClient!.send(
      destination: '/app/quiz/join',
      body: json.encode({
        'token': router.getValues!['id'],
        "userToken": user.token!,
      }),
    );
  }

  /// Sends a message to start the quiz.
  void _startQuiz() {
    stompClient!.send(
      destination: '/app/quiz/start',
      body: json.encode({
        'token': quizToken,
        "userToken": user.token!,
      }),
    );
  }

  /// Sends a message to leave the quiz.
  void _leaveQuiz() {
    stompClient!.send(
      destination: '/app/quiz/leave',
      body: json.encode({
        'token': quizToken,
        "userToken": user.token!,
      }),
    );
  }

  /// Sends a message to change the quiz settings.
  void _changeQuiz(int newQuizId) {
    stompClient!.send(
      destination: '/app/quiz/session/settings',
      body: json.encode({
        'token': quizToken,
        "userToken": user.token!,
        "message": {
          "setNewQuiz": true,
          "quizId": newQuizId,
          "changeTimer": false
        }
      }),
    );
  }

  /// Sends a message to change the quiz timer.
  void _changeTimer(int newTime) {
    stompClient!.send(
      destination: '/app/quiz/session/settings',
      body: json.encode({
        'token': quizToken,
        "userToken": user.token!,
        "message": {"setNewQuiz": false, "changeTimer": true, "timer": newTime}
      }),
    );
  }

  /// Shows a dialog for changing the quiz timer.
  void changeTimerClick() {
    final TextEditingController timerController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter new timer in seconds'),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                controller: timerController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _changeTimer(int.parse(timerController.text));
                Navigator.of(context).pop();
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog for changing the quiz.
  void changeQuizClick() {
    final TextEditingController quizController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change quiz'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter new quiz id'),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                controller: quizController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _changeQuiz(int.parse(quizController.text));
                Navigator.of(context).pop();
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 8),
          quizId == ""
              ? const SizedBox(
                  height: 200,
                )
              : Image(
                  image: NetworkImage(
                      '${ApiHandler.url}/api/quiz/thumbnail/$quizId'),
                  height: 200,
                  fit: BoxFit.cover,
                ),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quizName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.primaryColor),
                      ),
                      child: GestureDetector(
                        onTap: () => {
                          Clipboard.setData(
                            ClipboardData(text: quizToken),
                          ),
                        },
                        child: Text(
                          'Game PIN: $quizToken',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedTextButton(
                      text: "${quizTimer.toString()} sec",
                      height: 40,
                      width: 50,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () =>
                          username == leader ? changeTimerClick() : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Players: ${players.length}",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "Questions: $questionCount",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 550,
                    child: SingleChildScrollView(
                      child: Wrap(
                        children: [
                          for (int i = 0; i < players.length; i++)
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Chip(
                                label: Text(
                                  players[i],
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: players[i] == leader
                                        ? Colors.orange
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          username == leader
              ? Container(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                        ),
                        SizedTextButton(
                          text: "Start",
                          onPressed: _startQuiz,
                          height: 50,
                          width: 160,
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        SizedTextButton(
                          text: "Leave",
                          onPressed: _leaveQuiz,
                          inversed: true,
                          height: 50,
                          width: 160,
                          textStyle: const TextStyle(
                              color: Colors.orange,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: SizedTextButton(
                      text: "Leave",
                      onPressed: _leaveQuiz,
                      inversed: true,
                      height: 50,
                      width: 200,
                      textStyle: const TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
