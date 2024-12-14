package no.itszipzon.socket.quiz;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import no.itszipzon.dto.QuizQuestionDto;
import no.itszipzon.dto.QuizWithQuestionsDto;

/**
 * A class that represents a quiz session.
 */
public class QuizSession {

  private long quizId;
  private String leaderUsername;
  private List<QuizPlayer> players;
  private QuizWithQuestionsDto quiz;
  private String message;
  private String token;
  private boolean isStarted;
  private int currentQuestionIndex;
  private int amountOfQuestions;
  private String state;
  private List<Long> lastCorrectAnswers;
  private LocalDateTime questionStartTime;

  public QuizSession() {

  }

  /**
   * Constructor for a quiz session.
   *
   * @param leaderUsername The username of the leader.
   * @param quizId         The ID of the quiz.
   */
  public QuizSession(String leaderUsername, int quizId) {
    this.leaderUsername = leaderUsername;
    this.quizId = quizId;
    this.players = new ArrayList<>();
    this.isStarted = false;
    this.currentQuestionIndex = 0;
    this.amountOfQuestions = 0;
    this.state = "WAITING";
    this.lastCorrectAnswers = new ArrayList<>();
  }

  public long getQuizId() {
    return quizId;
  }

  public void setQuizId(long quizId) {
    this.quizId = quizId;
  }

  public String getLeaderUsername() {
    return leaderUsername;
  }

  public void setLeaderUsername(String leaderUsername) {
    this.leaderUsername = leaderUsername;
  }

  public List<QuizPlayer> getPlayers() {
    return players;
  }

  public void setPlayers(List<QuizPlayer> players) {
    this.players = players;
  }

  /**
   * Adds a player to the quiz session.
   *
   * @param player The player.
   */
  public void addPlayer(QuizPlayer player) {
    if (this.players.stream().anyMatch(p -> p.getUsername().equals(player.getUsername()))) {
      return;
    }
    this.players.add(player);
  }

  public void addPlayer(String playerName, Long id) {
    this.players.add(new QuizPlayer(playerName, id));
  }

  public void removePlayer(QuizPlayer player) {
    this.players.remove(player);
  }

  /**
   * Adds a player to the quiz session.
   *
   * @param playerName The username of the player.
   */
  public void removePlayer(String playerName) {
    players.removeIf(player -> player.getUsername().equals(playerName));
  }

  public QuizWithQuestionsDto getQuiz() {
    return quiz;
  }

  /**
   * Sets the quiz for the quiz session.
   *
   * @param quiz The quiz.
   */
  public void setQuiz(QuizWithQuestionsDto quiz) {
    for (QuizQuestionDto question : quiz.getQuizQuestions()) {
      Collections.shuffle(question.getQuizOptions());
    }
    this.quiz = quiz;
    this.amountOfQuestions = quiz.getQuizQuestions().size();
  }

  public String getMessage() {
    return message;
  }

  public void setMessage(String message) {
    this.message = message;
  }

  public String getToken() {
    return token;
  }

  public void setToken(String token) {
    this.token = token;
  }

  public boolean isStarted() {
    return isStarted;
  }

  public void setStarted(boolean started) {
    isStarted = started;
  }

  public int getCurrentQuestionIndex() {
    return currentQuestionIndex;
  }

  public void setCurrentQuestionIndex(int currentQuestionIndex) {
    this.currentQuestionIndex = currentQuestionIndex;
  }

  public void incrementCurrentQuestionIndex() {
    this.currentQuestionIndex++;
  }

  /**
   * Gets the current question.
   *
   * @return The current question.
   */
  public QuizQuestionDto getCurrentQuestion() {
    if (quiz == null) {
      return null;
    }
    if (currentQuestionIndex >= quiz.getQuizQuestions().size()) {
      return null;
    }
    return quiz.getQuizQuestions().get(currentQuestionIndex);
  }

  public int getAmountOfQuestions() {
    return amountOfQuestions;
  }

  public void setAmountOfQuestions(int amountOfQuestions) {
    this.amountOfQuestions = amountOfQuestions;
  }

  public String getState() {
    return state;
  }

  public void setState(String state) {
    this.state = state;
  }

  public List<Long> getLastCorrectAnswers() {
    return lastCorrectAnswers;
  }

  public void setLastCorrectAnswers(List<Long> lastCorrectAnswers) {
    this.lastCorrectAnswers = lastCorrectAnswers;
  }

  public void initQuestionStartTime() {
    System.out.println("Init question start time");
    this.questionStartTime = LocalDateTime.now();
  }

  public double getQuestionTime() {
    Duration duration = questionStartTime == null ? Duration.ofSeconds(1) : Duration.between(questionStartTime, LocalDateTime.now());
    return duration.toMillis() / 1000;
  }

}
