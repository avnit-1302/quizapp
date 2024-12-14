import 'package:client/elements/button.dart';
import 'package:client/tools/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bottom navigation bar widget used for navigating between different app sections.
class BottomNavbar extends ConsumerWidget {
  final String path;

  /// Constructs the BottomNavbar with the provided [path].
  const BottomNavbar({super.key, required this.path});

  /// Handles navigation when a navigation button is pressed.
  /// Updates the [RouterNotifier] with the selected [path].
  void onPressed(BuildContext context, String path, RouterNotifier router) {
    router.setPath(context, path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider.notifier);
    final theme = Theme.of(context);
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: theme.canvasColor,
        border: const Border(
          top: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 492,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: IconTextButton(
                  icon: Icons.local_fire_department,
                  text: "Feed",
                  onPressed: () => onPressed(context, "home", router),
                  active: path == "home",
                ),
              ),
              Expanded(
                child: IconTextButton(
                  icon: Icons.grid_view,
                  text: "Categories",
                  onPressed: () => onPressed(context, "categories", router),
                  active: path == "categories",
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: BigIconButton(
                  height: 56,
                  width: 56,
                  icon: Icons.add,
                  onPressed: () => onPressed(context, "create", router),
                ),
              ),
              Expanded(
                child: IconTextButton(
                  icon: Icons.play_arrow_rounded,
                  text: "Join Game",
                  onPressed: () => onPressed(context, "join", router),
                  active: path == "join",
                ),
              ),
              Expanded(
                child: IconTextButton(
                  icon: Icons.person,
                  text: "Profile",
                  onPressed: () => onPressed(context, "profile", router),
                  active: path == "profile",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
