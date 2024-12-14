import 'package:client/tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget representing a solo quiz question.
/// Displays a question, its options, and manages user interaction.
class QuizQuestionSolo extends ConsumerStatefulWidget {
  const QuizQuestionSolo(
      {super.key,
      required this.quizId,
      required this.questionText,
      required this.options,
      required this.onOptionTap,
      required this.onNextTap,
      required this.totalQuestions,
      required this.currentQuestionIndex});

  final int quizId;
  final String questionText;
  final List<Map<String, dynamic>> options;
  final Function onOptionTap;
  final Function onNextTap;

  final int totalQuestions;
  final int currentQuestionIndex;

  @override
  QuizQuestionSoloState createState() => QuizQuestionSoloState();
}

class QuizQuestionSoloState extends ConsumerState<QuizQuestionSolo> {
  String? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (widget.currentQuestionIndex + 1) / widget.totalQuestions;
    final questionText = Tools.fixEncoding(widget.questionText);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                final optionText =
                    Tools.fixEncoding(widget.options[index]["option"]);
                final isSelected = selectedAnswer == optionText;
                final isSelectedOrNoAnswer =
                    isSelected || selectedAnswer == null;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAnswer = optionText;
                    });
                    widget.onOptionTap(optionText, widget.options[index]["id"]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelectedOrNoAnswer
                          ? Colors.white
                          : Colors.grey[200],
                      border: Border.all(
                          color: isSelectedOrNoAnswer
                              ? theme.primaryColor
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          child: Text(
                            optionText,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: selectedAnswer != null ? () => widget.onNextTap() : null,
            child: Text(
              widget.currentQuestionIndex == widget.totalQuestions - 1
                  ? "Finish Quiz"
                  : "Next",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${widget.currentQuestionIndex + 1} of ${widget.totalQuestions}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
