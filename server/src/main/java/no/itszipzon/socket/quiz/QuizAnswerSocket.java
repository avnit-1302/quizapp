package no.itszipzon.socket.quiz;

/**
 * A class representing a quiz answer.
 */
public class QuizAnswerSocket {
  
  private Long id;
  private String answer;
  private int score;

  public QuizAnswerSocket() {
  }

  /**
   * Constructor for a quiz answer.
   *
   * @param id The id of the question.
   * @param answer The answer to the question.
   */
  public QuizAnswerSocket(String answer, Long id) {
    this.answer = answer;
    this.id = id;
  }

  public String getAnswer() {
    return answer;
  }

  public void setAnswer(String answer) {
    this.answer = answer;
  }

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public int getScore() {
    return score;
  }

  public void setScore(int score) {
    this.score = score;
  }

}
