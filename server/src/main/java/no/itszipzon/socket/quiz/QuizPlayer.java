package no.itszipzon.socket.quiz;

import java.util.ArrayList;
import java.util.List;

/**
 * A class representing a quiz player.
 */
public class QuizPlayer {
  
  private String username;
  private Long id;
  private List<QuizAnswerSocket> answers;
  private int score;
  private int amountOfCorrectAnswers;

  public QuizPlayer() {
  }

  /**
   * Constructor for a quiz player.
   *
   * @param username The username of the player.
   */
  public QuizPlayer(String username, Long id) {
    this.username = username;
    this.score = 0;
    this.id = id;
    this.answers = new ArrayList<>();
    this.amountOfCorrectAnswers = 0;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public List<QuizAnswerSocket> getAnswers() {
    return answers;
  }

  public void setAnswers(List<QuizAnswerSocket> answers) {
    this.answers = answers;
  }

  public int getScore() {
    return score;
  }

  public void setScore(int score) {
    this.score = score;
  }

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public int getAmountOfCorrectAnswers() {
    return amountOfCorrectAnswers;
  }

  public void setAmountOfCorrectAnswers(int amountOfCorrectAnswers) {
    this.amountOfCorrectAnswers = amountOfCorrectAnswers;
  }

}
