package no.itszipzon.socket.quiz;

import java.time.LocalDateTime;

/**
 * A class representing a quiz in session.
 */
public class QuizInSession {

  private long id;
  private String title;
  private String description;
  private String thumbnail;
  private int timer;
  private String username;
  private LocalDateTime createdAt;

  public QuizInSession() {
  }

  /**
   * Constructor for a quiz in session.
   *
   * @param id          id.
   * @param title       title.
   * @param description description.
   * @param thumbnail   thumbnail.
   * @param timer       timer.
   * @param username    username.
   * @param createdAt   createdAt.
   */
  public QuizInSession(long id, String title, String description, String thumbnail, Integer timer,
      LocalDateTime createdAt, String username) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.thumbnail = thumbnail;
    this.timer = timer;
    this.createdAt = createdAt;
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
