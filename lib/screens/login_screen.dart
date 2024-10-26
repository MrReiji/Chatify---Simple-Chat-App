import 'package:chatify/blocs/auth/login_form_bloc.dart';
import 'package:chatify/constants/constants.dart';
import 'package:chatify/design_widgets/buttons/primary_button.dart';
import 'package:chatify/design_widgets/dialogs/loading_dialog.dart';
import 'package:chatify/design_widgets/fields/input_widget.dart';
import 'package:chatify/screens/chats_screen.dart';
import 'package:chatify/screens/register_screen.dart';
import 'package:chatify/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

/// The `LoginScreen` widget provides a user interface for users to sign in to their accounts.
/// It uses `flutter_form_bloc` for form state management and validation.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginFormBloc(),
      child: Builder(
        builder: (context) {
          final loginFormBloc = context.read<LoginFormBloc>();

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: FormBlocListener<LoginFormBloc, String, String>(
              onSubmitting: (context, state) {
                LoadingDialog.show(context);
              },
              onSubmissionFailed: (context, state) {
                LoadingDialog.hide(context);
              },
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatsScreen(),
                  ),
                );
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.failureResponse!)),
                );
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: kDefaultPadding),
                        // App logo centered at the top.
                        Center(
                          child: Image.asset(
                            "assets/images/logo.png",
                            scale: 4,
                          ),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        // Heading text.
                        Text(
                          "Sign in to your account",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.color,
                              ),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        // Email input field.
                        InputWidget(
                          hintText: "Email",
                          prefixIcon: Icons.email_outlined,
                          textInputType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          fieldBloc: loginFormBloc.email,
                        ),
                        // Password input field.
                        InputWidget(
                          hintText: "Password",
                          prefixIcon: Icons.lock_outlined,
                          obscureText: true,
                          textInputType: TextInputType.visiblePassword,
                          autofillHints: const [AutofillHints.password],
                          fieldBloc: loginFormBloc.password,
                        ),
                        const SizedBox(height: kDefaultPadding),
                        // Sign In button.
                        PrimaryButton(
                          text: "Sign In",
                          press: () => loginFormBloc.submit(),
                        ),
                        const SizedBox(height: kDefaultPadding * 2),
                        // Navigation to the Register screen.
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.color,
                                  ),
                              children: [
                                TextSpan(
                                  text: "Sign Up",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: kDefaultPadding * 2),
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
