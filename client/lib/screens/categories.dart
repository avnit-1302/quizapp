import 'package:client/elements/card.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/router.dart';
import 'package:flutter/material.dart';
import 'package:client/elements/bottom_navbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A screen displaying a list of quiz categories.
/// Users can select a category from a dropdown menu or choose predefined categories from a grid.
class Categories extends ConsumerWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late RouterNotifier router = ref.watch(routerProvider.notifier);

    final List<String> gridCategoryNames = [
      "General Knowledge",
      "Pop Culture",
      "History",
      "Science"
    ];

    String? selectedCategory;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "I want to learn ....",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Dropdown Menu with Quiz Counts
            FutureBuilder<List<String>>(
              future: ApiHandler.getQuizCategories(),
              builder: (context, categorySnapshot) {
                if (categorySnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (categorySnapshot.hasError) {
                  return const Text("Error loading categories");
                }

                if (!categorySnapshot.hasData ||
                    categorySnapshot.data!.isEmpty) {
                  return const Text("No categories available");
                }

                final allCategories = categorySnapshot.data!;

                // Fetch counts for all categories
                return FutureBuilder<List<int>>(
                  future: Future.wait(
                    allCategories.map(
                      (category) => ApiHandler.getCategoryQuizCount(category),
                    ),
                  ),
                  builder: (context, countSnapshot) {
                    if (countSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (countSnapshot.hasError) {
                      return const Text("Error loading quiz counts");
                    }

                    final quizCounts = countSnapshot.data!;

                    return DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (newCategory) {
                        if (newCategory != null) {
                          selectedCategory = newCategory;
                          router.setPath(context, "category",
                              values: {"category": newCategory});
                        }
                      },
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text("Choose a Category"),
                        ),
                        ...allCategories
                            .asMap()
                            .entries
                            .map<DropdownMenuItem<String>>(
                          (entry) {
                            final category = entry.value;
                            final count = quizCounts[entry.key];
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text("$category ($count)"),
                            );
                          },
                        ).toList(),
                      ],
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      hint: const Text("Select Category"),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16.0),

            // Dynamic Grid for predefined categories
            Expanded(
              child: FutureBuilder<List<int>>(
                future: Future.wait(
                  gridCategoryNames.map(
                    (category) => ApiHandler.getCategoryQuizCount(category),
                  ),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("Error loading category quiz counts"));
                  }
                  final quizCounts = snapshot.data!;

                  return GridView.builder(
                    itemCount: gridCategoryNames.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => router.setPath(context, "category",
                            values: {"category": gridCategoryNames[index]}),
                        child: CategoryCard(
                          icon: _getCategoryIcon(gridCategoryNames[index]),
                          title: gridCategoryNames[index],
                          quizCount: quizCounts[index],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(path: "categories"),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case "General Knowledge":
        return Icons.star;
      case "Pop Culture":
        return Icons.movie;
      case "History":
        return Icons.history;
      case "Science":
        return Icons.science;
      default:
        return Icons.category;
    }
  }
}
