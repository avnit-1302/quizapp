import 'package:client/elements/custom_theme_extension.dart';
import 'package:client/elements/loading.dart';
import 'package:client/screens/categories.dart';
import 'package:client/screens/category.dart';
import 'package:client/screens/forgot_password.dart';
import 'package:client/screens/home.dart';
import 'package:client/screens/join.dart';
import 'package:client/screens/friends.dart';
import 'package:client/screens/login.dart';
import 'package:client/screens/profile.dart';
import 'package:client/screens/quiz/create_quiz.dart';
import 'package:client/screens/quiz/quiz.dart';
import 'package:client/screens/quiz/quiz_game_socket.dart';
import 'package:client/screens/quiz/quiz_lobby.dart';
import 'package:client/screens/quiz/quiz_game_solo.dart';
import 'package:client/screens/register.dart';
import 'package:client/tools/router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Holds all the settings for the application.
class AppSettings {
  /// Initiates all the screens in the application.
  static void initiateScreens(RouterNotifier router) {
    router.addScreen("", const Center(child: LogoLoading()));
    router.addScreen("login", const LoginScreen());
    router.addScreen("register", const Register());
    router.addScreen("home", const Home());
    router.addScreen("categories", const Categories());
    router.addScreen("join", const Join());
    router.addScreen("profile", const Profile());
    router.addScreen("create", const CreateQuiz());
    router.addScreen("quiz", const QuizScreen());
    router.addScreen("quiz/lobby", const QuizLobby());
    router.addScreen("quiz/game/socket", const QuizGameSocket());
    router.addScreen("category", Category());
    router.addScreen("quiz/solo", QuizGameSolo());
    router.addScreen("friends", Friends());
    router.addScreen("forgot-password", ForgotPassword());

    router.excludePaths(["", "login", "register", "test"]);
  }

  /// Returns the theme for the application.
  static ThemeData getTheme() {
    Color backgroundColor = const Color.fromARGB(255, 241, 241, 241);
    
    return ThemeData(
      primaryColor: Colors.orange,
      canvasColor: backgroundColor,
      scaffoldBackgroundColor: backgroundColor, 
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
      extensions: <ThemeExtension<dynamic>>[
        CustomThemeExtension(primaryTextColor: Colors.white)
      ]
    );
  }
}
