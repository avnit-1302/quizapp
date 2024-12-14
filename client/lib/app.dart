import 'package:client/tools/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/app_settings.dart';

/// The main app widget
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerState = ref.watch(routerProvider);
    final theme = AppSettings.getTheme();

    return MaterialApp(
      theme: theme, // Set the theme
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 10, // Set the height of the app bar
        ),
        body: Container(child: ref.read(routerProvider.notifier).currentScreen), // Set the body of the app
      ),
    );
  }
}
