import 'package:client/tools/error_message.dart';
import 'package:client/tools/router.dart';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// A utility class to handle messages received in the quiz lobby and game.
class QuizMessageHandler {
  /// Handles lobby messages received via WebSocket and takes appropriate actions.
  ///
  /// - `context`: The current [BuildContext].
  /// - `router`: An instance of [RouterNotifier] for navigating between pages.
  /// - `values`: A map containing the message data.
  /// - `username`: The username of the current user.
  /// - `stompClient`: The WebSocket client to manage connections.
  ///
  /// Returns the username of a player who left the quiz (if applicable).
  static String handleLobbyMessages(BuildContext context, RouterNotifier router,
      Map<String, dynamic> values, String username, StompClient stompClient) {
    String value = ""; 
    String message = values["message"];

    // Handle error messages
    if (message.startsWith("error:")) {

      String error = message.substring(6);
      
      if (error.startsWith("onlyleader:")) {
        if (username == values["leaderUsername"]) {
          ErrorHandler.showOverlayError(context, error.substring(12));
        }
      } else {
      error = message.substring(7);
      ErrorHandler.showOverlayError(context, message.substring(7));

        // Redirect user based on the error type
        if (error == "Quiz not found") {
          router.setPath(context, "join");
        } else if (error == "User not found") {
          router.setPath(context, "home");
        } else if (error == "Quiz has already started") {
          router.setPath(context, "join");
        }
      }

      // Handle quiz start message
    } else if (message.startsWith("start")) {
      stompClient.deactivate();
      router.setPath(context, "quiz/game/socket", values: values);

      // Handle player leave message
    } else if (message.startsWith("leave: ")) {
      List<String> error = message.substring(7).split(",");

      if (error[0] == "leader:true") {
        if (username == values["leaderUsername"]) {
          stompClient.deactivate();
          ErrorHandler.showOverlayError(context, "You have left the quiz");
          router.setPath(context, "join");
        } else {
          ErrorHandler.showOverlayError(context, "Leader has left the quiz");
          router.setPath(context, "join");
        }
      } else if (error[0] == "leader:false") {

        // Handle case where a regular player leaves
        if (error[1] == " user:$username") {
          stompClient.deactivate();
          ErrorHandler.showOverlayError(context, "You have left the quiz");
          router.setPath(context, "join");
        } else {
          ErrorHandler.showOverlayError(
              context, "${error[1].substring(6)} has left the quiz");
          value = error[1].substring(6);
        }
      }

      // Handle quiz end message
    } else if (message.startsWith("end")) {
      ErrorHandler.showOverlayError(context, "Quiz has ended");
    }

    return value;
  }

  /// Handles game-specific messages received via WebSocket.
  ///
  /// - `context`: The current [BuildContext].
  /// - `router`: An instance of [RouterNotifier] for navigation.
  /// - `values`: A map containing the message data.
  /// - `username`: The username of the current user.
  ///
  /// Throws an [UnimplementedError] since this method is not yet implemented.
  static Map<String, dynamic> handleGameMessages(BuildContext context,
      RouterNotifier router, Map<String, dynamic> values, String username) {
    throw UnimplementedError();
  }
}
