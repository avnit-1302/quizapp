import 'package:client/elements/bottom_navbar.dart';
import 'package:client/elements/quiz_post.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A screen that displays quizzes filtered by category.
/// Users can select a category from a dropdown and view a list of quizzes.
class Category extends ConsumerStatefulWidget {
  const Category({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CategoryState();
}

class CategoryState extends ConsumerState<Category> {
  late final RouterNotifier router;
  bool loading = true;

  late List<Map<String, dynamic>> quizzes;
  List<String> allCategories = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);

      _fetchCategories();
    });
  }

  /// Fetches all available categories from the server.
  ///
  /// Sets the initial category to the one provided in the router or the first available category.
  /// Then fetches quizzes for the selected category.
  Future<void> _fetchCategories() async {
    try {
      List<String> categories = await ApiHandler.getQuizCategories();
      setState(() {
        allCategories = categories;
        selectedCategory = router.getValues?["category"] ?? categories.first;
        _initiateQuizzes();
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error fetching categories: $e");
    }
  }

  /// Fetches quizzes for the currently selected category.
  ///
  /// Updates the list of quizzes and toggles the loading state.
  Future<void> _initiateQuizzes() async {
    setState(() {
      loading = true;
    });
    try {
      List<Map<String, dynamic>> quizList =
          await ApiHandler.getQuizzesByCategory(selectedCategory!, 0);
      setState(() {
        quizzes = quizList;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error fetching quizzes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quizzes by Category"),
      ),
      body: Column(
        children: [
          if (allCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedCategory,
                onChanged: (newCategory) {
                  if (newCategory != null) {
                    setState(() {
                      selectedCategory = newCategory;
                    });
                    _initiateQuizzes();
                  }
                },
                items: allCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                isExpanded: true,
                hint: const Text("Select a Category"),
              ),
            ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : quizzes.isEmpty
                    ? const Center(child: Text("No quizzes available"))
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = quizzes[index];

                          return QuizPost(
                            id: quiz["id"],
                            profilePicture: quiz["profilePicture"] ?? "",
                            title: quiz["title"],
                            username: quiz["username"],
                            createdAt: quiz["createdAt"],
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(path: "categories"),
    );
  }
}
