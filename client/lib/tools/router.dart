import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/tools/error_message.dart';
import 'package:client/screens/login.dart';

/// The state of the router
class RouterState {
  final String path;
  final Map<String, dynamic>? pathVariables;
  final Map<String, dynamic>? values;
  final List<Map<String, dynamic>?> prevValues;
  final List<String> paths;

  RouterState({
    required this.path,
    this.pathVariables,
    this.paths = const [],
    this.values,
    this.prevValues = const [],
  });

  /// Copy the state with new values
  RouterState copyWith(
      {String? path,
      Map<String, dynamic>? pathVariables,
      List<String>? paths,
      Map<String, dynamic>? values,
      List<Map<String, dynamic>?>? prevValues}) {
    return RouterState(
      path: path ?? this.path,
      pathVariables: pathVariables ?? this.pathVariables,
      paths: paths ?? this.paths,
      values: values,
      prevValues: prevValues ?? this.prevValues,
    );
  }
}

/// The notifier for the router
class RouterNotifier extends StateNotifier<RouterState> {
  final Map<String, Widget> _screens = {};
  final Set<String> excludedPaths = {};

  RouterNotifier() : super(RouterState(path: ''));

  Widget get currentScreen => _screens[state.path] ?? const LoginScreen();

  /// Add a screen to the router
  void addScreen(String name, Widget screen) {
    _screens[name] = screen;
  }

  /// Remove a screen from the router
  void removeScreen(String name) {
    _screens.remove(name);
  }

  /// Set the path of the router
  void setPath(BuildContext context, String path,
      {Map<String, dynamic>? values}) {
    final screenName = _getScreenName(path);

    if (!_screens.containsKey(screenName)) {
      ErrorHandler.showOverlayError(context, 'Screen $screenName not found.');
      return;
    }

    List<String> newPaths = List<String>.from(state.paths);
    List<Map<String, dynamic>?> newPrevValues =
        List<Map<String, dynamic>?>.from(state.prevValues);

    if (state.paths.contains(path)) {
      final index = state.paths.indexOf(path);
      newPaths = state.paths.sublist(0, index + 1);
      newPrevValues = state.prevValues.sublist(0, index + 1);
    } else if (!excludedPaths.contains(screenName)) {
      newPaths.add(screenName);
      newPrevValues.add(values);
    }

    final newPathVariables = _extractPathVariables(path);
    final newValues = values ?? {};

    state = state.copyWith(
      path: screenName,
      pathVariables: newPathVariables,
      paths: newPaths,
      prevValues: newPrevValues,
      values: newValues,
    );
  }

  /// Go back to the previous Screen
  void goBack(BuildContext context) {
    if (state.paths.length > 1) {
      final newPaths = List<String>.from(state.paths)..removeLast();
      final newPrevValues = List<Map<String, dynamic>?>.from(state.prevValues)
        ..removeLast();
      state = state.copyWith(
          path: newPaths.last,
          paths: newPaths,
          values: newPrevValues.last,
          prevValues: newPrevValues);
    } else {
      ErrorHandler.showOverlayError(context, 'No previous path found.');
    }
  }

  /// Get the screen name from the path
  String _getScreenName(String path) {
    return path.contains("?") ? path.split("?")[0] : path;
  }

  /// Extract the path variables from the path
  Map<String, dynamic>? _extractPathVariables(String path) {
    if (!path.contains("?")) return null;

    final variables = <String, dynamic>{};
    final params = path.split("?")[1].split("&");

    for (var param in params) {
      final pair = param.split("=");
      if (pair.length == 2) {
        variables[pair[0]] = pair[1];
      }
    }

    return variables;
  }

  /// Exclude paths from the goBack function
  void excludePath(String path) {
    excludedPaths.add(path);
  }

  /// Exclude multiple paths from the goBack function
  void excludePaths(List<String> paths) {
    excludedPaths.addAll(paths);
  }

  Map<String, dynamic>? get getPathVariables => state.pathVariables;

  Map<String, dynamic>? get getValues => state.values;
}

final routerProvider =
    StateNotifierProvider<RouterNotifier, RouterState>((ref) {
  return RouterNotifier();
});
