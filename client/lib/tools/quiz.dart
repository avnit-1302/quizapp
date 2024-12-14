
/// This file contains the Quiz and Option classes which are used to store the quiz data.
class Quiz {
  String question;
  List<Option> options;

  /// Constructor
  Quiz({required this.question, required this.options});

  /// Convert JSON to Quiz object
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      question: json['question'],
      options: List<Option>.from(json['options']),
    );
  }

  /// Convert Quiz object to JSON
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
    };
  }

  /// Getters and setters
  List<Option> getOptions() {
    return options;
  }

  String getQuestion() {
    return question;
  }

  void setQuestion(String question) {
    this.question = question;
  }

  void setOptions(List<Option> options) {
    this.options = options;
  }

  void addOption(Option option) {
    options.add(option);
  }
}

/// Option class
class Option {
  String optionText;
  bool isCorrect;

  /// Constructor
  Option({required this.optionText, this.isCorrect = false});

  /// Convert JSON to Option object
  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      optionText: json['optionText'],
      isCorrect: json['isCorrect'],
    );
  }

  /// Convert Option object to JSON
  Map<String, dynamic> toJson() {
    return {
      'optionText': optionText,
      'isCorrect': isCorrect,
    };
  }

  /// Getters and setters
  String getOption() {
    return optionText;
  }

  void setOption(String optionText) {
    this.optionText = optionText;
  }

  void setIsCorrect(bool isCorrect) {
    this.isCorrect = isCorrect;
  }

  bool getIsCorrect() {
    return isCorrect;
  }
}