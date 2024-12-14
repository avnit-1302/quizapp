import 'package:client/elements/bottom_navbar.dart';
import 'package:client/elements/feed_category.dart';
import 'package:client/elements/loading.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/tools/api_handler.dart'; // Import the API handler

/// The Home screen serves as the main landing page, displaying recent and popular quizzes.
class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> {
  late final RouterNotifier router;
  late final UserNotifier user;
  List<Map<String, dynamic>>? _recentQuizData;
  List<Map<String, dynamic>>? _popularQuizData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);
      user = ref.read(userProvider.notifier);

      _initQuizzes();
    });
  }

  Future<void> _initQuizzes() async {
    ApiHandler.getQuizzesByFilter(0, 5, "createdAt", "DESC").then((value) => {
          setState(() {
            _recentQuizData = value;
          })
        });
    ApiHandler.getMostPopularQuizzes(0).then((value) => {
          setState(() {
            _popularQuizData = value;
          })
        });

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.canvasColor,
      body: loading
          ? const Center(
              child: LogoLoading(),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: FeedCategory(
                      category: "Recently Created",
                      quizzes: _recentQuizData ?? []),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: FeedCategory(
                      category: "Popular Quizzes",
                      quizzes: _popularQuizData ?? []),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavbar(
        path: "home",
      ),
    );
  }
}
