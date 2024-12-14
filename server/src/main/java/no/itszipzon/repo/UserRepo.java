package no.itszipzon.repo;

import java.util.List;
import java.util.Optional;
import no.itszipzon.dto.UserDto;
import no.itszipzon.tables.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

/**
 * UserRepo.
 */
public interface UserRepo extends JpaRepository<User, Long> {

  @Query("SELECT u FROM User u WHERE u.username = :username")
  Optional<User> findUserByUsername(String username);

  @Query("SELECT u FROM User u WHERE u.username = :value OR u.email = :value")
  Optional<User> findUserByUsernameOrEmail(String value);

  @Query("""
      SELECT new no.itszipzon.dto.UserDto(u.userId, u.username)
      FROM User u
      WHERE
        u.username LIKE %:value%
      """)
  Optional<List<UserDto>> searchUsersByUsernameOrDisplayname(String value);

  @Query("""
      SELECT new no.itszipzon.dto.UserDto(u.userId, u.username, u.level, u.xp)
      FROM User u
      WHERE
        u.username = :username
      """)
  Optional<UserDto> getUserLevelAndXp(String username);

}
