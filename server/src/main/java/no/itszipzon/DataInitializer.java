package no.itszipzon;

import java.util.List;
import no.itszipzon.repo.CategoryRepo;
import no.itszipzon.repo.LevelRepo;
import no.itszipzon.tables.Category;
import no.itszipzon.tables.Level;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

/**
 * DataInitializer.
 */
@Component
public class DataInitializer implements CommandLineRunner {
  @Autowired
  private CategoryRepo categoryRepo;
  @Autowired
  private LevelRepo levelRepo;

  @Override
  public void run(String... args) throws Exception {
    // Add code to run when the application starts
    createCategories();
    createLevels();
  }

  private void createCategories() {
    List<Category> existing = categoryRepo.findAll();
    List<String> categories = List.of("General Knowledge", "Science", "History", "Geography", "Art",
        "Sports", "Music", "Movies", "Literature", "Technology", "Nature", "Food & Drink",
        "Animals", "Mythology", "Politics", "Celebrities", "Vehicles", "Comics", "Anime",
        "Cartoons", "Video Games", "Board Games", "Fashion", "Gardening", "Health", "Sci-Fi",
        "Pop Culture", "Mathematics", "Language", "Religion", "Space", "Psychology", "Philosophy",
        "Society", "Business", "Economics", "Education");
    for (String category : categories) {
      if (existing.stream().noneMatch(c -> c.getName().equals(category))) {
        Category newCategory = new Category();
        newCategory.setName(category);
        categoryRepo.save(newCategory);
      }
    }
  }

  private void createLevels() {
    List<Level> existing = levelRepo.findAll();
    List<Level> levels = List.of(
      new Level(1, 250),
      new Level(2, 750),
      new Level(3, 1250),
      new Level(4, 2000),
      new Level(5, 3250),
      new Level(6, 4000),
      new Level(7, 5000),
      new Level(8, 6250),
      new Level(9, 7750),
      new Level(10, 9500),
      new Level(11, 11500),
      new Level(12, 14000),
      new Level(13, 17000),
      new Level(14, 20500),
      new Level(15, 24500),
      new Level(16, 29000),
      new Level(17, 34000),
      new Level(18, 39500),
      new Level(19, 45500),
      new Level(20, 52000),
      new Level(21, 59000),
      new Level(22, 66500),
      new Level(23, 74500),
      new Level(24, 83000),
      new Level(25, 92000),
      new Level(26, 101500),
      new Level(27, 111500),
      new Level(28, 122000),
      new Level(29, 133000),
      new Level(30, 144500),
      new Level(31, 156500),
      new Level(32, 169000)
      );

    for (Level level : levels) {
      if (existing.stream()
          .noneMatch(l -> l.getLevel() == level.getLevel() && l.getXp() == level.getXp())) {
        levelRepo.save(level);
      }
    }
  }
}
