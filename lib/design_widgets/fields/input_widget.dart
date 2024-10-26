import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

/// A simplified input widget with fieldBloc and autofillHints support.
/// Reflects a clean and modern design.
class InputWidget extends StatelessWidget {
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextInputType? textInputType;
  final TextFieldBloc fieldBloc;

  const InputWidget({
    Key? key,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.autofillHints,
    this.textInputType,
    required this.fieldBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a standard gray color for hint and suffix icon if not otherwise defined
    final Color iconColor = Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldBlocBuilder(
          textFieldBloc: fieldBloc,
          suffixButton: obscureText ? SuffixButton.obscureText : null,
          autofillHints: autofillHints,
          keyboardType: textInputType,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Icon(
                      prefixIcon,
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                    ),
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: iconColor),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14.0,
              color: iconColor,
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 0.0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4.0),
      ],
    );
  }
}
