package no.itszipzon.tables;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.util.List;

/**
 * Holds all the categories.
 */
@Entity
@Table(name = "category")
public class Category {
  
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "categoryId")
  private Long categoryId;

  @Column(nullable = false, name = "name")
  private String name;

  @OneToMany(mappedBy = "category", cascade = CascadeType.ALL)
  @JsonManagedReference
  private List<QuizCategory> categories;


  public Long getCategoryId() {
    return categoryId;
  }

  public void setCategoryId(Long categoryId) {
    this.categoryId = categoryId;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public List<QuizCategory> getCategories() {
    return categories;
  }

  public void setCategories(List<QuizCategory> categories) {
    this.categories = categories;
  }

}
