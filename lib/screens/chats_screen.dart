import 'package:chatify/design_widgets/chats/body.dart';
import 'package:chatify/screens/group_creation_screen.dart';
import 'package:chatify/screens/settings_screen.dart';
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
  String searchQuery = '';
  bool _isSearching = false; // Do obsługi animowanego przejścia wyszukiwania
  final TextEditingController _searchController = TextEditingController();

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
  backgroundColor: kPrimaryColor,
  automaticallyImplyLeading: false,
  title: Padding(
    padding: EdgeInsets.only(
      left: 8,
      right: 8,
    ),
    child: _isSearching
        ? _buildSearchField()
        : Text(
            _selectedIndex == 0 ? "Group Chats" : "Settings",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
  ),
  actions: [
    if (_selectedIndex == 0) ...[
      IconButton(
        icon: Icon(_isSearching ? Icons.close : Icons.search),
        onPressed: () {
          setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) {
              _searchController.clear();
              searchQuery = '';
            }
          });
        },
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = 1;
            });
          },
          child: CircleAvatar(
            backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? NetworkImage(profileImageUrl!)
                : const AssetImage("assets/images/noProfileImg.png") as ImageProvider,
          ),
        ),
      ),
    ],
  ],
),

      body: _selectedIndex == 0
          ? Body(searchQuery: searchQuery)
          : const SettingsScreen(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
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
            )
          : null,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      onChanged: (value) {
        setState(() {
          searchQuery = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search chats...',
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
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
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: "Chats",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Settings",
        ),
      ],
    );
  }
}
