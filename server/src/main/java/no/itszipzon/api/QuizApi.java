package no.itszipzon.api;

import io.jsonwebtoken.Claims;
import jakarta.persistence.EntityNotFoundException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import no.itszipzon.Tools;
import no.itszipzon.config.JwtUtil;
import no.itszipzon.dto.QuizDto;
import no.itszipzon.dto.QuizOptionDto;
import no.itszipzon.dto.QuizQuestionDto;
import no.itszipzon.dto.QuizWithQuestionsDto;
import no.itszipzon.repo.CategoryRepo;
import no.itszipzon.repo.QuizAttemptRepo;
import no.itszipzon.repo.QuizOptionRepo;
import no.itszipzon.repo.QuizQuestionRepo;
import no.itszipzon.repo.QuizRepo;
import no.itszipzon.repo.UserRepo;
import no.itszipzon.service.UserService;
import no.itszipzon.tables.Category;
import no.itszipzon.tables.Quiz;
import no.itszipzon.tables.QuizAnswer;
import no.itszipzon.tables.QuizAttempt;
import no.itszipzon.tables.QuizCategory;
import no.itszipzon.tables.QuizOption;
import no.itszipzon.tables.QuizQuestion;
import no.itszipzon.tables.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/**
 * QuizApi.
 */
@RestController
@RequestMapping("api/quiz")
public class QuizApi {
  @Autowired
  private QuizRepo quizRepo;
  @Autowired
  private CategoryRepo categoryRepo;
  @Autowired
  private JwtUtil jwtUtil;
  @Autowired
  private QuizQuestionRepo questionRepo;
  @Autowired
  private QuizAttemptRepo quizAttemptRepo;
  @Autowired
  private UserService userService;
  @Autowired
  private UserRepo userRepo;
  @Autowired
  private QuizOptionRepo optionRepo;

  /**
   * Get all quizzes.
   *
   * @return quizzes.
   */
  @GetMapping
  @Transactional(readOnly = true)
  public ResponseEntity<List<QuizDto>> getAllQuizzes() {
    return new ResponseEntity<>(
        quizRepo.findAll().stream().map(this::mapToQuizDto).collect(Collectors.toList()),
        HttpStatus.OK);
  }

