import 'package:client/elements/input.dart';
import 'package:client/elements/button.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends ConsumerState<Register> {
  late final RouterNotifier router;
  late final UserNotifier user;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool terms = false;

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
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
      if (mounted) {
        router.setPath(context, 'home');
      }
    }
  }

  Future<void> onPressed(BuildContext context) async {
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        !terms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    if (!terms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms.')),
      );
      return;
    }
    toggleLoading();
    await Future.delayed(const Duration(seconds: 2), () {});
    try {
      final result = await ApiHandler.register(email, password, confirmPassword, username, terms);
      if (result.statusCode == 200) {
        router.setPath(context, 'login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.body)),
        );
        toggleLoading();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      toggleLoading();
    }
  }

  void toggleLoading() {
    setState(() {
      loading = !loading;
    });
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
                'Sign up',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              Input(
                labelText: "Username",
                enabled: !loading,
                controller: usernameController,
                obscureText: false,
                onReturn: (_) {
                  emailFocusNode.requestFocus();
                },
                icon: Icons.person,
              ),
              const SizedBox(height: 24),
              Input(
                labelText: "Email",
                controller: emailController,
                enabled: !loading,
                obscureText: false,
                focusNode: emailFocusNode,
                onReturn: (_) {
                  passwordFocusNode.requestFocus();
                },
                icon: Icons.email,
              ),
              const SizedBox(height: 24),
              Input(
                labelText: "Password",
                enabled: !loading,
                controller: passwordController,
                obscureText: true,
                focusNode: passwordFocusNode,
                onReturn: (_) {
                  confirmPasswordFocusNode.requestFocus();
                },
                icon: Icons.lock,
              ),
              const SizedBox(height: 24),
              Input(
                labelText: "Confirm Password",
                enabled: !loading,
                controller: confirmPasswordController,
                obscureText: true,
                focusNode: confirmPasswordFocusNode,
                onReturn: (_) {
                  onPressed(context);
                },
                icon: Icons.lock,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(value: terms, activeColor: theme.primaryColor, onChanged: (bool? value) {
                    setState(() {
                      terms = value!;
                    }
                    );
                  }
                  ),
                  const Text("I accept the terms and conditions.")
                ],
              ),
              SmallTextButton(
                  text: "Sign up",
                  loading: loading,
                  onPressed: () => onPressed(context)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ",
                      style: TextStyle(color: Colors.grey)),
                  InkWell(
                    onTap: () => router.setPath(context, 'login'),
                    child: Text(
                      'Sign in here.',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
