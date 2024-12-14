package no.itszipzon.tables;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.List;


/**
 * Quiz.
 */
@Entity
@Table(name = "quiz")
public class Quiz {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "quizId")
  private Long quizId;

  @Column(nullable = false, name = "title")
  private String title;

  @Column(nullable = false, name = "description")
  private String description;

  @Column(nullable = false, name = "thumbnail")
  private String thumbnail;

  @Column(nullable = false, name = "createdAt")
  private LocalDateTime createdAt;

  @Column(nullable = false, name = "updatedAt")
  private LocalDateTime updatedAt;

  @Column(nullable = false, name = "timer")
  private Integer timer = 0;

  @ManyToOne(cascade = CascadeType.MERGE)
  @JoinColumn(name = "userId", referencedColumnName = "userId")
  @JsonBackReference
  private User user;

  @OneToMany(mappedBy = "quiz", cascade = CascadeType.ALL, orphanRemoval = true)
  @JsonManagedReference
  private List<QuizQuestion> quizQuestions;

  @OneToMany(mappedBy = "quiz", cascade = CascadeType.ALL, orphanRemoval = true)
  @JsonManagedReference
  private List<QuizCategory> categories;

  @OneToMany(mappedBy = "quiz", cascade = CascadeType.ALL, orphanRemoval = true)
  @JsonManagedReference
  private List<QuizAttempt> quizAttempts;

  @OneToMany(mappedBy = "quiz", cascade = CascadeType.ALL, orphanRemoval = true)
  @JsonManagedReference
  private List<QuizSessionManagerTable> sessionManagers;

  @PrePersist
  protected void onCreate() {
    LocalDateTime now = LocalDateTime.now();
    createdAt = now;
    updatedAt = now;
  }

  @PreUpdate
  protected void onUpdate() {
    updatedAt = LocalDateTime.now();
  }

  public Long getQuizId() {
    return quizId;
  }

  public void setQuizId(Long quizId) {
    this.quizId = quizId;
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

  public LocalDateTime getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(LocalDateTime createdAt) {
    this.createdAt = createdAt;
  }

  public LocalDateTime getUpdatedAt() {
    return updatedAt;
  }

  public void setUpdatedAt(LocalDateTime updatedAt) {
    this.updatedAt = updatedAt;
  }

  public List<QuizQuestion> getQuizQuestions() {
    return quizQuestions;
  }

  public void setQuizQuestions(List<QuizQuestion> quizQuestions) {
    this.quizQuestions = quizQuestions;
  }

  public Integer getTimer() {
    return timer;
  }

  public void setTimer(Integer timer) {
    this.timer = timer;
  }

  public void setUser(User user) {
    this.user = user;
  }

  public User getUser() {
    return this.user;
  }

  public List<QuizCategory> getCategories() {
    return categories;
  }

  public void setCategories(List<QuizCategory> categories) {
    this.categories = categories;
  }

  public List<QuizAttempt> getQuizAttempts() {
    return quizAttempts;
  }

}
