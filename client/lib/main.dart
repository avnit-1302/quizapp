import 'package:client/app.dart';
import 'package:client/app_settings.dart';
import 'package:client/elements/loading.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The main function to run the app
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(const ProviderScope(child: MainApp())));
}

/// The main app widget
class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(userProvider);

    return userAsyncValue.when(
      loading: () {
        return const Center(
          child: LogoLoading(),
        );
      },
      error: (error, stackTrace) {
        return const ErrorScreen();
      },
      data: (user) {
        final routerNotifier = ref.read(routerProvider.notifier);
        AppSettings.initiateScreens(routerNotifier);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (await user.inSession()) {
            routerNotifier.setPath(context, "home");
          } else {
            routerNotifier.setPath(context, "login");
          }
        });

        return const App();
      },
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(child: Text('An error occurred')),
    );
  }
}
