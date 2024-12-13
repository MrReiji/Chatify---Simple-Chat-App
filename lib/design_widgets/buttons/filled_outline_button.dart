import 'package:chatify/constants/constants.dart';
import 'package:flutter/material.dart';

/// A customizable button widget that can be either filled or outlined.
///
/// The `FillOutlineButton` provides a flexible design for buttons
/// that adapt their appearance based on the `isFilled` parameter.
/// - If `isFilled` is `true`, the button has a filled white background.
/// - If `isFilled` is `false`, the button is outlined with a transparent background.
///
/// This widget is reusable and can be used for various actions in the app.
///
/// ### Example Usage:
/// ```dart
/// FillOutlineButton(
///   isFilled: true,
///   text: "Click Me",
///   press: () {
///     print("Button Pressed");
///   },
/// );
/// ```
class FillOutlineButton extends StatelessWidget {
  /// Indicates whether the button is filled or outlined.
  ///
  /// Defaults to `true` (filled).
  final bool isFilled;

  /// The callback function that is triggered when the button is pressed.
  final VoidCallback press;

  /// The text displayed inside the button.
  final String text;

  /// Constructor for `FillOutlineButton`.
  ///
  /// - `isFilled`: Optional. Defaults to `true`.
  /// - `press`: Required. Callback function to handle button press events.
  /// - `text`: Required. The text to display inside the button.
  const FillOutlineButton({
    super.key,
    this.isFilled = true,
    required this.press,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      // Button shape and border styling
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: Colors.white), // White border
      ),
      elevation: isFilled ? 2 : 0, // Elevation for filled buttons
      color: isFilled ? Colors.white : Colors.transparent, // Background color
      onPressed: press, // Trigger the provided callback function
      child: Text(
        text, // Display the button text
        style: TextStyle(
          color: isFilled ? kContentColorLightTheme : Colors.white, // Text color
          fontSize: 12, // Text font size
        ),
      ),
    );
  }
}
