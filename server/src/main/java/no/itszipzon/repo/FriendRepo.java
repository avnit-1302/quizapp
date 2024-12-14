package no.itszipzon.repo;

import java.util.List;
import java.util.Optional;
import no.itszipzon.dto.FriendDto;
import no.itszipzon.tables.Friend;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * Repository for the Friend table.
 */
public interface FriendRepo extends JpaRepository<Friend, Long> {
  @Query("""
          SELECT new no.itszipzon.dto.FriendDto(
              f.friendId,
              CASE
                  WHEN f.user.username = :username THEN f.friendUser.username
                  ELSE f.user.username
              END,
              f.status,
              f.createdAt,
              f.acceptedAt,
                  CASE
                      WHEN f.user.username = :username THEN f.friendUser.lastLoggedIn
                      ELSE f.user.lastLoggedIn
                  END,
              CASE
                  WHEN f.user.username = :username THEN f.friendUser.profilePicture
                  ELSE f.user.profilePicture
              END
          )
          FROM Friend f
          WHERE (f.user.username = :username OR f.friendUser.username = :username)
          AND f.status = 'ACCEPTED'
      """)
  List<FriendDto> findUserFriends(@Param("username") String username);

  @Query("""
          SELECT new no.itszipzon.dto.FriendDto(
              f.friendId,
              f.user.username,
              f.status,
              f.createdAt,
              f.acceptedAt,
              f.user.lastLoggedIn,
              f.user.profilePicture
          )
          FROM Friend f
          WHERE f.friendUser.username = :username AND f.status = 'PENDING'
      """)
  List<FriendDto> findPendingFriendRequests(@Param("username") String username);

  @Query("""
          SELECT CASE WHEN COUNT(f) > 0 THEN true ELSE false END
          FROM Friend f
          WHERE ((f.user.username = :username1 AND f.friendUser.username = :username2)
          OR (f.user.username = :username2 AND f.friendUser.username = :username1))
          AND f.status = 'ACCEPTED'
      """)
  boolean areFriends(@Param("username1") String username1, @Param("username2") String username2);

  @Query("""
          SELECT f FROM Friend f
          WHERE ((f.user.username = :username1 AND f.friendUser.username = :username2)
          OR (f.user.username = :username2 AND f.friendUser.username = :username1))
      """)
  Optional<Friend> findFriendship(@Param("username1") String username1,
      @Param("username2") String username2);
}