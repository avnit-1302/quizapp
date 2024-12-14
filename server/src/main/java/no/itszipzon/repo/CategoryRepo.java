package no.itszipzon.repo;

import java.util.List;
import no.itszipzon.tables.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

/**
 * Repository for the Category table.
 */
public interface CategoryRepo extends JpaRepository<Category, Long> {
  @Query("SELECT c.name FROM Category c ORDER BY c.name ASC")
  List<String> findAllNames();

  @Query("SELECT c FROM Category c WHERE c.name = :name")
  Category findByName(String name);

  @Query("SELECT COUNT(qc) FROM QuizCategory qc WHERE qc.category.name = :categoryName")
  long countQuizzesByCategory(String categoryName);
}