  /**
   * Get all quizzes with pagination.
   *
   * @param page page.
   * @param size size.
   * @return quizzes.
   */
  @GetMapping("/all/filter/{page}/{size}/{by}/{orientation}")
  public ResponseEntity<List<QuizDto>> getFilteredQuizzes(@PathVariable int page,
      @PathVariable int size, @PathVariable String by, @PathVariable String orientation) {
    Pageable pageable = PageRequest.of(page, size,
        Sort.by(Sort.Direction.fromString(orientation), by));
    List<QuizDto> quizzes = quizRepo.findAllByFilter(pageable).orElse(new ArrayList<>());
    if (quizzes.isEmpty()) {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
    return new ResponseEntity<>(quizzes, HttpStatus.OK);
  }

  /**
   * Get quiz by id.
   *
   * @param id id.
   * @return quiz.
   */
  @GetMapping("/{id}")
  public ResponseEntity<QuizWithQuestionsDto> getQuizById(@PathVariable Long id) {
    Optional<Quiz> quiz = quizRepo.findById(id);
    return quiz.map(value -> ResponseEntity.ok(mapToQuizWithQuestionsDto(value)))
        .orElseGet(() -> ResponseEntity.notFound().build());
  }

  /**
   * Get quiz image.
   *
   * @param id id.
   * @return image.
   */
  @GetMapping("/thumbnail/{id}")
  public ResponseEntity<Resource> getQuizImage(@PathVariable Long id) {
    Optional<QuizDto> quiz = quizRepo.findQuizSummaryById(id);
    String thumbnail = quiz.get().getThumbnail();
    String imageFolder = "static/images/" + quiz.get().getUserId() + "/quiz/";
    Resource resource;
    String filetype;
    resource = new ClassPathResource(imageFolder + thumbnail);
    filetype = thumbnail.substring(thumbnail.lastIndexOf(".") + 1);
    MediaType mediaType = null;
    switch (filetype) {
      case "png":
        mediaType = MediaType.IMAGE_PNG;
        break;
      case "jpg":
        mediaType = MediaType.IMAGE_JPEG;
        break;
      case "jpeg":
        mediaType = MediaType.IMAGE_JPEG;
        break;
      case "gif":
        mediaType = MediaType.IMAGE_GIF;
        break;
      default:
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
    return ResponseEntity.ok().contentType(mediaType).body(resource);
  }

  @GetMapping("/categories")
  @Transactional(readOnly = true)
  public ResponseEntity<List<String>> getCategories() {
    return ResponseEntity.ok(categoryRepo.findAllNames());
  }

  /**
   * Get quizzes by category.
   *
   * @param category category.
   * @param page     page.
   * @return quizzes.
   */
  @GetMapping("/category/{category}/{page}")
  public ResponseEntity<List<QuizDto>> getQuizzesByCategory(@PathVariable String category,
      @PathVariable int page) {
    Pageable pageable = PageRequest.of(page, 10); // 10 quizzes per page
    Optional<List<QuizDto>> quizzes = quizRepo.findQuizzesByCategory(category, pageable);
    if (quizzes.isEmpty()) {
      return new ResponseEntity<>(new ArrayList<>(), HttpStatus.OK);
    }
    return new ResponseEntity<>(quizzes.get(), HttpStatus.OK);
  }

  @GetMapping("/category/count/{categoryName}")
  public ResponseEntity<Long> getQuizCountByCategory(@PathVariable String categoryName) {
    long count = categoryRepo.countQuizzesByCategory(categoryName);
    return ResponseEntity.ok(count);
  }

  /**
   * Get quizzes by search.
   *
   * @param authorizationHeader authorizationHeader.
   * @return quizzes.
   */
  @GetMapping("/user/self/{page}/{amount}")
  public ResponseEntity<List<QuizDto>> getQuizzesByUser(
      @RequestHeader("Authorization") String authorizationHeader, @PathVariable int page,
      @PathVariable int amount) {
    if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    String token = authorizationHeader.substring(7);
    Claims claims = jwtUtil.extractClaims(token);
    if (claims == null) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    String username = claims.getSubject();
    Pageable pageable = PageRequest.of(page, amount, Sort.by(Sort.Direction.DESC, "createdAt"));
    Optional<List<QuizDto>> optQuizzes = quizRepo.findUsersQuizzes(username, pageable);
    List<QuizDto> quizzes = optQuizzes.orElse(new ArrayList<>());
    return new ResponseEntity<>(quizzes, HttpStatus.OK);
  }

  /**
   * Get quizzes by search.
   *
   * @param username username.
   * @return quizzes.
   */
  @GetMapping("/user/username/{username}/{page}/{amount}")
  public ResponseEntity<List<QuizDto>> getQuizzesByUsername(@PathVariable String username,
      @PathVariable int page, @PathVariable int amount) {
    Pageable pageable = PageRequest.of(page, amount, Sort.by(Sort.Direction.DESC, "createdAt"));
    Optional<List<QuizDto>> optQuizzes = quizRepo.findUsersQuizzes(username, pageable);
    List<QuizDto> quizzes = optQuizzes.orElse(new ArrayList<>());
    return new ResponseEntity<>(quizzes, HttpStatus.OK);
  }

  /**
   * Get quizzes by search.
   *
   * @param authorizationHeader authorizationHeader.
   * @return quizzes.
   */
  @GetMapping("/user/history/{page}/{amount}")
  public ResponseEntity<List<QuizDto>> getQuizzesByUserHistory(
      @RequestHeader("Authorization") String authorizationHeader, @PathVariable int page,
      @PathVariable int amount) {
    if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    String token = authorizationHeader.substring(7);
    Claims claims = jwtUtil.extractClaims(token);
    if (claims == null) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    String username = claims.getSubject();
    Pageable pageable = PageRequest.of(page, amount, Sort.by(Sort.Direction.DESC, "takenAt"));
    Optional<List<QuizDto>> optQuizzes = quizAttemptRepo.findQuizzesFromUserHistory(username,
        pageable);
    List<QuizDto> quizzes = optQuizzes.orElse(new ArrayList<>());
    return new ResponseEntity<>(quizzes, HttpStatus.OK);
  }

  /**
   * Get all questions for a specific quiz by quiz ID.
   *
   * @param quizId The ID of the quiz.
   * @return A list of questions associated with the quiz.
   */
  @GetMapping("/questions/{quizId}")
  public ResponseEntity<List<QuizQuestionDto>> getQuestionsByQuizId(@PathVariable Long quizId) {
    Optional<Quiz> quizOptional = quizRepo.findById(quizId);
    if (quizOptional.isEmpty()) {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
    // Map quiz questions to DTOs
    List<QuizQuestionDto> questionsDto = quizOptional.get().getQuizQuestions().stream()
        .map(this::mapToQuestionDto).collect(Collectors.toList());
    return new ResponseEntity<>(questionsDto, HttpStatus.OK);
  }

  /**
   * Get popular quizzes with pagination.
   *
   * @return List of popular quizzes.
   */
  @GetMapping("/popular/{page}")
  @Transactional(readOnly = true)
  public ResponseEntity<List<Map<String, Object>>> getMostPopularQuizzes(@PathVariable int page) {
    // Create a pageable object
    Pageable pageable = PageRequest.of(page, 5);
    Optional<List<QuizDto>> popularQuizzesPage = quizAttemptRepo.findTopPopularQuizzes(pageable);
    if (popularQuizzesPage.isEmpty()) {
      return new ResponseEntity<>(new ArrayList<>(), HttpStatus.OK);
    }
    // Map the results to the desired response format
    List<Map<String, Object>> response = popularQuizzesPage.get().stream().map(record -> {
      Map<String, Object> quizMap = new HashMap<>();
      quizMap.put("id", record.getId());
      quizMap.put("title", record.getTitle());
      quizMap.put("description", record.getDescription());
      quizMap.put("thumbnail", record.getThumbnail());
      quizMap.put("timer", record.getTimer());
      quizMap.put("username", record.getUsername());
      quizMap.put("createdAt", record.getCreatedAt());
      quizMap.put("profile_picture", record.getProfilePicture());
      return quizMap;
    }).collect(Collectors.toList());
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  

  /**
   * Create quiz.
   *
   * @param quiz quiz.
   * @return If the quiz was created.
   */
  @PostMapping
  @Transactional
  public ResponseEntity<Boolean> createQuiz(@RequestPart("quiz") Map<String, Object> quiz,
      @RequestPart("thumbnail") MultipartFile thumbnail,
      @RequestHeader("Authorization") String authorizationHeader) {
    if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    String token = authorizationHeader.substring(7);
    Claims claims = jwtUtil.extractClaims(token);
    if (claims == null) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    User quizUser = new User();
    quizUser.setId(claims.get("id", Long.class));
    quizUser.setUsername(claims.getSubject());
    String title = quiz.get("title").toString();
    String description = quiz.get("description").toString();

    if (title.isBlank() || description.isBlank()) {
      return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
    }

    if (description.length() > 254) {
      return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
    }

    if (title.length() > 30) {
      return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
    }

    int timer = (int) quiz.get("timer");
    if (timer < 0) {
      return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
    }
    
    if (timer > 120) {
      return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
    }

    if (timer > 0 && timer < 10) {
      return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
    }

    Quiz newQuiz = new Quiz();
    newQuiz.setTitle(title);
    newQuiz.setDescription(description);
    newQuiz.setTimer(timer);
    newQuiz.setQuizQuestions(new ArrayList<>());
    newQuiz.setUser(quizUser);
    Object questionsObj = quiz.get("quizQuestions");
    if (!(questionsObj instanceof List)) {
      return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
    }
    List<?> questionsList = (List<?>) questionsObj;
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> questions = questionsList.stream().filter(item -> item instanceof Map)
        .map(item -> (Map<String, Object>) item).collect(Collectors.toList());
    for (Map<String, Object> question : questions) {
      String questionText = (String) question.get("question");
      if (questionText.isBlank()) {
        return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
      }
      QuizQuestion quizQuestion = new QuizQuestion();
      quizQuestion.setQuestion(questionText);
      quizQuestion.setQuiz(newQuiz);
      quizQuestion.setQuizOptions(new ArrayList<>());
      Object optionsObj = question.get("quizOptions");
      if (!(optionsObj instanceof List)) {
        return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
      }
      List<?> optionsList = (List<?>) optionsObj;
      @SuppressWarnings("unchecked")
      List<Map<String, Object>> options = optionsList.stream().filter(item -> item instanceof Map)
          .map(item -> (Map<String, Object>) item).collect(Collectors.toList());
      if (options.size() < 2) {
        return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
      }
      boolean hasCorrect = false;
      for (Map<String, Object> option : options) {
        String optionText = (String) option.get("optionText");
        boolean isCorrect = (boolean) option.get("correct");
        QuizOption quizOption = new QuizOption();
        quizOption.setQuizQuestion(quizQuestion);
        quizOption.setCorrect(isCorrect);
        quizOption.setOptionText(optionText);
        if (isCorrect) {
          hasCorrect = true;
        }
        quizQuestion.getQuizOptions().add(quizOption);
      }
      if (!hasCorrect) {
        return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
      }
      newQuiz.getQuizQuestions().add(quizQuestion);
    }
    Object categoryObj = quiz.get("categories");
    if (categoryObj != null && !(categoryObj instanceof List<?>)) {
      return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
    }
    List<?> categoryList = (List<?>) categoryObj;
    List<String> categories = categoryList.stream().filter(String.class::isInstance)
        .map(String.class::cast).collect(Collectors.toList());
    if (categories.size() > 0) {
      List<Category> quizCategories = categoryRepo.findAll();
      List<QuizCategory> quizCategoryList = new ArrayList<>();
      for (String category : categories) {
        if (!category.isBlank()) {
          QuizCategory newCategory = new QuizCategory();
          if (quizCategories.stream().anyMatch(c -> c.getName().equals(category))) {
            newCategory.setCategory(quizCategories.stream()
                .filter(c -> c.getName().equals(category)).findFirst().get());
            newCategory.setQuiz(newQuiz);
            quizCategoryList.add(newCategory);
          }
        }
      }
      newQuiz.setCategories(quizCategoryList);
    }
    String thumbnailString = Tools.addImage(quizUser.getId(), thumbnail, "quiz");
    if (thumbnailString.isBlank()) {
      return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
    }
    newQuiz.setThumbnail(thumbnailString);
    quizRepo.save(newQuiz);
    return new ResponseEntity<>(true, HttpStatus.CREATED);
  }

  /**
   * Get check solo game questions.
   *
   * @param gameData The game data.
   * @return quizzes.
   */
  @PostMapping("/game/solo/check")
  public ResponseEntity<Map<String, Object>> checkSoloGame(
      @RequestBody Map<String, Object> gameData,
      @RequestHeader("Authorization") String authorizationHeader) {
    if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    String token = authorizationHeader.substring(7);
    Claims claims = jwtUtil.extractClaims(token);
    if (claims == null) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    Object answersObj = gameData.get("answers");
    if (!(answersObj instanceof List)) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    List<?> answersList = (List<?>) answersObj;
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> answers = answersList.stream().filter(obj -> obj instanceof Map)
        .map(obj -> (Map<String, Object>) obj).collect(Collectors.toList());
    List<Map<String, Object>> answerCheck = new ArrayList<>();
    int amountOfCorrect = 0;
    for (Map<String, Object> answer : answers) {
      long questionId;
      try {
        questionId = Long.parseLong(answer.get("questionId").toString());
      } catch (NumberFormatException e) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
      // Check if answerId is null
      Object answerIdObj = answer.get("optionId");
      Map<String, Object> check = new HashMap<>();
      check.put("questionId", questionId);
      check.put("optionId", answerIdObj);
      if (answerIdObj == null) {
        // If answerId is null, mark as incorrect
        check.put("correct", false);
      } else {
        long answerId;
        try {
          answerId = Long.parseLong(answerIdObj.toString());
        } catch (NumberFormatException e) {
          return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        // Check if the provided answerId is correct
        Optional<Boolean> correctOptional = questionRepo.checkIfCorrectAnswer(questionId, answerId);
        if (correctOptional.isEmpty()) {
          return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        if (correctOptional.get()) {
          int maxScore = 1000;
          double seconds = Double.parseDouble(answer.get("responseTime").toString());
          int score = 0;
          if (seconds < 0.5) {
            score = maxScore;
          } else {
            double reductionFactor = 1
                - ((seconds / Integer.parseInt(gameData.get("timer").toString())) / 2);
            score = (int) Math.round(maxScore * reductionFactor);
          }
          check.put("score", score);
          check.put("correct", true);
          amountOfCorrect++;
        } else {
          check.put("score", 0);
          check.put("correct", false);
        }
      }
      answerCheck.add(check);
    }
    Map<String, Object> response = new HashMap<>();
    response.put("checks", answerCheck);
    int score = answerCheck.stream()
        .mapToInt(answerCheckItem -> (Integer) answerCheckItem.get("score") == null ? 0
            : (Integer) answerCheckItem.get("score"))
        .sum();
    response.put("score", score);
    response.put("amountOfCorrect", amountOfCorrect);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * Post a solo game.
   *
   * @param gameData            The game data.
   * @param authorizationHeader The JWT token.
   * @return The game data.
   */
  @PostMapping("/game/solo")
  public ResponseEntity<Map<String, Object>> soloGame(@RequestBody Map<String, Object> gameData,
      @RequestHeader("Authorization") String authorizationHeader) {
    if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    String token = authorizationHeader.substring(7);
    Claims claims = jwtUtil.extractClaims(token);
    if (claims == null) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    long quizId;
    try {
      quizId = Long.parseLong(gameData.get("quizId").toString());
    } catch (NumberFormatException e) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    QuizAttempt quizAttempt = new QuizAttempt();
    Optional<Quiz> quizOptional = quizRepo.findById(quizId);

    if (quizOptional.isEmpty()) {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    User user = userRepo.findUserByUsername(claims.getSubject()).get();

    quizAttempt.setQuiz(quizOptional.get());
    quizAttempt.setUser(user);

    Map<String, Object> response = new HashMap<>();
    response.put("username", claims.getSubject());
    response.put("userId", claims.get("id"));
    response.put("quizId", quizId);
    Object answersObj = gameData.get("answers");
    if (!(answersObj instanceof List)) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    List<?> answersList = (List<?>) answersObj;
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> answers = answersList.stream().filter(obj -> obj instanceof Map)
        .map(obj -> (Map<String, Object>) obj).collect(Collectors.toList());
    List<Map<String, Object>> answerCheck = new ArrayList<>();
    List<QuizAnswer> quizAnswers = new ArrayList<>();

    for (Map<String, Object> answer : answers) {
      long questionId;

      try {
        questionId = Long.parseLong(answer.get("questionId").toString());
      } catch (NumberFormatException e) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }

      QuizAnswer quizAnswer = new QuizAnswer();
      quizAnswer.setQuizAttempt(quizAttempt);

      QuizQuestion question = questionRepo
            .findById(questionId)
            .orElseThrow(() -> new EntityNotFoundException("QuizQuestion not found"));
      quizAnswer.setQuizQuestion(question);
      Long answerId = null;

      if (answer.get("optionId") == null) {
        quizAnswer.setQuizOption(null);
      } else {
        QuizOption quizOption = optionRepo
            .findById(Long.parseLong(answer.get("optionId").toString()))
            .orElseThrow(() -> new EntityNotFoundException("QuizOption not found"));
        answerId = Long.parseLong(answer.get("optionId").toString());
        quizAnswer.setQuizOption(quizOption);
      }
      
      Map<String, Object> check = new HashMap<>();
      check.put("questionId", questionId);
      check.put("optionId", answerId);
      answerCheck.add(check);
      quizAnswers.add(quizAnswer);
    }
    LocalDateTime now = LocalDateTime.now();
    LocalDateTime oneMonthAgo = now.minusMonths(1);

    int reduction = quizAttemptRepo.countAttemptLastMonth(claims.getSubject(), quizId, oneMonthAgo,
        now);

    int score = gameData.get("score") == null ? 0
        : Integer.parseInt(gameData.get("score").toString());

    int xp = Tools.calculateXp(score, quizOptional.get().getQuizQuestions().size(),
        Integer.parseInt(gameData.get("amountOfCorrect").toString()), reduction);

    User quizOwner = userRepo.findUserByUsername(quizOptional.get().getUser().getUsername()).get();

    if (user.getUsername().equalsIgnoreCase(quizOptional.get().getUser().getUsername())) {
      userService.addXp(user, 0);
    } else {
      userService.addXp(user, xp);
      userService.addXp(quizOwner, 250);
    }

    response.put("checks", answerCheck);
    response.put("score", score);
    quizAttempt.setExpEarned(xp);
    quizAttempt.setTakenAt(now);
    quizAttempt.setQuizAnswers(quizAnswers);
    quizAttemptRepo.save(quizAttempt);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * Deletes a quiz and its associated data (attempts, questions, options, etc) if the requesting
   * user owns it.
   *
   * @param id                  Quiz ID to delete
   * @param authorizationHeader JWT token containing user info
   * @return ResponseEntity with result message and status: - 200 OK if deleted successfully - 401
   *         UNAUTHORIZED if missing/invalid token - 403 FORBIDDEN if user doesn't own quiz - 404
   *         NOT_FOUND if quiz doesn't exist - 500 INTERNAL_SERVER_ERROR if deletion fails
   */
  @DeleteMapping("/{id}")
  @Transactional
  public ResponseEntity<String> deleteQuiz(@PathVariable Long id,
      @RequestHeader("Authorization") String authorizationHeader) {
    if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
      return new ResponseEntity<>("Unauthorized", HttpStatus.UNAUTHORIZED);
    }
    String token = authorizationHeader.substring(7);
    Claims claims = jwtUtil.extractClaims(token);
    if (claims == null) {
      return new ResponseEntity<>("Invalid token", HttpStatus.UNAUTHORIZED);
    }
    Optional<Quiz> quizOptional = quizRepo.findById(id);
    if (quizOptional.isEmpty()) {
      return new ResponseEntity<>("Quiz not found", HttpStatus.NOT_FOUND);
    }
    Quiz quiz = quizOptional.get();
    String username = claims.getSubject();
    if (!quiz.getUser().getUsername().equals(username)) {
      return new ResponseEntity<>("Unauthorized: User does not own this quiz",
          HttpStatus.FORBIDDEN);
    }
    try {
      quizAttemptRepo.deleteAll(quiz.getQuizAttempts());
      quizRepo.delete(quiz);
      return new ResponseEntity<>("Quiz deleted successfully", HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>("Error deleting quiz: " + e.getMessage(),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  private QuizDto mapToQuizDto(Quiz quiz) {
    User user = quiz.getUser();
    return new QuizDto(quiz.getQuizId(), quiz.getTitle(), quiz.getDescription(),
        quiz.getThumbnail(), quiz.getTimer(), user.getUsername(), user.getProfilePicture(),
        quiz.getCreatedAt());
  }

  private QuizWithQuestionsDto mapToQuizWithQuestionsDto(Quiz quiz) {
    List<QuizQuestionDto> questionsDto = quiz.getQuizQuestions().stream()
        .map(this::mapToQuestionDto).collect(Collectors.toList());
    
    QuizWithQuestionsDto response = new QuizWithQuestionsDto(
        quiz.getQuizId(),
        quiz.getTitle(),
        quiz.getDescription(),
        quiz.getThumbnail(),
        quiz.getTimer(),
        quiz.getCreatedAt(),
        questionsDto,
        quizRepo.findUsernameFromQuizId(quiz.getQuizId()).get());

    response.getQuizQuestions().forEach(question -> Collections.shuffle(question.getQuizOptions()));
    return response;
  }

  private QuizQuestionDto mapToQuestionDto(QuizQuestion question) {
    List<QuizOptionDto> optionsDto = question.getQuizOptions().stream()
        .map(option -> new QuizOptionDto(option.getQuizOptionId(), option.getOptionText(),
            option.isCorrect()))
        .collect(Collectors.toList());
    return new QuizQuestionDto(question.getQuizQuestionId(), question.getQuestion(), optionsDto);
  }
}
