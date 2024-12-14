package no.itszipzon.socket.quiz;

import io.jsonwebtoken.Claims;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import no.itszipzon.DtoParser;
import no.itszipzon.Tools;
import no.itszipzon.config.JwtUtil;
import no.itszipzon.repo.QuizRepo;
import no.itszipzon.tables.Quiz;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * A manager that handles quiz sessions.
 */
@Service
public class QuizSessionManager {

  private Map<String, QuizSession> quizSessions;

  @Autowired
  private QuizRepo quizRepo;

  @Autowired
  private JwtUtil jwtUtil;

  public QuizSessionManager() {
    quizSessions = new ConcurrentHashMap<>();
  }

  /**
   * Creates a quiz session.
   *
   * @param message The message containing the quiz ID and the username.
   * @return The token for the quiz session.
   */
  public String createQuizSession(QuizMessage message) {

    Claims claims = jwtUtil.extractClaims(message.getUserToken());

    QuizSession quizSession = new QuizSession(claims.getSubject(), message.getQuizId());
    quizSession.setMessage("create");
    quizSession.addPlayer(new QuizPlayer(claims.getSubject(), claims.get("id", Long.class)));

    Optional<Quiz> quiz = quizRepo.findById((long) message.getQuizId());

    if (quiz.isPresent()) {
      quizSession.setQuiz(DtoParser.mapToQuizWithQuestionsDto(quiz.get(), quizRepo));
    } else {
      return null;
    }

    int idLength = 5;
    String token = Tools.generateToken(idLength);
    while (quizSessions.containsKey(token)) {
      token = Tools.generateToken(idLength);
    }
    quizSessions.put(token, quizSession);
    return token;
  }

  /**
   * Gets a player.
   *
   * @param token The token for the quiz session.
   */
  public QuizPlayer getPlayer(String token) {
    Claims claims = jwtUtil.extractClaims(token);
    return new QuizPlayer(claims.getSubject(), claims.get("id", Long.class));
  }

  public void deleteQuizSession(String token) {
    quizSessions.remove(token);
  }

  public QuizSession getQuizSession(String token) {
    return quizSessions.get(token);
  }

  public boolean quizSessionExists(String token) {
    return quizSessions.containsKey(token);
  }

  /**
   * Sets the quiz for a quiz session.
   *
   * @param message The message containing the token and the quiz ID.
   */
  public boolean setNewQuiz(QuizSession message) {

    Optional<Quiz> quiz = quizRepo.findById((long) message.getQuizId());

    if (!quiz.isPresent()) {
      return false;
    }

    message.setQuiz(DtoParser
        .mapToQuizWithQuestionsDto(quiz.get(), quizRepo));
    return true;
  }

}
