package no.itszipzon.dto;

/**
 * UserDto.
 */
public class UserDto {
  
  private Long userId;
  private String username;
  private int level;
  private int xp;

  /**
   * Constructor.
   *
   * @param userId userId
   * @param username username
   */
  public UserDto(Long userId, String username) {
    this.userId = userId;
    this.username = username;
  }

  /**
   * Constructor.
   *
   * @param userId userId
   * @param username username
   * @param level level
   * @param xp xp
   */
  public UserDto(Long userId, String username, int level, int xp) {
    this.userId = userId;
    this.username = username;
    this.level = level;
    this.xp = xp;
  }

  public Long getUserId() {
    return userId;
  }

  public void setUserId(Long userId) {
    this.userId = userId;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
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
