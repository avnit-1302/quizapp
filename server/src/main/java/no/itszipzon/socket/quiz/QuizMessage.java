package no.itszipzon.socket.quiz;

import java.util.Map;

/**
 * A message object that carries data from the client to the server.
 */
public class QuizMessage {

  private int quizId;
  private String userToken;
  private String token;
  private Map<String, Object> message;

  public QuizMessage() {
  }

  public QuizMessage(int quizId) {
    this.quizId = quizId;
  }

  public int getQuizId() {
    return quizId;
  }

  public void setQuizId(int quizId) {
    this.quizId = quizId;
  }

  public String getUserToken() {
    return userToken;
  }

  public void setUserToken(String userToken) {
    this.userToken = userToken;
  }

  public String getToken() {
    return token;
  }

  public void setToken(String token) {
    this.token = token;
  }

  public Map<String, Object> getMessage() {
    return message;
  }

  public void setMessage(Map<String, Object> message) {
    this.message = message;
  }
  
}
