import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

/// A simplified input widget with fieldBloc and autofillHints support.
/// Reflects the previous design, keeping it clean and modern.
class InputWidget extends StatelessWidget {
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextInputType? textInputType;
  final TextFieldBloc fieldBloc;

  const InputWidget({
    Key? key,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.autofillHints,
    this.textInputType,
    required this.fieldBloc, // Required fieldBloc for handling form logic
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldBlocBuilder(
          textFieldBloc: fieldBloc, // Using the fieldBloc for form management
          obscureText: obscureText,
          autofillHints: autofillHints, // Support for autofill hints
          keyboardType: textInputType,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12.0), // Padding for the icon
                    child: Icon(
                      prefixIcon,
                      color: Theme.of(context).primaryColor.withOpacity(0.7), // Icon color
                    ),
                  )
                : null,
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 14.0,
              color: Colors.grey, // Subtle grey for hint text
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1), // Light background for the input field
            contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0), // Spacious padding for the input
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Colors.transparent, // No visible border in the default state
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor, // Border color when focused
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.red, // Border color when there is an error
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.red, // Border color when focused with an error
              ),
            ),
          ),
        ),
        
      ],
    );
  }
}
