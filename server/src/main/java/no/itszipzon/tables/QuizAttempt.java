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
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.List;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

/**
 * QuizAttempt.
 */
@Entity
@Table(name = "quizAttempt")
public class QuizAttempt {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long quizAttemptId;

  @Column(name = "expEarned", nullable = false)
  private int expEarned = 0;

  @ManyToOne(cascade = CascadeType.MERGE)
  @JoinColumn(name = "userId", referencedColumnName = "userId")
  @JsonBackReference
  private User user;

  @ManyToOne
  @JoinColumn(name = "quizId", referencedColumnName = "quizId")
  @JsonBackReference
  @OnDelete(action = OnDeleteAction.CASCADE)
  private Quiz quiz;

  @OneToMany(mappedBy = "quizAttempt", cascade = CascadeType.ALL, orphanRemoval = true)
  @JsonManagedReference
  private List<QuizSessionTable> quizSessions;

  @Column(name = "takenAt")
  private LocalDateTime takenAt;

  @OneToMany(mappedBy = "quizAttempt", cascade = CascadeType.ALL, orphanRemoval = true)
  @JsonManagedReference
  private List<QuizAnswer> quizAnswers;

  @PrePersist
  protected void onCreate() {
    LocalDateTime now = LocalDateTime.now();
    takenAt = now;
  }

  public Long getQuizAttemptId() {
    return quizAttemptId;
  }

  public void setQuizAttemptId(Long quizAttemptId) {
    this.quizAttemptId = quizAttemptId;
  }

  public User getUser() {
    return user;
  }

  public void setUser(User user) {
    this.user = user;
  }

  public Quiz getQuiz() {
    return quiz;
  }

  public void setQuiz(Quiz quiz) {
    this.quiz = quiz;
  }

  public LocalDateTime getTakenAt() {
    return takenAt;
  }

  public void setTakenAt(LocalDateTime takenAt) {
    this.takenAt = takenAt;
  }

  public List<QuizAnswer> getQuizAnswers() {
    return quizAnswers;
  }

  public void setQuizAnswers(List<QuizAnswer> quizAnswers) {
    this.quizAnswers = quizAnswers;
  }

  public List<QuizSessionTable> getQuizSessions() {
    return quizSessions;
  }

  public void setQuizSessions(List<QuizSessionTable> quizSessions) {
    this.quizSessions = quizSessions;
  }

  public int getExpEarned() {
    return expEarned;
  }

  public void setExpEarned(int expEarned) {
    this.expEarned = expEarned;
  }

}
