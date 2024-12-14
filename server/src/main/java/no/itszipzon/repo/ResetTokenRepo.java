package no.itszipzon.repo;

import java.util.Optional;
import no.itszipzon.tables.ResetToken;
import no.itszipzon.tables.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * Repository for ResetToken.
 */
public interface ResetTokenRepo extends JpaRepository<ResetToken, Long> {

  Optional<ResetToken> findByToken(String token);

  void deleteByUser_UserId(Long userId);

  Optional<ResetToken> findByUser_UserIdAndValidTrue(Long userId);

  @Modifying
  @Query("DELETE FROM ResetToken rt WHERE rt.user = :user")
  void deleteByUser(@Param("user") User user);
}
