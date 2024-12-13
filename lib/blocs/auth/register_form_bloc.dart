import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Singleton instance of FirebaseAuth used for authentication operations.
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

/// Custom exception that is thrown when no image is selected during registration.
class SelectedImageIsNullException implements Exception {}

/// A form bloc that handles user registration functionality.
///
/// This class manages:
/// - Input validation for `email`, `password`, `confirmPassword`, and `username` fields.
/// - Checking for internet connectivity before proceeding with registration.
/// - Creating a new user account in Firebase Authentication.
/// - Uploading the user's profile image to Firebase Storage.
/// - Storing user data in Firestore.
class RegisterFormBloc extends FormBloc<String, String> {
  /// The image file selected by the user for their profile picture.
  File? selectedImage;

  /// Bloc for the email input field.
  /// 
  /// Validators:
  /// - `required`: Ensures the field is not empty.
  /// - `email`: Validates the format of the entered email.
  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  /// Bloc for the password input field.
  /// 
  /// Validators:
  /// - `required`: Ensures the field is not empty.
  /// - `passwordMin6Chars`: Ensures the password has a minimum length of 6 characters.
  final password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars,
    ],
  );

  /// Bloc for the confirm password input field.
  /// 
  /// Validators:
  /// - `required`: Ensures the field is not empty.
  /// - `passwordMin6Chars`: Ensures the password has a minimum length of 6 characters.
  /// - Ensures the value matches the `password` field value.
  final confirmPassword = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars,
    ],
  );

  /// Bloc for the username input field.
  /// 
  /// Validators:
  /// - `required`: Ensures the field is not empty.
  final username = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  /// Constructor for `RegisterFormBloc`.
  ///
  /// Initializes the form blocs and adds a validator to ensure `confirmPassword` matches `password`.
  RegisterFormBloc() {
    addFieldBlocs(
      fieldBlocs: [
        email,
        password,
        confirmPassword,
        username,
      ],
    );

    // Validate that the confirm password matches the password.
    confirmPassword
      ..addValidators([FieldBlocValidators.confirmPassword(password)])
      ..subscribeToFieldBlocs([password]);
  }

  /// Handles the form submission process.
  ///
  /// This method:
  /// 1. Validates if a profile image has been selected.
  /// 2. Checks internet connectivity before proceeding.
  /// 3. Creates a new user account in Firebase Authentication.
  /// 4. Uploads the user's profile image to Firebase Storage.
  /// 5. Stores the user's information (username, email, profile image URL) in Firestore.
  /// 6. Emits a success or failure response based on the outcome.
  @override
  Future<void> onSubmitting() async {
    try {
      // Check if an image has been selected.
      if (selectedImage == null) {
        debugPrint('No image selected.');
        throw SelectedImageIsNullException();
      }
      debugPrint('Selected image path: ${selectedImage!.path}');

      // Check for internet connectivity.
      final bool isConnected = await InternetConnection().hasInternetAccess;
      debugPrint('Internet connectivity: $isConnected');
      if (!isConnected) {
        debugPrint('No internet connection.');
        emitFailure(failureResponse: "No internet connection!");
        return;
      }

      // Create a new user account with Firebase Authentication.
      debugPrint('Creating user with email: ${email.value}');
      final UserCredential userCredentials =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );
      debugPrint('User registered: ${userCredentials.user!.uid}');

      // Upload the selected image to Firebase Storage.
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${userCredentials.user!.uid}.jpg');

      debugPrint('Uploading image to Firebase Storage...');
      await storageRef.putFile(selectedImage!);
      debugPrint('Image uploaded to Firebase Storage.');

      // Get the download URL of the uploaded image.
      final String imageUrl = await storageRef.getDownloadURL();
      debugPrint('Image URL obtained: $imageUrl');

      // Save user information in Firestore.
      debugPrint('Saving user information to Firestore...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
        'username': username.value,
        'email': email.value,
        'image_url': imageUrl,
      });
      debugPrint('User information saved to Firestore.');

      // Registration successful.
      emitSuccess(successResponse: "Account created successfully!");
      debugPrint('Registration process completed successfully.');
    } on FirebaseAuthException catch (error) {
      debugPrint('FirebaseAuthException: ${error.code} - ${error.message}');
      if (error.code == 'email-already-in-use') {
        emitFailure(failureResponse: "Email already in use. Please sign in!");
      } else {
        emitFailure(
            failureResponse: "Authentication failed! ${error.message}");
      }
    } on SelectedImageIsNullException {
      debugPrint('SelectedImageIsNullException: No image selected.');
      emitFailure(failureResponse: 'Please select a profile image!');
    } catch (error) {
      debugPrint('An unknown error occurred: $error');
      emitFailure(failureResponse: "An unknown error occurred.");
    }
  }
}
