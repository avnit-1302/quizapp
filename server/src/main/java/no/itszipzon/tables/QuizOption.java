package no.itszipzon.tables;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.Column;
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
 * Option for a quiz question.
 */
@Entity
@Table(name = "quizOption")
public class QuizOption {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "quizOptionId")
  private Long quizOptionId;

  @Column(nullable = false, name = "optionText")
  private String optionText;

  @Column(nullable = false, name = "correct")
  private boolean correct;

  @ManyToOne
  @JoinColumn(name = "quizQuestionId", referencedColumnName = "quizQuestionId")
  @JsonBackReference
  @OnDelete(action = OnDeleteAction.CASCADE)
  private QuizQuestion quizQuestion;

  public Long getQuizOptionId() {
    return quizOptionId;
  }

  public void setQuizOptionId(Long quizOptionId) {
    this.quizOptionId = quizOptionId;
  }

  public String getOptionText() {
    return optionText;
  }

  public void setOptionText(String optionText) {
    this.optionText = optionText;
  }

  public boolean isCorrect() {
    return correct;
  }

  public void setCorrect(boolean correct) {
    this.correct = correct;
  }

  public QuizQuestion getQuizQuestion() {
    return quizQuestion;
  }

  public void setQuizQuestion(QuizQuestion quizQuestion) {
    this.quizQuestion = quizQuestion;
  }

}
