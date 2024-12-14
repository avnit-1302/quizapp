import 'dart:convert';
import 'dart:io';
import 'package:client/dummy_data.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

/// Handles API requests.
class ApiHandler {

  static final String _url = "http://10.212.25.78:8080";

  //static final String _url = Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';

  static String get url => _url;

  /// Updates the user's email
  static Future<void> updateEmail(String token, String newEmail) async {
    final response = await http.put(
      Uri.parse('$_url/api/user/update-email'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "newEmail": newEmail,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Failed to update email',
      );
    }
  }

  /// Uploads a profile picture for the user.
  static Future<Map<String, dynamic>> uploadProfilePicture(
      File image, String token) async {
    final uri = Uri.parse('$_url/api/user/pfp');

    // Get the file extension
    String extension = image.path.split('.').last.toLowerCase();
    if (!['png', 'jpg', 'jpeg', 'gif'].contains(extension)) {
      return {
        "success": false,
        "message": "Invalid file type: .$extension. Only PNG, JPG, and GIF are allowed."
      };
    }

    // Map extension to MIME type
    String mimeType = 'image/$extension';
    if (extension == 'jpg') mimeType = 'image/jpeg';

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            contentType: MediaType.parse(mimeType),
          ),
        );

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return {"success": true, "message": "Profile picture uploaded successfully"};
      } else {
        return {
          "success": false,
          "message": "Failed to upload profile picture: ${responseBody.body}"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error uploading profile picture: $e"};
    }
  }






  /// Checks if the user is in session.
  static Future<bool> userInSession(String token) async {
    final response = await http.get(Uri.parse('$_url/api/user/insession'),
        headers: {"Authorization": "Bearer $token"});
    return jsonDecode(response.body);
  }

  /// Gets the user.
  static Future<Map<String, Object>> getUser(String? token) async {
    if (token == null) {
      return {};
    }
    final response = await http.get(Uri.parse('$_url/api/user'),
        headers: {"Authorization": "Bearer $token"});
    return jsonDecode(response.body);
  }

  /// Logs in the user.
  static Future<Response> login(
      String email, String password, bool rememberMe) async {
    final response = await http.post(Uri.parse('$_url/api/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'user': email, 'password': password, 'rememberMe': rememberMe}));
    return response;
  }

  /// Registers the user.
  static Future<Response> register(String email, String password,
      String confirmPassword, String username, bool terms) async {
    final response = await http.post(
      Uri.parse('$_url/api/user/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'username': username,
        'terms': terms
      }),
    );
    return response;
  }

  /// Logs out the user.
  static Future<bool> logout(String? token) async {
    if (token == null) {
      return false;
    }
    final response = await http.post(Uri.parse('$_url/api/user/logout'),
        headers: {"Authorization": "Bearer $token"});
    return jsonDecode(response.body);
  }

  /// Checks if the username exists.
  static Future<bool> usernameExists(String username) async {
    final response =
        await http.get(Uri.parse('$_url/api/user/usernameexists/$username'));
    return jsonDecode(response.body);
  }

  /// Checks if the email exists.
  static Future<bool> hasPfp(String username) async {
    final response =
        await http.get(Uri.parse('$_url/api/user/haspfp/$username'));
    return jsonDecode(response.body);
  }

  /// Gets the user's profile.
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(Uri.parse('$_url/api/user'),
        headers: {"Authorization": "Bearer $token"});
    return jsonDecode(response.body);
  }

  /// Gets the user's profile picture.
  static Future<String> getProfilePicture(String username) async {
    final response = await ApiHandler.hasPfp(username);
    if (response) {
      return '$_url/api/user/pfp/$username';
    } else {
      return DummyData.profilePicture;
    }
  }

  /// Get a users quizzes by token
  static Future<List<Map<String, dynamic>>> getUserQuizzesByToken(
      String token, int page, int amount) async {
    final response = await http.get(
        Uri.parse('$_url/api/quiz/user/self/$page/$amount'),
        headers: {"Authorization": "Bearer $token"});
    if (response.statusCode == 200) {
      List<dynamic> quizzes = jsonDecode(response.body);
      return quizzes.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  /// Get a users quizzes by username
  static Future<List<Map<String, dynamic>>> getUserQuizzesByUsername(
      String username, int page, int amount) async {
    final response = await http
        .get(Uri.parse('$_url/api/quiz/user/username/$username/$page/$amount'));

    if (response.statusCode == 200) {
      List<dynamic> quizzes = jsonDecode(response.body);
      return quizzes.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  /// Get a users history by token
  static Future<List<Map<String, dynamic>>> getQuizzesByUserHistory(
      String token, int page, int amount) async {
    final response = await http.get(
        Uri.parse('$_url/api/quiz/user/history/$page/$amount'),
        headers: {"Authorization": "Bearer $token"});

    if (response.statusCode == 200) {
      List<dynamic> quizzes = jsonDecode(response.body);
      return quizzes.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  /// Fetches quizzes from the API.
  static Future<List<Map<String, dynamic>>> getQuizzes() async {
    final response = await http.get(Uri.parse('$_url/api/quiz'));

    if (response.statusCode == 200) {
      List<dynamic> quizzes = jsonDecode(response.body);
      return quizzes.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  /// Fetches quizzes from the API by filter.
  static Future<List<Map<String, dynamic>>> getQuizzesByFilter(
      int page, int size, String by, String orientation) async {
    final response = await http.get(
        Uri.parse("$_url/api/quiz/all/filter/$page/$size/$by/$orientation"));

    if (response.statusCode == 200) {
      List<dynamic> quizzes = jsonDecode(response.body);
      return quizzes.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  /// Create a quiz
  static Future<http.Response> createQuiz(
      Map<String, dynamic> quizData, String token, File thumbnail) async {
    final uri = Uri.parse('$_url/api/quiz');

    String fileExtension = thumbnail.path.split('.').last.toLowerCase();
    String mimeType;
    if (fileExtension == 'png') {
      mimeType = 'image/png';
    } else if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
      mimeType = 'image/jpeg';
    } else {
      throw Exception('Unsupported file type');
    }

    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(http.MultipartFile.fromString(
        'quiz',
        jsonEncode(quizData),
        contentType: MediaType('application', 'json'),
      ))
      ..files.add(await http.MultipartFile.fromPath(
        'thumbnail',
        thumbnail.path,
        contentType: MediaType.parse(mimeType),
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  /// Fetches categories from the API.
  static Future<List<String>> getQuizCategories() async {
    final response = await http.get(Uri.parse('$_url/api/quiz/categories'));
    return jsonDecode(response.body).cast<String>();
  }

  /// Fetches quizzes by category.
  static Future<List<Map<String, dynamic>>> getQuizzesByCategory(
      String category, int page) async {
    final response =
        await http.get(Uri.parse('$_url/api/quiz/category/$category/$page'));

    if (response.statusCode == 200) {
      List<dynamic> quizzes = jsonDecode(response.body);
      return quizzes.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  /// Fetches quizzes from the API.
  static Future<Map<String, dynamic>> getQuiz(int id) async {
    final response = await http.get(Uri.parse('$_url/api/quiz/$id'));
    return jsonDecode(response.body);
  }

  /// Check quiz results
  static Future<Map<String, dynamic>> checkQuiz(
      String token, Map<String, dynamic> quiz) async {
    final uri = Uri.parse('$_url/api/quiz/game/solo/check');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(quiz),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check quiz answers');
    }
  }

  // Inputs a quiz game to the API.
  static Future<Map<String, dynamic>> playQuiz(
      String token, Map<String, dynamic> quiz) async {
    final uri = Uri.parse('$_url/api/quiz/game/solo');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(quiz),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check quiz answers');
    }
  }

  /// Fetches the 10 most popular quizzes based on the number of attempts.
  static Future<List<Map<String, dynamic>>> getMostPopularQuizzes(
      int page) async {
    final uri = Uri.parse('$_url/api/quiz/popular/$page');

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      List<dynamic> quizzes = jsonDecode(response.body);
      return quizzes.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch popular quizzes');
    }
  }

  /// Get list of friends
  static Future<List<Map<String, dynamic>>> getFriends(String token) async {
    final response = await http.get(
      Uri.parse('$_url/api/friends'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> friends = jsonDecode(response.body);
      return friends.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load friends');
    }
  }

  /// Get pending friend requests
  static Future<List<Map<String, dynamic>>> getPendingFriendRequests(
      String token) async {
    final response = await http.get(
      Uri.parse('$_url/api/friends/pending'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> requests = jsonDecode(response.body);
      return requests.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load friend requests');
    }
  }

  /// Send friend request
  static Future<void> sendFriendRequest(String token, String username) async {
    final response = await http.post(
      Uri.parse('$_url/api/friends/request/$username'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      String errorMessage = response.body;
      if (response.statusCode == 400) {
        // Handle specific error cases
        switch (errorMessage) {
          case "Cannot send friend request to yourself":
            throw Exception("You can't send a friend request to yourself");
          case "Friend request already exists":
            throw Exception("Friend request already exists");
          default:
            throw Exception(errorMessage);
        }
      } else if (response.statusCode == 404) {
        throw Exception("User not found");
      } else {
        throw Exception("Failed to send friend request");
      }
    }
  }

  /// Accept friend request
  static Future<void> acceptFriendRequest(
      String token, int friendRequestId) async {
    final response = await http.post(
      Uri.parse('$_url/api/friends/accept/$friendRequestId'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        throw Exception("Friend request not found");
      } else {
        throw Exception("Failed to accept friend request");
      }
    }
  }

  /// Remove friend
  static Future<void> removeFriend(String token, String username) async {
    final response = await http.delete(
      Uri.parse('$_url/api/friends/$username'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        throw Exception("Friendship not found");
      } else {
        throw Exception("Failed to remove friend");
      }
    }
  }

  /// Get amount of quizzes in given category
  static Future<int> getCategoryQuizCount(String categoryName) async {
    final response = await http.get(
      Uri.parse('$_url/api/quiz/category/count/$categoryName'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get category quiz count');
  }

  /// Delete a quiz
  static Future<void> deleteQuiz(String token, int quizId) async {
    final response = await http.delete(
      Uri.parse('$_url/api/quiz/$quizId'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 401:
          throw Exception("Unauthorized access");
        case 403:
          throw Exception("You don't have permission to delete this quiz");
        case 404:
          throw Exception("Quiz not found");
        default:
          throw Exception("Failed to delete quiz: ${response.body}");
      }
    }
  }

  /// Reset the password
  static Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$_url/api/user/resetpassword'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(email),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to request password reset");
    }
  }

  /// Verify the reset token
  static Future<void> verifyToken(String email, String token) async {
    final response = await http.post(
      Uri.parse('$_url/api/user/verify-reset-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ??
          'Failed to verify the reset token.');
    }
  }

  /// Reset the password
  static Future<void> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse("$_url/api/user/newpassword"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "token": token,
        "newPassword": newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  /// Update the user's password and email and username
  static Future<Response> updateUser(
    String token, {
    String? newEmail,
    String? newUsername,
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
  }) async {
    final response = await http.put(
      Uri.parse('$_url/api/user/update'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": newEmail ?? "",
        "username": newUsername ?? "",
        "oldPassword": oldPassword ?? "",
        "newPassword": newPassword ?? "",
        "confirmPassword": confirmPassword ?? "",
      }),
    );

    return response;
  }
}
