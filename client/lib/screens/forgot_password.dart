import 'package:client/screens/token_verification.dart';
import 'package:flutter/material.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A screen where users can request a password reset by providing their email adress.
class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends ConsumerState<ForgotPassword> {
  final emailController = TextEditingController();
  bool loading = false;
  String? successMessage;
  String? errorMessage;

  late final RouterNotifier router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);
    });
  }

  void toggleLoading() {
    setState(() {
      loading = !loading;
    });
  }

  /// Handles the password reset process.
  ///
  /// Sends a password reset request using the provided email.
  /// Displays success or error messages based on the outcome.
  Future<void> handleForgotPassword() async {
    toggleLoading();
    successMessage = null;
    errorMessage = null;

    try {
      // Request password reset via API
      await ApiHandler.requestPasswordReset(emailController.text);

      // Display success message and navigate to token verification screen
      setState(() {
        successMessage = "A password reset link has been sent to your email.";
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TokenVerification(email: emailController.text, router: router,)
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to send password reset email. Please try again.";
      });
    }

    toggleLoading();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Reset Your Password',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                enabled: !loading,
                decoration: InputDecoration(
                  labelText: "Enter your email",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loading ? null : handleForgotPassword,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Send Reset Link"),
              ),
              if (successMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
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
