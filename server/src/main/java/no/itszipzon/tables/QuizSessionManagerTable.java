package no.itszipzon.tables;


import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.util.List;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

/**
 * Manages all the quizzes played by users against other users.
 */
@Entity
@Table(name = "quizSessionManager")
public class QuizSessionManagerTable {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long quizSessionManagerId;

  @OneToMany(mappedBy = "quizManager", cascade = CascadeType.ALL, orphanRemoval = true)
  @JsonManagedReference
  private List<QuizSessionTable> quizSessions;

  @ManyToOne
  @JoinColumn(name = "quizId", referencedColumnName = "quizId")
  @JsonBackReference
  @OnDelete(action = OnDeleteAction.CASCADE)
  private Quiz quiz;

  public Long getQuizSessionManagerId() {
    return quizSessionManagerId;
  }

  public void setQuizSessionManagerId(Long quizSessionManagerId) {
    this.quizSessionManagerId = quizSessionManagerId;
  }

  public List<QuizSessionTable> getQuizSessions() {
    return quizSessions;
  }

  public void setQuizSessions(List<QuizSessionTable> quizSessions) {
    this.quizSessions = quizSessions;
  }

  public Quiz getQuiz() {
    return quiz;
  }

  public void setQuiz(Quiz quiz) {
    this.quiz = quiz;
  }
}
