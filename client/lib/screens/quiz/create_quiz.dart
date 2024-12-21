import 'dart:io';

import 'package:client/elements/button.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/error_message.dart';
import 'package:client/tools/quiz.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateQuiz extends ConsumerStatefulWidget {
  const CreateQuiz({super.key});

  @override
  CreateQuizState createState() => CreateQuizState();
}

class CreateQuizState extends ConsumerState<CreateQuiz> {
  late final RouterNotifier router;
  late final UserNotifier user;
  int _selectedIndex = 0;
  bool loading = false;
  File? imageFile;
  late final List<String> categories;
  List<String> quizCategories = [];

  final List<Quiz> questions = [
    Quiz(question: "", options: [
      Option(optionText: ""),
      Option(optionText: ""),
    ])
  ];

  // Controllers for managing user input
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  TextEditingController questionController = TextEditingController();

  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);
      user = ref.read(userProvider.notifier);
    });
    _initCategories();
  }

  Future<void> _initCategories() async {
    categories = await ApiHandler.getQuizCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    timeController.dispose();
    questionController.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void showTitlePopup(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Title"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                        cursorColor: theme.primaryColor,
                        selectionColor: theme.primaryColor,
                      ),
                    ),
                    child: TextField(
                      controller: titleController,
                      maxLength: 30,
                      onChanged: (value) {
                        setState(() {}); // Update UI when text changes
                      },
                      decoration: InputDecoration(
                        hintText: "Enter title",
                        counterText:
                            "${titleController.text.length}/30 characters", // Character count
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                SmallTextButton(
                  text: "Save",
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showDescriptionPopup(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Description"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                        cursorColor: theme.primaryColor,
                        selectionColor: theme.primaryColor,
                      ),
                    ),
                    child: TextField(
                      controller: descriptionController,
                      maxLength: 254,
                      onChanged: (value) {
                        setState(() {}); // Update UI when text changes
                      },
                      decoration: InputDecoration(
                        hintText: "Enter description",
                        counterText:
                            "${descriptionController.text.length}/254 characters", // Character count
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      maxLines: 5,
                      minLines: 5,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                ],
              ),
              actions: [
                SmallTextButton(
                  text: "Save",
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showTimePopup(ThemeData theme) {
    List<int> timeOptions = [for (int i = 10; i <= 120; i += 5) i];

    int selectedTime = timeOptions.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Seconds to answer each question"),
              content: DropdownButton<int>(
                isExpanded: true,
                value: selectedTime,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedTime = newValue;
                    });
                  }
                },
                items: timeOptions.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value seconds"),
                  );
                }).toList(),
              ),
              actions: [
                SmallTextButton(
                  text: "Save",
                  onPressed: () {
                    setState(() {
                      timeController.text = selectedTime.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isValidTime() {
    if (timeController.text.isEmpty) return false;
    final int? timeValue = int.tryParse(timeController.text);
    return timeValue != null && timeValue > 0;
  }

  void showCategoriesPopup(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add categories"),
              content: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: theme.primaryColor,
                    selectionColor: theme.primaryColor,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      hint: const Text("Select category"),
                      items: categories
                          .where((value) => !quizCategories.contains(value))
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                          onTap: () {
                            setState(() {
                              quizCategories.add(value);
                            });
                          },
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        //
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: [
                            for (int i = 0; i < quizCategories.length; i++)
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Chip(
                                  label: Text(quizCategories[i]),
                                  onDeleted: () {
                                    setState(() {
                                      quizCategories.removeAt(i);
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                SmallTextButton(
                    text: "Save", onPressed: () => Navigator.pop(context)),
              ],
            );
          },
        );
      },
    );
  }

  void changeSelectedQuestion(int prev, int newIndex) {
    final prevQuiz = questions[prev];

    questions[prev] = Quiz(
      question: questionController.text,
      options: [
        for (int i = 0; i < prevQuiz.options.length; i++)
          Option(
            optionText: controllers[i].text,
            isCorrect: prevQuiz.options[i].isCorrect,
          ),
      ],
    );

    questionController.text = questions[newIndex].question;
    for (int i = 0; i < controllers.length; i++) {
      if (i < questions[newIndex].options.length) {
        controllers[i].text = questions[newIndex].options[i].optionText;
      } else {
        controllers[i].clear();
      }
    }

    setState(() {
      _selectedIndex = newIndex;
    });
  }

  void addOption(int index) {
    setState(() {
      questions[_selectedIndex].options.add(Option(optionText: ""));
    });
  }

  void _deleteQuestion(int index) {
    if (index == _selectedIndex) {
      if (questions.length == 1) {
        setState(() {
          questionController.clear();
          for (int i = 0; i < controllers.length; i++) {
            controllers[i].clear();
          }
          questions[0].options = [
            Option(optionText: ""),
            Option(optionText: ""),
          ];
        });
        return;
      } else if (index == questions.length - 1) {
        changeSelectedQuestion(_selectedIndex, _selectedIndex - 1);
        setState(() {
          questions.removeAt(index);
        });
      } else {
        setState(() {
          questions.removeAt(index);
        });
        changeSelectedQuestion(_selectedIndex, _selectedIndex);
      }
    } else {
      setState(() {
        questions.removeAt(index);
      });
    }
  }

  void _deleteOption(int index) {
    final prevQuiz = questions[_selectedIndex];
    questions[_selectedIndex] = Quiz(
      question: questionController.text,
      options: [
        for (int i = 0; i < prevQuiz.options.length; i++)
          Option(
            optionText: controllers[i].text,
            isCorrect: prevQuiz.options[i].isCorrect,
          ),
      ],
    );
    setState(() {
      if (questions[_selectedIndex].options.length > 2) {
        questions[_selectedIndex].options.removeAt(index);

        for (int i = 0; i < controllers.length; i++) {
          if (i < questions[_selectedIndex].options.length) {
            controllers[i].text =
                questions[_selectedIndex].options[i].optionText;
          } else {
            controllers[i].clear();
          }
        }
      } else {
        questions[_selectedIndex].options[index].optionText = "";
        controllers[index].text = "";
      }
    });
  }

  void addNewQuestion() {
    if (questions.length >= 25) {
      ErrorHandler.showOverlayError(context, "Maximum of 25 questions");
      return;
    }
    setState(() {
      questions.add(Quiz(question: "", options: [
        Option(optionText: ""),
        Option(optionText: ""),
      ]));
    });
    changeSelectedQuestion(_selectedIndex, _selectedIndex + 1);
  }

  Future<void> addImage() async {
    if (await Permission.photos.request().isGranted || Platform.isAndroid) {
      final ImagePicker picker = ImagePicker();
      try {
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          final allowedExtensions = ['jpg', 'jpeg', 'png'];
          final fileExtension = image.path.split('.').last.toLowerCase();

          if (allowedExtensions.contains(fileExtension)) {
            setState(() {
              imageFile = File(image.path);
            });
          } else {
            ErrorHandler.showOverlayError(
                context, "Please select a jpg, jpeg, or png image");
          }
        }
      } catch (e) {
        ErrorHandler.showOverlayError(context, "Failed to pick image");
      }
    } else {
      ErrorHandler.showOverlayError(context, "Permission denied");
    }
  }

  void createQuiz(int currentIndex) {
    if (loading) {
      ErrorHandler.showOverlayError(
          context, "Please wait for the current quiz to be created");
      return;
    }
    setState(() {
      loading = true;
    });

    final prevQuiz = questions[currentIndex];

    questions[currentIndex] = Quiz(
      question: questionController.text,
      options: [
        for (int i = 0; i < prevQuiz.options.length; i++)
          Option(
            optionText: controllers[i].text,
            isCorrect: prevQuiz.options[i].isCorrect,
          ),
      ],
    );

    if (titleController.text.isEmpty) {
      setState(() {
        loading = false;
      });
      ErrorHandler.showOverlayError(context, "Title cannot be empty");
      return;
    }

    if (titleController.text.length > 30) {
      setState(() {
        loading = false;
      });
      ErrorHandler.showOverlayError(
          context, "Title must be less than 50 chars");
      return;
    }

    if (descriptionController.text.isEmpty) {
      setState(() {
        loading = false;
      });
      ErrorHandler.showOverlayError(context, "Description cannot be empty");
      return;
    }

    if (timeController.text.isEmpty) {
      setState(() {
        loading = false;
      });
      ErrorHandler.showOverlayError(context, "Time cannot be empty");
      return;
    }
    int? timer;
    try {
      timer = int.parse(timeController.text);
    } catch (e) {
      setState(() {
        loading = false;
      });
      ErrorHandler.showOverlayError(
          context, "Please enter a valid integer for time");
    }

    if (timer! > 0 && timer < 5) {
      setState(() {
        loading = false;
      });
      ErrorHandler.showOverlayError(
          context, "Time must be greater than 5 seconds or 0");
      return;
    }

    if (timer > 120) {
      setState(() {
        loading = false;
      });
      ErrorHandler.showOverlayError(
          context, "Time must be less than 120 seconds");
      return;
    }

    if (quizCategories.isEmpty) {
      setState(() {
        loading = false;
      });
      ErrorHandler.showOverlayError(
          context, "Please select at least one category");
      return;
    }

    for (var question in questions) {
      if (question.question.isEmpty) {
        setState(() {
          loading = false;
        });
        ErrorHandler.showOverlayError(context, "Question cannot be empty");
        return;
      }

      if (question.options.length < 2) {
        setState(() {
          loading = false;
        });
        ErrorHandler.showOverlayError(context, "Question must have 2 options");
        return;
      }

      bool isCorrect = false;
      for (var option in question.options) {
        if (option.optionText.isEmpty) {
          setState(() {
            loading = false;
          });
          ErrorHandler.showOverlayError(context, "Option cannot be empty");
          return;
        }

        if (option.isCorrect) {
          isCorrect = true;
        }
      }

      if (!isCorrect) {
        setState(() {
          loading = false;
        });
        ErrorHandler.showOverlayError(
            context, "Please select a correct option");
        return;
      }
    }

    if (imageFile == null) {
      setState(() {
        loading = false;
      });
      ErrorHandler.showOverlayError(context, "Please select an image");
      return;
    }

    Map<String, dynamic> quiz = {
      "title": titleController.text,
      "description": descriptionController.text,
      "timer": int.parse(timeController.text),
      "categories": quizCategories,
      "quizQuestions": [
        for (int i = 0; i < questions.length; i++)
          {
            "question": questions[i].question,
            "quizOptions": [
              for (int j = 0; j < questions[i].options.length; j++)
                {
                  "optionText": questions[i].options[j].optionText,
                  "correct": questions[i].options[j].isCorrect,
                }
            ],
          }
      ],
    };

    ApiHandler.createQuiz(quiz, user.token!, imageFile!).then((response) {
      if (response.statusCode == 201) {
        if (response.body == "true") {
          setState(() {
            loading = false;
          });
          router.setPath(context, "profile");
        } else {
          setState(() {
            loading = false;
          });
          ErrorHandler.showOverlayError(context, "Failed to create quiz");
        }
      } else {
        setState(() {
          loading = false;
        });
        ErrorHandler.showOverlayError(context, "Error creating quiz");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const topButtonTextStyle = TextStyle(color: Colors.white, fontSize: 12);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedTextButton(
                  textStyle: topButtonTextStyle,
                  height: 30,
                  text: "Add title",
                  onPressed: () => showTitlePopup(theme)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedTextButton(
                  textStyle: topButtonTextStyle,
                  height: 30,
                  text: "Add desc",
                  onPressed: () => showDescriptionPopup(theme)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedTextButton(
                  textStyle: topButtonTextStyle,
                  height: 30,
                  text: "Add time",
                  onPressed: () => showTimePopup(theme)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedTextButton(
                  textStyle: topButtonTextStyle,
                  height: 30,
                  text: "Categories",
                  onPressed: () => showCategoriesPopup(theme)),
            ),
            IconButton(
                onPressed: () => router.goBack(context),
                icon: const Icon(Icons.close)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            imageFile != null
                ? GestureDetector(
                    onTap: addImage,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                      child: Image.file(
                        imageFile!,
                        height: 162,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: addImage,
                    child: Container(
                      height: 162,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 217, 217, 217),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            Text("Add Image"),
                          ],
                        ),
                      ),
                    ),
                  ),
            Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: theme.primaryColor,
                  selectionColor: theme.primaryColor,
                ),
              ),
              child: TextField(
                enabled: !loading,
                controller: questionController,
                cursorColor: theme.primaryColor,
                decoration: const InputDecoration(
                  hintText: "Enter question",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    borderSide: BorderSide(
                      color: Colors.orange,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: questions[_selectedIndex].options.length,
                itemBuilder: (context, index) {
                  if (index >= controllers.length) {
                    controllers.add(TextEditingController());
                  }
                  return Column(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: TextSelectionThemeData(
                            cursorColor: theme.primaryColor,
                            selectionColor: theme.primaryColor,
                          ),
                        ),
                        child: TextField(
                          enabled: !loading,
                          controller: controllers[index],
                          cursorColor: theme.primaryColor,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("${index + 1}."),
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(
                                      () {
                                        questions[_selectedIndex]
                                            .options[index]
                                            .setIsCorrect(
                                              !questions[_selectedIndex]
                                                  .options[index]
                                                  .isCorrect,
                                            );
                                      },
                                    ),
                                    child: questions[_selectedIndex]
                                            .options[index]
                                            .isCorrect
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          )
                                        : const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _deleteOption(index),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      index < questions[_selectedIndex].options.length
                          ? const SizedBox(height: 5)
                          : const SizedBox(height: 0),
                      questions[_selectedIndex].options.length < 5 &&
                              index ==
                                  questions[_selectedIndex].options.length - 1
                          ? Center(
                              child: SmallTextButton(
                                text: "Add new option",
                                onPressed: () => addOption(_selectedIndex),
                              ),
                            )
                          : const SizedBox(height: 0),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            color: theme.canvasColor,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (int i = 0; i < questions.length; i++)
                          Padding(
                            padding: i == 0
                                ? const EdgeInsets.only(
                                    right: 8.0, top: 8.0, bottom: 8.0)
                                : const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () =>
                                  changeSelectedQuestion(_selectedIndex, i),
                              child: Container(
                                height: 30,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: i == _selectedIndex
                                      ? Colors.orange
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    "Question ${i + 1}",
                                    style: TextStyle(
                                      color: i == _selectedIndex
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      width: 50,
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          addNewQuestion();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      width: 50,
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteQuestion(_selectedIndex);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              width: double.infinity,
              child: SizedTextButton(
                  text: "Save",
                  onPressed: () => createQuiz(_selectedIndex),
                  height: 40,
                  textStyle: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
