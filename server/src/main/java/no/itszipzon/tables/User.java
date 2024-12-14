package no.itszipzon.tables;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PostLoad;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

/**
 * Users.
 */
@Entity
@Table(name = "user")
public class User {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "userId")
  private Long userId;

  @Column(nullable = false, unique = true, name = "username")
  private String username;

  @Column(nullable = false, name = "password")
  private String password;

  @Column(nullable = false, unique = true, name = "email")
  private String email;

  @Column(nullable = false, name = "role")
  private String role = "user";

  @Column(nullable = true, name = "profilePicture")
  private String profilePicture;

  @Column(nullable = false, name = "createdAt")
  private LocalDateTime createdAt;

  @Column(nullable = false, name = "updatedAt")
  private LocalDateTime updatedAt;

  @Column(nullable = false, name = "terms")
  private LocalDateTime terms;

  @Column(name = "lastLoggedIn")
  private LocalDateTime lastLoggedIn;

  @Column(name = "ban")
  private LocalDateTime banned;

  @Column(name = "level", nullable = false)
  private Integer level = 0;

  @Column(name = "xp", nullable = false)
  private Integer xp = 0;

  @Transient
  private LocalDateTime lastLoggedInOriginal;

  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
  @JsonManagedReference
  private List<QuizAttempt> quizAttempts;

  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
  @JsonManagedReference
  private List<Quiz> quizzes;

  @PrePersist
  protected void onCreate() {
    LocalDateTime now = LocalDateTime.now();
    createdAt = now;
    updatedAt = now;
  }

  @PostLoad
  protected void onLoad() {
    this.lastLoggedInOriginal = lastLoggedIn;
  }

  @PreUpdate
  protected void onUpdate() {
    if (!Objects.equals(lastLoggedInOriginal, lastLoggedIn)) {
      return;
    }
    updatedAt = LocalDateTime.now();
  }

  public Long getId() {
    return userId;
  }

  public void setId(Long id) {
    this.userId = id;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public String getPassword() {
    return password;
  }

  public void setPassword(String password) {
    this.password = password;
  }

  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  public String getRole() {
    return this.role;
  }

  public void setRole(String role) {
    this.role = role;
  }

  public LocalDateTime getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(LocalDateTime createdAt) {
    this.createdAt = createdAt;
  }

  public LocalDateTime getUpdatedAt() {
    return updatedAt;
  }

  public void setUpdatedAt(LocalDateTime updatedAt) {
    this.updatedAt = updatedAt;
  }

  public LocalDateTime getLastLoggedIn() {
    return lastLoggedIn;
  }

  public void setLastLoggedIn(LocalDateTime lastLoggedIn) {
    this.lastLoggedIn = lastLoggedIn;
  }

  public LocalDateTime getBanned() {
    return this.banned;
  }

  public void setBanned(LocalDateTime banned) {
    this.banned = banned;
  }

  public LocalDateTime getTerms() {
    return terms;
  }

  public void setTerms(LocalDateTime terms) {
    this.terms = terms;
  }

  public String getProfilePicture() {
    return profilePicture;
  }

  public void setProfilePicture(String profilePicture) {
    this.profilePicture = profilePicture;
  }

  public int getLevel() {
    return level;
  }

  public void setLevel(int level) {
    this.level = level;
  }

  public int getXp() {
    return xp;
  }

  public void setXp(int xp) {
    this.xp = xp;
  }

}
