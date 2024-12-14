package no.itszipzon.service;

import java.util.Optional;
import no.itszipzon.repo.LevelRepo;
import no.itszipzon.repo.UserRepo;
import no.itszipzon.tables.Level;
import no.itszipzon.tables.User;
import org.springframework.stereotype.Service;

/**
 * Service for the Level table.
 */
@Service
public class UserService {
  private LevelRepo levelRepo;
  private UserRepo userRepo;

  public UserService(UserRepo userRepo, LevelRepo levelRepo) {
    this.userRepo = userRepo;
    this.levelRepo = levelRepo;
  }

  /**
   * Method to get the level of a user.
   *
   * @param user the user
   * @return the level of the user
   */
  public User addXp(User user, int xpGained) {
    int newXp = user.getXp() + xpGained;
    int currentLevel = user.getLevel();
    while (true) {
      Optional<Level> nextLevel = levelRepo.getLevel(currentLevel + 1);
      if (nextLevel.isEmpty()) {
        newXp = 0;
        break;
      } else if (newXp < nextLevel.get().getXp()) {
        break;
      }
      newXp -= nextLevel.get().getXp();
      currentLevel++;
    }
    user.setXp(newXp);
    user.setLevel(currentLevel);
    return userRepo.save(user);
  }
}
