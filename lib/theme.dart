import 'package:chatify/screens/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light theme configuration
ThemeData lightThemeData(BuildContext context) {
  return ThemeData.light().copyWith(
    primaryColor: kPrimaryColor, // Set primary color to the defined purple
    scaffoldBackgroundColor: kIvoryWhite, // Use soft white (Ivory White) for light mode background
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0), // Minimalist app bar
    iconTheme: const IconThemeData(color: kContentColorLightTheme), // Icons follow light theme text color
    textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
        .apply(bodyColor: kContentColorLightTheme), // Google Font for text, applying the light theme color
    colorScheme: const ColorScheme.light(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
    ), // Define color scheme for the light theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kIvoryWhite, // Use Ivory White for bottom navigation background
      selectedItemColor: kPrimaryColor.withOpacity(0.7), // Purple for selected items
      unselectedItemColor: kContentColorLightTheme.withOpacity(0.32), // Faded text for unselected items
      selectedIconTheme: const IconThemeData(color: kPrimaryColor), // Purple icons when selected
      showUnselectedLabels: true,
    ),
  );
}

// Dark theme configuration remains unchanged
ThemeData darkThemeData(BuildContext context) {
  return ThemeData.dark().copyWith(
    primaryColor: kPrimaryColor, // Keep primary purple color
    scaffoldBackgroundColor: const Color(0xFF2A2A35), // Darker background for dark mode
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0, backgroundColor: Color(0xFF2A2A35)),
    iconTheme: const IconThemeData(color: kContentColorDarkTheme), // Icons follow dark theme text color
    textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
        .apply(bodyColor: kContentColorDarkTheme), // Google Font for text, applying the dark theme color
    colorScheme: const ColorScheme.dark().copyWith(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
    ), // Define color scheme for the dark theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF2A2A35), // Dark background for bottom navigation
      selectedItemColor: Colors.white70, // White for selected items in dark mode
      unselectedItemColor: kContentColorDarkTheme.withOpacity(0.32), // Faded text for unselected items
      selectedIconTheme: const IconThemeData(color: kPrimaryColor), // Purple icons when selected
      showUnselectedLabels: true,
    ),
  );
}

const appBarTheme = AppBarTheme(centerTitle: false, elevation: 0);
