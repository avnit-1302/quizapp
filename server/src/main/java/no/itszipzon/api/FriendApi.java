package no.itszipzon.api;

import io.jsonwebtoken.Claims;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import no.itszipzon.Logger;
import no.itszipzon.config.JwtUtil;
import no.itszipzon.dto.FriendDto;
import no.itszipzon.repo.FriendRepo;
import no.itszipzon.repo.UserRepo;
import no.itszipzon.tables.Friend;
import no.itszipzon.tables.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** REST API controller for managing friend relationships between users. */
@RestController
@RequestMapping("api/friends")
public final class FriendApi {

  @Autowired
  private FriendRepo friendRepo;

  @Autowired
  private UserRepo userRepo;

  @Autowired
  private JwtUtil jwtUtil;

  public FriendApi() {
  }

  /**
   * Retrieves all friends for the authenticated user.
   *
   * @param authHeader JWT token in format "Bearer {token}"
   * @return ResponseEntity containing list of FriendDto objects
   */
  @GetMapping
  public ResponseEntity<List<FriendDto>> getFriends(
      @RequestHeader("Authorization") String authHeader) {
    Claims claims = validateToken(authHeader);
    if (claims == null) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }

    List<FriendDto> friends = friendRepo.findUserFriends(claims.getSubject());
    return new ResponseEntity<>(friends, HttpStatus.OK);
  }

  /**
   * Retrieves pending friend requests for the authenticated user.
   *
   * @param authHeader JWT token in format "Bearer {token}"
   * @return ResponseEntity containing list of pending FriendDto objects
   */
  @GetMapping("/pending")
  public ResponseEntity<List<FriendDto>> getPendingRequests(
      @RequestHeader("Authorization") String authHeader) {
    Claims claims = validateToken(authHeader);
    if (claims == null) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }

    List<FriendDto> pending = friendRepo.findPendingFriendRequests(claims.getSubject());
    return new ResponseEntity<>(pending, HttpStatus.OK);
  }

  /**
   * Sends a friend request to the specified user.
   *
   * @param authHeader JWT token in format "Bearer {token}"
   * @param username   Username of the user to send request to
   * @return ResponseEntity containing result message
   */
  @PostMapping("/request/{username}")
  public ResponseEntity<String> sendFriendRequest(@RequestHeader("Authorization") String authHeader,
      @PathVariable String username) {
    Claims claims = validateToken(authHeader);
    if (claims == null) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }

    if (claims.getSubject().equals(username)) {
      return new ResponseEntity<>("Cannot send friend request to yourself", HttpStatus.BAD_REQUEST);
    }

    Optional<User> targetUser = userRepo.findUserByUsername(username);
    if (targetUser.isEmpty()) {
      return new ResponseEntity<>("User not found", HttpStatus.NOT_FOUND);
    }

    Optional<Friend> existingFriendship = friendRepo.findFriendship(claims.getSubject(), username);
    if (existingFriendship.isPresent()) {
      return new ResponseEntity<>("Friend request already exists", HttpStatus.BAD_REQUEST);
    }

    User requestingUser = userRepo.findUserByUsername(claims.getSubject()).get();
    Friend friend = new Friend();
    friend.setUser(requestingUser);
    friend.setFriendUser(targetUser.get());
    friend.setStatus("PENDING");
    friendRepo.save(friend);

    Logger.log("User " + claims.getSubject() + " sent friend request to " + username);
    return new ResponseEntity<>("Friend request sent", HttpStatus.OK);
  }

  /**
   * Accepts a pending friend request.
   *
   * @param authHeader JWT token in format "Bearer {token}"
   * @param friendId   ID of the friend request to accept
   * @return ResponseEntity containing result message
   */
  @PostMapping("/accept/{friendId}")
  public ResponseEntity<String> acceptFriendRequest(
      @RequestHeader("Authorization") String authHeader, @PathVariable Long friendId) {
    Claims claims = validateToken(authHeader);
    if (claims == null) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }

    Optional<Friend> friendRequest = friendRepo.findById(friendId);
    if (friendRequest.isEmpty()
        || !friendRequest.get().getFriendUser().getUsername().equals(claims.getSubject())) {
      return new ResponseEntity<>("Friend request not found", HttpStatus.NOT_FOUND);
    }

    Friend friend = friendRequest.get();
    friend.setStatus("ACCEPTED");
    friend.setAcceptedAt(LocalDateTime.now());
    friendRepo.save(friend);

    Logger.log("User " + claims.getSubject() + " accepted friend request from "
        + friend.getUser().getUsername());
    return new ResponseEntity<>("Friend request accepted", HttpStatus.OK);
  }

  /**
   * Removes a friend relationship or cancels a pending request.
   *
   * @param authHeader JWT token in format "Bearer {token}"
   * @param username   Username of the friend to remove
   * @return ResponseEntity containing result message
   */
  @DeleteMapping("/{username}")
  public ResponseEntity<String> removeFriend(@RequestHeader("Authorization") String authHeader,
      @PathVariable String username) {
    Claims claims = validateToken(authHeader);
    if (claims == null) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }

    Optional<Friend> friendship = friendRepo.findFriendship(claims.getSubject(), username);
    if (friendship.isEmpty()) {
      return new ResponseEntity<>("Friendship not found", HttpStatus.NOT_FOUND);
    }

    friendRepo.delete(friendship.get());
    Logger.log("User " + claims.getSubject() + " removed friend " + username);

    return new ResponseEntity<>("Friend removed", HttpStatus.OK);
  }

  /**
   * Validates and extracts claims from JWT token.
   *
   * @param authHeader JWT token in format "Bearer {token}"
   * @return Claims object if token is valid, null otherwise
   */
  private Claims validateToken(String authHeader) {
    if (authHeader == null || !authHeader.startsWith("Bearer ")) {
      return null;
    }
    String token = authHeader.substring(7);
    return jwtUtil.extractClaims(token);
  }
}