package no.itszipzon.tables;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

/**
 * When a user played a quiz against other users.
 */
@Entity
@Table(name = "quizSession")
public class QuizSessionTable {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long quizSessionId;

  @ManyToOne
  @JoinColumn(name = "userId", referencedColumnName = "userId")
  @JsonBackReference
  private User user;

  @ManyToOne(cascade = { CascadeType.MERGE, CascadeType.REMOVE })
  @JoinColumn(name = "quizManagerId", referencedColumnName = "quizSessionManagerId")
  @JsonBackReference
  private QuizSessionManagerTable quizManager;

  @ManyToOne
  @JoinColumn(name = "quizAttemptId", referencedColumnName = "quizAttemptId")
  @JsonBackReference
  @OnDelete(action = OnDeleteAction.CASCADE)
  private QuizAttempt quizAttempt;

  public Long getQuizSessionId() {
    return quizSessionId;
  }

  public void setQuizSessionId(Long quizSessionId) {
    this.quizSessionId = quizSessionId;
  }

  public User getUser() {
    return user;
  }

  public void setUser(User user) {
    this.user = user;
  }

  public QuizSessionManagerTable getQuizManager() {
    return quizManager;
  }

  public void setQuizManager(QuizSessionManagerTable quizManager) {
    this.quizManager = quizManager;
  }

  public QuizAttempt getQuizAttempt() {
    return quizAttempt;
  }

  public void setQuizAttempt(QuizAttempt quizAttempt) {
    this.quizAttempt = quizAttempt;
  }
}
