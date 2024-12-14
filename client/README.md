# client

A new Flutter project.

### Router
If you only want to route to another page. Simply use 
``` dart
// with stateless widget
Class {Your class} extends ConsumerWidget {
   @override
   Widget build(BuildContext context, WidgetRef ref) {
      final router = ref.read(routerProvider.notifier);
      final user = ref.read(userProvider.notifier)
   }
}

// With stateful widget
class {Your class} extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  {Your class} createState() => {Your class}();
}

class {Your state class} extends ConsumerState<Home> {
  late final RouterNotifier router;
  late final UserNotifier user;
}
``` 
### Installation
1. Clone the repository:
   ```bash
   cd [your-project-folder]
   git clone git@github.com:Itszipzon/mobileapplication_2024.git
   ```

2. If this is your first time running the project, make sure to install the necessary dependencies:
   ```bash
   cd client
   flutter pub get
   ```

### Running the Project

1. Navigate to the client directory:
   ```bash
    cd client
   ```
2. To run the project, use the following command:
   ```bash
   flutter run -d chrome
   ```