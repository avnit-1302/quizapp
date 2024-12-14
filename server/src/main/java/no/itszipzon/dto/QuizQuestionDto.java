package no.itszipzon.dto;

import java.util.List;

/**
 * QuizQuestionDto.
 */
public class QuizQuestionDto {

  private long id;
  private String question;
  private List<QuizOptionDto> quizOptions;

  public QuizQuestionDto(long id, String question) {
    this.id = id;
    this.question = question;
  }

  /**
   * QuizQuestionDto.
   *
   * @param id id.
   * @param question question.
   * @param quizOptions quizOptions.
   */
  public QuizQuestionDto(long id, String question, List<QuizOptionDto> quizOptions) {
    this.id = id;
    this.question = question;
    this.quizOptions = quizOptions;
  }

  public long getId() {
    return id;
  }

  public void setId(long id) {
    this.id = id;
  }

  public String getQuestion() {
    return question;
  }

  public void setQuestion(String question) {
    this.question = question;
  }

  public List<QuizOptionDto> getQuizOptions() {
    return quizOptions;
  }

  public void setQuizOptions(List<QuizOptionDto> quizOptions) {
    this.quizOptions = quizOptions;
  }
}
