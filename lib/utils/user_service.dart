import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Function to fetch the user's profile image URL
Future<String?> getUserProfileImageUrl() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userData['image_url'] ?? '';
    }
  } catch (e) {
    print("Error fetching user image: $e");
  }
  return null;
}