package no.itszipzon.config;

import io.github.cdimascio.dotenv.Dotenv;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import no.itszipzon.Tools;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.Environment;
import org.springframework.core.env.MapPropertySource;

/**
 * Class for configuring the environment.
 */
@Configuration
@PropertySource("classpath:application.properties")
public class EnvConfig {
  /**
   * Constructor for EnvConfig.
   *
   * @param environment the environment.
   * @throws IOException if an error occurs.
   */
  public EnvConfig(Environment environment) throws IOException {
    Dotenv dotenv = Tools.getEnv();

    Map<String, Object> propertiesMap = new HashMap<>();
    dotenv.entries().forEach(entry -> propertiesMap.put(entry.getKey(), entry.getValue()));
    ((ConfigurableEnvironment) environment)
        .getPropertySources()
        .addFirst(new MapPropertySource("envProperties", propertiesMap));
  }
  
}
