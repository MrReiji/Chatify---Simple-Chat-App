import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Singleton instance of FirebaseAuth used for authentication operations.
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

/// A form bloc that handles user login functionality.
/// 
/// This class manages:
/// - Input validation for email and password fields.
/// - Checking for internet connectivity before proceeding with login.
/// - Signing in users with Firebase Authentication.
/// - Initializing Firebase Cloud Messaging for push notifications after successful login.
class LoginFormBloc extends FormBloc<String, String> {
  /// Bloc for the email input field.
  /// 
  /// This field uses the following validators:
  /// - `required`: Ensures the field is not empty.
/// - `email`: Validates the format of the entered email.
  final TextFieldBloc email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  /// Bloc for the password input field.
  /// 
  /// This field uses the following validators:
  /// - `required`: Ensures the field is not empty.
/// - `passwordMin6Chars`: Ensures the password has a minimum length of 6 characters.
  final TextFieldBloc password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars,
    ],
  );

  /// Constructor for `LoginFormBloc`.
  /// 
  /// Initializes the bloc by adding `email` and `password` field blocs to the form.
  LoginFormBloc() {
    addFieldBlocs(
      fieldBlocs: [
        email,
        password,
      ],
    );
  }

  /// Handles the form submission process.
  /// 
  /// This method:
  /// - Validates the input fields (`email` and `password`).
  /// - Checks for internet connectivity before attempting to log in.
  /// - Uses Firebase Authentication to sign in the user with the provided credentials.
  /// - Emits success or failure responses based on the outcome.
  /// - Initializes Firebase Messaging to retrieve a push notification token upon successful login.
  @override
  Future<void> onSubmitting() async {
    debugPrint('Email: ${email.value}');
    debugPrint('Password: ${password.value}');

    try {
      // Verify internet connectivity before proceeding.
      final bool isConnected = await InternetConnection().hasInternetAccess;

      if (!isConnected) {
        // Internet is not available; emit a failure response.
        emitFailure(failureResponse: "No internet connection!");
        return;
      }

      // Attempt to sign in the user with email and password.
      final UserCredential userCredentials =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      // Initialize Firebase Messaging token for push notifications.
      FirebaseMessaging.instance.getToken().then((token) {
        debugPrint("Firebase Messaging Token: $token");
      });

      debugPrint(userCredentials.toString());
      debugPrint("Logged in successfully");

      // Emit success response if login is successful.
      emitSuccess(successResponse: "You have logged in successfully!");
    } on FirebaseAuthException catch (_) {
      // Handle specific Firebase authentication errors.
      emitFailure(
        failureResponse: "Invalid email or password. Please try again!",
      );
    } catch (error) {
      // Handle any other unexpected errors.
      debugPrint(error.toString());
      emitFailure(failureResponse: "An unknown error occurred.");
    }
  }
}
