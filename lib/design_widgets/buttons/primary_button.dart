import '../../constants/constants.dart';
import 'package:flutter/material.dart';

/// A customizable primary button widget used for prominent actions in the app.
///
/// The `PrimaryButton` is designed to serve as the main action button
/// with customizable text, color, and padding. It is suitable for actions
/// that require user attention.
///
/// ### Example Usage:
/// ```dart
/// PrimaryButton(
///   text: "Get Started",
///   press: () {
///     print("Button Pressed");
///   },
///   color: Colors.blue,
///   padding: EdgeInsets.symmetric(vertical: 20),
/// );
/// ```
class PrimaryButton extends StatelessWidget {
  /// The text displayed on the button.
  final String text;

  /// The callback function that is triggered when the button is pressed.
  final VoidCallback press;

  /// The background color of the button.
  ///
  /// Defaults to `kPrimaryColor` from the constants file.
  final Color color;

  /// The padding inside the button.
  ///
  /// Defaults to `EdgeInsets.all(kDefaultPadding * 0.75)`.
  final EdgeInsets padding;

  /// Constructor for `PrimaryButton`.
  ///
  /// - `text`: Required. The text to display on the button.
  /// - `press`: Required. Callback function to handle button press events.
  /// - `color`: Optional. Sets the button's background color. Defaults to `kPrimaryColor`.
  /// - `padding`: Optional. Sets the padding around the button text. Defaults to `EdgeInsets.all(kDefaultPadding * 0.75)`.
  const PrimaryButton({
    super.key,
    required this.text,
    required this.press,
    this.color = kPrimaryColor,
    this.padding = const EdgeInsets.all(kDefaultPadding * 0.75),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      // Styling the button shape and padding
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(40)), // Rounded corners
      ),
      padding: padding, // Padding inside the button
      color: color, // Background color
      minWidth: double.infinity, // Button takes full width
      onPressed: press, // Trigger the provided callback function
      child: Text(
        text, // Display the button text
        style: const TextStyle(
          color: Colors.white, // Text color
        ),
      ),
    );
  }
}
