import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final _firebase = FirebaseAuth.instance;

class RegisterFormBloc extends FormBloc<String, String> {
  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars,
    ],
  );

  final confirmPassword = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars,
    ],
  );

  final username = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  RegisterFormBloc() {
    addFieldBlocs(
      fieldBlocs: [
        email,
        password,
        confirmPassword,
        username,
      ],
    );

    // Confirm password validation - password must match confirm password
    confirmPassword
      ..addValidators([FieldBlocValidators.confirmPassword(password)])
      ..subscribeToFieldBlocs([password]);
  }

  @override
  void onSubmitting() async {
    debugPrint('Email: ${email.value}');
    debugPrint('Password: ${password.value}');
    debugPrint('Confirm Password: ${confirmPassword.value}');
    debugPrint('Username: ${username.value}');

    try {
      // Sprawdzenie dostępności połączenia internetowego przy użyciu InternetConnectionCheckerPlus
      final bool isConnected = await InternetConnection().hasInternetAccess;

      if (!isConnected) {
        emitFailure(failureResponse: "No internet connection!");
        return;
      }

      // Tworzenie konta w Firebase Authentication
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
        email: email.value, 
        password: password.value,
      );

      debugPrint("User registered: $userCredentials");

      // Zapis użytkownika w kolekcji 'users' w Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
        'username': username.value,
        'email': email.value,
      });

      // Rejestracja zakończona sukcesem
      emitSuccess(successResponse: "Account created successfully!");
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        emitFailure(failureResponse: "Email already in use. Sign in!");
      } else {
        emitFailure(failureResponse: "Authentication failed! ${error.message}");
      }
    } catch (error) {
      debugPrint(error.toString());
      emitFailure(failureResponse: "An unknown error occurred.");
    }
  }
}
