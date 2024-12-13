import 'package:chatify/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String username = 'Guest';
  String email = 'notavailable@example.com';
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Pobierz obecnego użytkownika
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        email = user.email ?? email;

        // Pobierz dokument użytkownika z Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc.get('username') ?? username;
            profileImageUrl = userDoc.get('image_url');
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zaktualizowany nagłówek z awatarem użytkownika, nazwą i e-mailem
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Awatar z Firebase Storage lub domyślną ikoną użytkownika
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: kPrimaryColor.withOpacity(0.2),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null
                          ? Icon(Icons.person, size: 44, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Dane użytkownika w układzie pionowym
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),

            // Sekcja ustawień ogólnych
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () {
                      // Logika zmiany języka
                    },
                  ),
                  SettingsTile.switchTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Enable Dark Mode',
                    value: false,
                    onChanged: (bool value) {
                      // Logika przełączania trybu ciemnego
                    },
                  ),
                  SettingsTile.switchTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Allow Notifications',
                    value: true,
                    onChanged: (bool value) {
                      // Logika powiadomień
                    },
                  ),
                  SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    onTap: () {
                      // Przejście do ekranu zmiany hasła
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),

            // Sekcja wylogowania
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SettingsTile(
                icon: Icons.exit_to_app,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for each settings tile
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  static Widget switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: kPrimaryColor),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: kPrimaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}
