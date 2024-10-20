import 'package:chatify/screens/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2), // Adds flexible space before the logo
            Center(
              child: Image.asset(
                "assets/images/logo.png",
                scale: 5,
              ),
            ),
            // Display the app name "Chatify" with custom styling
            Text(
              "Chatify",
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 100,
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.color, // Use theme-defined color for text
              ),
            ),
            const Spacer(flex: 1), // Adds flexible space between elements
            // Display a welcoming message for the user
            Text(
              "Stay connected with friends \nand family, anytime.",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              "Quick, reliable, and secure \nmessaging at your fingertips.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withOpacity(
                        0.64), // Slightly transparent text for a softer look
              ),
            ),
            const Spacer(flex: 3), // Adds more space before the button
            // "Next" button for navigating to the next screen
            FittedBox(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "Next",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withOpacity(
                                    0.8), // Slightly transparent button text
                          ),
                    ),
                    const SizedBox(
                        width: kDefaultPadding /
                            4), // Spacing between text and icon
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.8),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
