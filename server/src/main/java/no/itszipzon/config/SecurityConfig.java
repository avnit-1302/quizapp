package no.itszipzon.config;

import java.util.ArrayList;
import java.util.List;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

/**
 * SecurityConfig.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

  /**
   * SecurityFilterChain.
   *
   * @param http HttpSecurity.
   * @return SecurityFilterChain.
   * @throws Exception Exception.
   */
  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .cors(cors -> cors.configurationSource(corsConfigurationSource()))
        .csrf(csrf -> csrf.disable());

    return http.build();
  }

  /**
   * CorsConfigurationSource.
   *
   * @return CorsConfigurationSource.
   */
  @Bean
  public CorsConfigurationSource corsConfigurationSource() {

    List<String> allowedOrigins = new ArrayList<>(
        List.of(
          "http://localhost"
        )
    );
    CorsConfiguration configuration = new CorsConfiguration();
    configuration.setAllowedOrigins(allowedOrigins);
    configuration.addAllowedHeader("*");
    configuration.addAllowedMethod("*");
    configuration.setAllowCredentials(true);

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/api/**", configuration);

    return source;
  }
}
