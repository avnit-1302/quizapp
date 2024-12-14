package no.itszipzon.dto;

import java.time.LocalDateTime;
import java.util.List;

/**
 * QuizDto.
 */
public class QuizWithQuestionsDto {

  private long id;
  private String title;
  private String description;
  private String thumbnail;
  private Integer timer;
  private List<QuizQuestionDto> quizQuestions;
  private String username;
  private LocalDateTime createdAt;

  /**
   * QuizDto.
   *
   * @param id            id.
   * @param title         title.
   * @param description   description.
   * @param thumbnail     thumbnail.
   * @param timer         timer.
   * @param quizQuestions quizQuestions.
   */
  public QuizWithQuestionsDto(long id, String title, String description, String thumbnail,
      Integer timer, LocalDateTime createdAt, List<QuizQuestionDto> quizQuestions) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.thumbnail = thumbnail;
    this.timer = timer;
    this.createdAt = createdAt;
    this.quizQuestions = quizQuestions;
  }

  /**
   * QuizDto.
   *
   * @param id            id.
   * @param title         title.
   * @param description   description.
   * @param thumbnail     thumbnail.
   * @param timer         timer.
   * @param quizQuestions quizQuestions.
   * @param username      username.
   */
  public QuizWithQuestionsDto(
      long id,
      String title,
      String description,
      String thumbnail,
      Integer timer,
      LocalDateTime createdAt,
      List<QuizQuestionDto> quizQuestions,
      String username) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.thumbnail = thumbnail;
    this.timer = timer;
    this.createdAt = createdAt;
    this.quizQuestions = quizQuestions;
    this.username = username;
  }

  public long getId() {
    return id;
  }

  public void setId(long id) {
    this.id = id;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public String getThumbnail() {
    return thumbnail;
  }

  public void setThumbnail(String thumbnail) {
    this.thumbnail = thumbnail;
  }

  public Integer getTimer() {
    return timer;
  }

  public void setTimer(Integer timer) {
    this.timer = timer;
  }

  public List<QuizQuestionDto> getQuizQuestions() {
    return quizQuestions;
  }

  public void setQuizQuestions(List<QuizQuestionDto> quizQuestions) {
    this.quizQuestions = quizQuestions;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public LocalDateTime getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(LocalDateTime createdAt) {
    this.createdAt = createdAt;
  }
}