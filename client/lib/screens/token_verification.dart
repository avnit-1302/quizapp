import 'package:client/screens/reset_password.dart';
import 'package:client/tools/api_handler.dart';
import 'package:flutter/material.dart';
import 'package:client/tools/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenVerification extends ConsumerStatefulWidget {
  final String email;
  final RouterNotifier router;

  const TokenVerification({required this.email, super.key, required this.router});

  @override
  TokenVerificationState createState() => TokenVerificationState();
}

class TokenVerificationState extends ConsumerState<TokenVerification> {
  final tokenControllers = List.generate(5, (_) => TextEditingController());
  bool loading = false;
  String? errorMessage;

  void toggleLoading() {
    setState(() {
      loading = !loading;
    });
  }

  String getEnteredToken() {
    return tokenControllers.map((controller) => controller.text).join();
  }

  Future<void> verifyToken() async {
    toggleLoading();
    errorMessage = null;

    final enteredToken = getEnteredToken();

    if (enteredToken.length != 5) {
      setState(() {
        errorMessage = "Please enter the 5 sign code.";
      });
      toggleLoading();
      return;
    }

    try {
       await ApiHandler.verifyToken(widget.email, enteredToken);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPassword(token: enteredToken, router: widget.router,),
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Invalid or expired Code.";
      });
    }

    toggleLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Code"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                "Check your email",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter the 5 sign code sent to ${widget.email}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 50,
                      child: TextField(
                        controller: tokenControllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: "",
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 4) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loading ? null : verifyToken,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Verify Code"),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
