import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:portfoliobuilderslms/login.dart';
import 'package:portfoliobuilderslms/registration.dart';
import 'package:portfoliobuilderslms/user/liveclass.dart';
import 'package:portfoliobuilderslms/user/modules.dart';
import 'package:portfoliobuilderslms/user/usercourse.dart';

class UserDashboardScreen extends StatefulWidget {
  final String userId;

  const UserDashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  String selectedContent = 'Course Content';
  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void updateContent(String newContent) {
    setState(() {
      selectedContent = newContent;
    });
  }

  void handleMenuSelection(String value) {
    if (value == 'Settings') {
      updateContent('Settings');
    } else if (value == 'Sign Out') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegistrationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      appBar: isLargeScreen
          ? null
          : AppBar(
              title: Text('Dashboard'),
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: handleMenuSelection,
                  itemBuilder: (BuildContext context) {
                    return {'Settings', 'Sign Out'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
      drawer: isLargeScreen
          ? null
          : Drawer(
              child: Sidebar(
                isLargeScreen: isLargeScreen,
                onMenuItemSelected: updateContent,
                searchController: searchController,
                selectedContent: selectedContent, // Pass selectedContent here
              ),
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (isLargeScreen)
                Sidebar(
                  isLargeScreen: isLargeScreen,
                  onMenuItemSelected: updateContent,
                  searchController: searchController,
                  selectedContent: selectedContent, // Pass selectedContent here
                ),
              Expanded(
                child: ContentArea(
                  isLargeScreen: isLargeScreen,
                  selectedContent: selectedContent,
                  searchController: searchController,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final Function(String) onMenuItemSelected;
  final TextEditingController searchController;
  final bool isLargeScreen;
  final String selectedContent;

  Sidebar({
    required this.onMenuItemSelected,
    required this.searchController,
    required this.isLargeScreen,
    required this.selectedContent,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = isLargeScreen ? 300.0 : MediaQuery.of(context).size.width * 0.8;

    return Card(
      elevation: 4,
      child: Container(
        color: Colors.white,
        width: sidebarWidth,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserCard(userId: 'userId',),
            SizedBox(height: 20),
            SearchField(searchController: searchController),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: MainMenu(
                  isLargeScreen: isLargeScreen,
                  onMenuItemSelected: onMenuItemSelected,
                  selectedContent: selectedContent, // Pass selectedContent here
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class UserCard extends StatelessWidget {
  final String userId;

  UserCard({required this.userId});

  Future<Map<String, String>> _fetchUserData(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? 'Name',
          'email': data['email'] ?? 'Email',
          'role': data['role'] ?? 'student',
        };
      } else {
        return {'name': 'Name', 'email': 'No Email', 'role': 'student'};
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {'name': 'Name', 'email': 'Email', 'role': 'student'};
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Replace with actual login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _fetchUserData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading user data');
        } else if (snapshot.hasData) {
          final userData = snapshot.data!;
          return Column(
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['name']!,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            userData['email']!,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 209, 209, 209),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Text(
                              userData['role']!,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _logout(context),
                label: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24), backgroundColor: const Color.fromARGB(255, 16, 61, 27),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.redAccent.withOpacity(0.5),
                  elevation: 5,
                ),
              ),
            ],
          );
        } else {
          return Text('No data available');
        }
      },
    );
  }
}


class SearchField extends StatelessWidget {
  final TextEditingController searchController;

  SearchField({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.greenAccent,
          ),
          labelText: 'Search...',
          labelStyle: TextStyle(color: Colors.greenAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.greenAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.greenAccent),
          ),
        ),
      ),
    );
  }
}

class MainMenu extends StatelessWidget {
  final Function(String) onMenuItemSelected;
  final bool isLargeScreen;
  final String selectedContent;

  MainMenu({required this.onMenuItemSelected, required this.isLargeScreen, required this.selectedContent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                'Main Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SidebarButton(
              icon: Icons.home,
              text: 'Dashboard',
              isSelected: selectedContent == 'Dashboard', // Highlight if selected
              onTap: () => onMenuItemSelected('Dashboard'),
            ),
            SidebarButton(
              icon: Icons.list,
              text: 'Course Content',
              isSelected: selectedContent == 'Course Content', // Highlight if selected
              onTap: () => onMenuItemSelected('Course Content'),
            ),
            SidebarButton(
              icon: Icons.live_tv,
              text: 'Live Classes',
              isSelected: selectedContent == 'Live Classes', // Highlight if selected
              onTap: () => onMenuItemSelected('Live Classes'),
            ),
            SidebarButton(
              icon: Icons.person,
              text: 'Profile',
              isSelected: selectedContent == 'Profile', // Highlight if selected
              onTap: () => onMenuItemSelected('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isSelected;

  SidebarButton({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.green[50],  // Highlight selected
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.green[700],
            ),
            SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 0, 0, 0)),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentArea extends StatelessWidget {
  final String selectedContent;
  final TextEditingController searchController;
  final bool isLargeScreen;  // Accepting isLargeScreen

  const ContentArea({required this.selectedContent, required this.searchController, required this.isLargeScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedContent,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 20),
          Expanded(child: _buildContent(selectedContent)),
        ],
      ),
    );
  }

  Widget _buildContent(String selectedContent) {
    switch (selectedContent) {
      case 'Dashboard':
        return UserAllocatedCoursesPage();
      case 'Course Management':
        return UserAllocatedCoursesPage();
         case 'Live Classes':
        return UserLiveViewPage();
        case 'Profile':
        return Text("Coming Soon");

        
      
      default:
        return UserAllocatedCoursesPage();
    }
  }
}