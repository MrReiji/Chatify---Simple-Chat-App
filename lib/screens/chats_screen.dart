import 'package:chatify/design_widgets/chats/body.dart';
import 'package:chatify/screens/group_creation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatify/constants/constants.dart';
import 'package:chatify/utils/user_service.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  int _selectedIndex = 0;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  Future<void> _fetchUserProfileImage() async {
    final imageUrl = await getUserProfileImageUrl();
    setState(() {
      profileImageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Group Chats",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings screen
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to user profile
              },
              child: CircleAvatar(
                backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? NetworkImage(profileImageUrl!)
                    : const AssetImage("assets/images/noProfileImg.png") as ImageProvider,
              ),
            ),
          ),
        ],
      ),
      body: const Body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GroupCreationScreen()),
          );
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(
          Icons.group_add,
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
        // TODO: Handle navigation based on selected index
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: "Chats",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: "People",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.call),
          label: "Calls",
        ),
        BottomNavigationBarItem(
          icon: CircleAvatar(
            radius: 14,
            backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? NetworkImage(profileImageUrl!)
                : const AssetImage("assets/images/noProfileImg.png") as ImageProvider,
          ),
          label: "Profile",
        ),
      ],
    );
  }
}
