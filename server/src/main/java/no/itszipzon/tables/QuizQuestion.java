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
import jakarta.persistence.Table;
import java.util.List;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

/**
 * QuizQuestion.
 */
@Entity
@Table(name = "quizQuestion")
public class QuizQuestion {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long quizQuestionId;

  @Column(nullable = false, name = "question")
  private String question;

  @ManyToOne
  @JoinColumn(name = "quizId", referencedColumnName = "quizId")
  @JsonBackReference
  @OnDelete(action = OnDeleteAction.CASCADE)
  private Quiz quiz;

  @OneToMany(mappedBy = "quizQuestion", cascade = CascadeType.ALL, orphanRemoval = true)
  @JsonManagedReference
  private List<QuizOption> quizOptions;

  public Long getQuizQuestionId() {
    return quizQuestionId;
  }

  public void setQuizQuestionId(Long quizQuestionId) {
    this.quizQuestionId = quizQuestionId;
  }

  public String getQuestion() {
    return question;
  }

  public void setQuestion(String question) {
    this.question = question;
  }

  public Quiz getQuiz() {
    return quiz;
  }

  public void setQuiz(Quiz quiz) {
    this.quiz = quiz;
  }

  public List<QuizOption> getQuizOptions() {
    return quizOptions;
  }

  public void setQuizOptions(List<QuizOption> quizOptions) {
    this.quizOptions = quizOptions;
  }

}
