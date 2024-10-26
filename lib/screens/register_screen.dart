import 'dart:io';
import 'package:chatify/blocs/auth/register_form_bloc.dart';
import 'package:chatify/constants/constants.dart';
import 'package:chatify/design_widgets/buttons/primary_button.dart';
import 'package:chatify/design_widgets/dialogs/loading_dialog.dart';
import 'package:chatify/design_widgets/fields/input_widget.dart';
import 'package:chatify/design_widgets/fields/user_image_picker.dart';
import 'package:chatify/screens/chats_screen.dart';
import 'package:chatify/screens/login_screen.dart';
import 'package:chatify/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterFormBloc(),
      child: Builder(
        builder: (context) {
          final registerFormBloc = context.read<RegisterFormBloc>();

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: FormBlocListener<RegisterFormBloc, String, String>(
              onSubmitting: (context, state) {
                debugPrint('Form is submitting...');
                LoadingDialog.show(context);
              },
              onSubmissionFailed: (context, state) {
                debugPrint('Form submission failed.');
                LoadingDialog.hide(context);
              },
              onSuccess: (context, state) {
                debugPrint('Form submitted successfully.');
                LoadingDialog.hide(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatsScreen(),
                  ),
                );
              },
              onFailure: (context, state) {
                debugPrint('Form submission failed: ${state.failureResponse}');
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.failureResponse!)),
                );
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: kDefaultPadding),
                        Text(
                          "Join Chatify Today!",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        Text(
                          "Create an account to connect with friends and explore new conversations.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge!.color,
                              ),
                        ),
                        const SizedBox(height: kDefaultPadding),

                        // Profile picture selection
                        UserImagePicker(
                          onPickImage: (pickedImage) {
                            debugPrint('Image picked: ${pickedImage.path}');
                            registerFormBloc.selectedImage = pickedImage;
                          },
                        ),

                        const SizedBox(height: kDefaultPadding / 2),

                        // Username input field
                        InputWidget(
                          hintText: "Username",
                          prefixIcon: Icons.person,
                          fieldBloc: registerFormBloc.username,
                          autofillHints: const [AutofillHints.newUsername],
                        ),

                        // Email input field
                        InputWidget(
                          hintText: "Email",
                          prefixIcon: Icons.email,
                          textInputType: TextInputType.emailAddress,
                          fieldBloc: registerFormBloc.email,
                          autofillHints: const [AutofillHints.email],
                        ),

                        // Password input field
                        InputWidget(
                          hintText: "Password",
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          textInputType: TextInputType.visiblePassword,
                          fieldBloc: registerFormBloc.password,
                          autofillHints: const [AutofillHints.newPassword],
                        ),

                        // Confirm Password input field
                        InputWidget(
                          hintText: "Confirm Password",
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          textInputType: TextInputType.visiblePassword,
                          fieldBloc: registerFormBloc.confirmPassword,
                          autofillHints: const [AutofillHints.newPassword],
                        ),

                        const SizedBox(height: kDefaultPadding),

                        // Create Account button
                        PrimaryButton(
                          text: "Create Account",
                          press: () {
                            debugPrint('Create Account button pressed.');
                            registerFormBloc.submit();
                          },
                        ),

                        const SizedBox(height: kDefaultPadding),

                        // Already have an account? Go back to Sign In screen
                        TextButton(
                          onPressed: () {
                            debugPrint('Navigating to LoginScreen.');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).textTheme.headlineSmall?.color,
                                  ),
                              children: [
                                TextSpan(
                                  text: "Sign In",
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
