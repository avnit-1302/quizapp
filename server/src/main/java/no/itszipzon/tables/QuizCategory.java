package no.itszipzon.tables;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.CascadeType;
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
 * Holds the relationship between a quiz and a category.
 */
@Entity
@Table(name = "quizCategory")
public class QuizCategory {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "quizCategoryId")
  private Long quizCategoryId;

  @ManyToOne(cascade = CascadeType.MERGE)
  @JoinColumn(name = "categoryId", referencedColumnName = "categoryId")
  @JsonBackReference
  private Category category;

  @ManyToOne
  @JoinColumn(name = "quizId", referencedColumnName = "quizId")
  @JsonBackReference
  @OnDelete(action = OnDeleteAction.CASCADE)
  private Quiz quiz;

  public Long getQuizCategoryId() {
    return quizCategoryId;
  }

  public void setQuizCategoryId(Long quizCategoryId) {
    this.quizCategoryId = quizCategoryId;
  }

  public Category getCategory() {
    return category;
  }

  public void setCategory(Category category) {
    this.category = category;
  }

  public Quiz getQuiz() {
    return quiz;
  }

  public void setQuiz(Quiz quiz) {
    this.quiz = quiz;
  }

}
