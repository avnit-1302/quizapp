import 'package:client/elements/input.dart';
import 'package:client/elements/button.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A screen for user login
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State to track "Remember Me" checkbox and loading status
  bool rememberMe = false;
  bool loading = false;

  // Focus node for password input field
  final passwordFocusNode = FocusNode();

  // Router and user session management
  late final RouterNotifier router;
  late final UserNotifier user;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);
      user = ref.read(userProvider.notifier);
      _checkUserSession();
    });
  }

  /// Check if the user is already logged in
  Future<void> _checkUserSession() async {
    if (await user.inSession()) {
      router.setPath(context, 'home');
    }
  }

  
  /// Toggles the loading state.
  void toggleLoading() {
    setState(() {
      loading = !loading;
    });
  }

  /// Handles the login process.
  ///
  /// Sends the email and password to the API for authentication.
  /// If successful, navigates to the home screen.
  Future<void> handleLogin() async {
    toggleLoading();

    await Future.delayed(const Duration(seconds: 2));

    final response =
        await ApiHandler.login(emailController.text, passwordController.text, rememberMe);
    

    if (response.statusCode == 200) {
      user.setToken(response.body);

      if (mounted) {
        router.setPath(context, "home");
      }
    } else {
      print("Error");
    }

    toggleLoading();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign in',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              Input(
                labelText: "Username or Email",
                enabled: !loading,
                controller: emailController,
                onReturn: (_) {
                  passwordFocusNode.requestFocus();
                },
                icon: Icons.login,
              ),
              const SizedBox(height: 24),
              Input(
                labelText: "Password",
                controller: passwordController,
                enabled: !loading,
                obscureText: true,
                focusNode: passwordFocusNode,
                onReturn: (_) {
                  handleLogin();
                },
                icon: Icons.lock,
              ),
              const SizedBox(height: 24),
              SmallTextButton(
                onPressed: () {
                  handleLogin();
                },
                text: 'Sign In',
                loading: loading,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(value: rememberMe, activeColor: theme.primaryColor, onChanged: (bool? value) {
                    setState(() {
                      rememberMe = value!;
                    }
                    );
                  }
                  ),
                  const Text("Remember me")
                ],
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => router.setPath(context, 'forgot-password'),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(color: theme.primaryColor),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ",
                      style: TextStyle(color: Colors.grey)),
                  InkWell(
                    onTap: () => router.setPath(context, 'register'),
                    child: Text(
                      'Sign up here.',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
