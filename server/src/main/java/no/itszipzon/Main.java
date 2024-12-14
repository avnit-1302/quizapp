package no.itszipzon;

import java.net.URL;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * The main method to run the springboot application.
 */
@SpringBootApplication
public class Main {

  public static void main(String[] args) {
    SpringApplication.run(Main.class, args);
  }

  public URL getResource(String resource) {
    return this.getClass().getResource(resource);
  }

}
