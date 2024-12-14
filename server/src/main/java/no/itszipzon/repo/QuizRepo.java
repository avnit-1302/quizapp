package no.itszipzon.repo;

import java.util.List;
import java.util.Optional;
import no.itszipzon.dto.QuizDto;
import no.itszipzon.tables.Quiz;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * QuizRepo.
 */
public interface QuizRepo extends JpaRepository<Quiz, Long> {
  @SuppressWarnings("null")
  @EntityGraph(attributePaths = { "quizQuestions" })
  List<Quiz> findAll();

  @Query("""
      SELECT new no.itszipzon.dto.QuizDto(q.quizId, q.title, q.description, q.thumbnail, q.timer,
                                           u.username, u.profilePicture, q.createdAt)
      FROM Quiz q
        JOIN q.user u
      """)
  Optional<List<QuizDto>> findAllByFilter(Pageable pageable);

  @Query("""
      SELECT new no.itszipzon.dto.QuizDto(q.quizId, q.title, q.description, q.thumbnail, q.timer,
                                           u.username, u.profilePicture, q.createdAt)
      FROM Quiz q JOIN q.user u
      """)
  List<QuizDto> findAllQuizzesSummary();

  @Query("""
      SELECT new no.itszipzon.dto.QuizDto(q.quizId, q.title, q.description, q.thumbnail, q.timer,
                                           u.username, u.profilePicture, q.createdAt, u.userId)
      FROM Quiz q JOIN q.user u
      WHERE q.quizId = :id
      """)
  Optional<QuizDto> findQuizSummaryById(Long id);

  @EntityGraph(attributePaths = {"quizQuestions.quizOptions", "user"})
  Optional<Quiz> findById(Long id);

  @Query("""
      SELECT u.username
      FROM Quiz q JOIN q.user u
      WHERE q.quizId = :id
      """)
  Optional<String> findUsernameFromQuizId(Long id);

  @Query("""
      SELECT new no.itszipzon.dto.QuizDto(q.quizId, q.title, q.description, q.thumbnail, q.timer,
                                           u.username, u.profilePicture, q.createdAt)
      FROM Quiz q JOIN q.user u
      WHERE u.username = :username
      ORDER BY q.createdAt DESC
      """)
  Optional<List<QuizDto>> findQuizHistoryByUsername(String username, Pageable pageable);

  @Query("""
      SELECT new no.itszipzon.dto.QuizDto(q.quizId, q.title, q.description, q.thumbnail, q.timer,
                                           u.username, u.profilePicture, q.createdAt)
      FROM Quiz q JOIN q.user u
      WHERE u.username = :username
      ORDER BY q.createdAt DESC
      """)
  Optional<List<QuizDto>> findUsersQuizzes(String username, Pageable pageable);

  @Query("""
      SELECT new no.itszipzon.dto.QuizDto(q.quizId, q.title, q.description, q.thumbnail, q.timer,
                                           u.username, u.profilePicture, q.createdAt)
      FROM Quiz q
        JOIN q.user u
        JOIN q.categories qc
      WHERE qc.category.name = :category
        ORDER BY q.createdAt DESC
      """)
  Optional<List<QuizDto>> findQuizzesByCategory(String category, Pageable pageable);

  @Query("SELECT COUNT(q) FROM Quiz q WHERE :category MEMBER OF q.categories")
  int countQuizzesInCategory(@Param("category") String category);


}
