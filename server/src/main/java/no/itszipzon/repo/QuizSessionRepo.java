package no.itszipzon.repo;

import no.itszipzon.tables.QuizSessionManagerTable;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * QuizSessionRepo.
 */
public interface QuizSessionRepo extends JpaRepository<QuizSessionManagerTable, Long> {

  
}
