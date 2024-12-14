import 'package:client/tools/audioManager.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/tools.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget to display the score screen for a quiz
class ScoreScreen extends ConsumerStatefulWidget {
  const ScoreScreen({
    super.key,
    required this.router,
    required this.user,
    required this.values,
    required this.username,
  });

  final RouterNotifier router;
  final UserNotifier user;
  final Map<String, dynamic> values;
  final String username;

  @override
  ScoreState createState() => ScoreState();
}

class ScoreState extends ConsumerState<ScoreScreen> {
  int quizId = -1;
  String title = "Loading...";
  String token = "";
  List<Map<String, dynamic>> players = [
    {"username": "Loading...", "id": -1, "answers": [], "score": -1}
  ];
  AudioManager? audioManager;

  @override
  void initState() {
    super.initState();
    audioManager = AudioManager();
    _initializeValues();
    audioManager!.playSoundEffect("countup.mp3");
  }

  @override
  void dispose() {
    audioManager?.dispose();
    super.dispose();
  }

  /// initializes values and plays sound effect
  void _initializeValues() {
    setState(() {
      quizId = widget.values["quiz"]['id'];
      title = widget.values["quiz"]['title'];
      token = widget.values['token'];
      players = List<Map<String, dynamic>>.from(widget.values['players'])
        ..sort((a, b) => b['score'].compareTo(a['score']));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Scores",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        SizedBox(
          width: 350,
          height: 350,
          child: ListView.builder(
            itemCount: players.length > 5 ? 5 : players.length,
            itemBuilder: (context, index) {
              return Container(
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Tools.fixEncoding(players[index]['username'].toString())),
                    Text(players[index]['score'].toString()),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
