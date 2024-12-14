package no.itszipzon;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Class for logging.
 */
public class Logger {

  /**
   * Logs an error message.
   *
   * @param message The message to log
   */
  public static void error(String message) {
    String newMessage = "[" + LocalDateTime.now() + "] ERROR: " + message;
    logToFile(newMessage);
    System.err.println(newMessage);
  }

  /**
   * Logs a warning message.
   *
   * @param message The message to log
   */
  public static void warning(String message) {
    String newMessage = "[" + LocalDateTime.now() + "] WARNING: " + message;
    logToFile(newMessage);
    System.err.println(newMessage);
  }

  /**
   * Logs an info message.
   *
   * @param message The message to log
   */
  public static void info(String message) {
    String newMessage = "[" + LocalDateTime.now() + "] INFO: " + message;
    logToFile(newMessage);
    System.out.println(newMessage);
  }

  /**
   * Logs a generic message.
   *
   * @param message The message to log
   */
  public static void log(String message) {
    String newMessage = "[" + LocalDateTime.now() + "] LOG: " + message;
    logToFile(newMessage);
    System.out.println(newMessage);
  }

  /**
   * Logs a message to a file.
   *
   * @param message The message to log
   */
  private static void logToFile(String message) {
    boolean log = false; // Set to true to log to file
    if (log) {
      String staticLocation = new Main().getResource("/static").getPath();

      if (!Files.exists(Path.of(Tools.getCorrectUrl(staticLocation + "/logs")))) {
        try {
          Files.createDirectories(Path.of(Tools.getCorrectUrl(staticLocation + "/logs")));
        } catch (IOException e) {
          e.printStackTrace();
        }
      }

      String path = new Main().getResource("/static/logs").getPath();
      String pathBefore = new Main().getResource("/static").getPath();
      String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
  
      pathBefore += "/../../../src/main/resources/static/logs/";
      
      try {
        File file = new File(path + "/log-" + date + ".txt");
        File fileBefore = new File(pathBefore + "/log-" + date + ".txt");
        if (!file.exists()) {
          file.createNewFile();
        }
        if (!fileBefore.exists()) {
          fileBefore.createNewFile();
        }
        FileWriter writer = new FileWriter(file, true);
        FileWriter writerBefore = new FileWriter(fileBefore, true);
        writer.write(message + "\n");
        writerBefore.write(message + "\n");
        writer.close();
        writerBefore.close();
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
  }

}
