import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final _firebase = FirebaseAuth.instance;

class LoginFormBloc extends FormBloc<String, String> {
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

  LoginFormBloc() {
    addFieldBlocs(
      fieldBlocs: [
        email,
        password,
      ],
    );
  }

  @override
  void onSubmitting() async {
    debugPrint(email.value);
    debugPrint(password.value);

    try {
      // Sprawdzenie dostępności połączenia internetowego za pomocą klasy InternetConnection
      final bool isConnected = await InternetConnection().hasInternetAccess;

      if (!isConnected) {
        emitFailure(failureResponse: "No internet connection!");
        return;
      }

      // Logowanie do Firebase przy pomocy emaila i hasła
      final userCredentials = await _firebase.signInWithEmailAndPassword(
        email: email.value, 
        password: password.value,
      );
      
      debugPrint(userCredentials.toString());
      debugPrint("Logged in");
      emitSuccess(successResponse: "You have logged in successfully!");
    } on FirebaseAuthException catch (_) {
      emitFailure(failureResponse: "Invalid email or password. Please try again!");
    } catch (error) {
      debugPrint(error.toString());
      emitFailure(failureResponse: "An unknown error occurred.");
    }
  }
}
