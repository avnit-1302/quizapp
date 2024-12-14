package no.itszipzon.repo;

import java.util.List;
import no.itszipzon.tables.QuizOption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

/**
 * QuizOptionRepo.
 */
public interface QuizOptionRepo extends JpaRepository<QuizOption, Long> {

  List<QuizOption> findByQuizQuestionQuizQuestionId(Long quizQuestionId);

  @Query("""
      SELECT qo.quizOptionId FROM QuizOption qo
      JOIN qo.quizQuestion qq
      WHERE qq.quizQuestionId = :questionId
        AND qo.correct = false
      """)
  List<Long> findWrongOptionFromQuestion(long questionId);
}
