import 'package:chatify/constants/constants.dart';
import 'package:chatify/design_widgets/buttons/primary_button.dart';
import 'package:chatify/screens/login_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Placeholder for the selected profile image
  String? profileImagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
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
                  color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color,
                ),
              ),
              const SizedBox(height: kDefaultPadding * 2),

              // Profile picture selection area
              GestureDetector(
                onTap: () {
                  // Open image picker to select profile picture (implement image picker functionality)
                  // setState(() => profileImagePath = 'path_to_image');
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  backgroundImage: profileImagePath != null
                      ? AssetImage(profileImagePath!)
                      : null,
                  child: profileImagePath == null
                      ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey.withOpacity(0.7))
                      : null,
                ),
              ),
              const SizedBox(height: kDefaultPadding),

              // Nickname input field
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.grey.withOpacity(0.7)),
                  hintText: "Username",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: kDefaultPadding),

              // Email input field
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colors.grey.withOpacity(0.7)),
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: kDefaultPadding),

              // Password input field
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.grey.withOpacity(0.7)),
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: kDefaultPadding),

              // Confirm Password input field
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.grey.withOpacity(0.7)),
                  hintText: "Confirm Password",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: kDefaultPadding * 2),

              // Sign Up button
              PrimaryButton(
                text: "Create Account",
                press: () {
                  // Implement sign-up action
                },
              ),
              const SizedBox(height: kDefaultPadding * 2),

              // Already have an account? Go back to Sign In screen
              TextButton(
                 onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.color,
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
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
