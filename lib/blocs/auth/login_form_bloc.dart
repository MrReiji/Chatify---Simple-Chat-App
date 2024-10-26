import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// Singleton instance of FirebaseAuth used for authentication operations.
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

/// A form bloc that handles user login functionality.
/// Manages the email and password fields, validates input,
/// checks for internet connectivity, and performs sign-in using Firebase Authentication.
class LoginFormBloc extends FormBloc<String, String> {
  /// Bloc for the email input field, with validators for required field and proper email format.
  final TextFieldBloc email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  /// Bloc for the password input field, with validators for required field and minimum length.
  final TextFieldBloc password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars,
    ],
  );

  /// Initializes the form bloc by adding the email and password field blocs.
  LoginFormBloc() {
    addFieldBlocs(
      fieldBlocs: [
        email,
        password,
      ],
    );
  }

  /// Handles form submission.
  /// Validates input, checks internet connectivity,
  /// and attempts to sign in the user with Firebase Authentication.
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

      debugPrint(userCredentials.toString());
      debugPrint("Logged in successfully");

      emitSuccess(successResponse: "You have logged in successfully!");
    } on FirebaseAuthException catch (_) {
      emitFailure(
        failureResponse: "Invalid email or password. Please try again!",
      );
    } catch (error) {
      debugPrint(error.toString());
      emitFailure(failureResponse: "An unknown error occurred.");
    }
  }
}
