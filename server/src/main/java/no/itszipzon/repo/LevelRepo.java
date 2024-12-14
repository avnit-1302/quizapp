package no.itszipzon.repo;

import java.util.Optional;
import no.itszipzon.tables.Level;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

/**
 * Repository interface for the Level table.
 */
public interface LevelRepo extends JpaRepository<Level, Integer> {
  
  @Query("SELECT l FROM Level l WHERE l.level = :level")
  Optional<Level> getLevel(int level);

}
