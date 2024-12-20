import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymbro/Screens/Chats/chat_page.dart';
import 'package:gymbro/Screens/Search/search_page.dart';
import 'package:gymbro/Screens/authentication/sign_in.dart';
import '../PostAdds/new_post_screen.dart';
import '../TimeLine/timeline_page.dart';
import 'package:gymbro/Screens/Profile/profile_page.dart';
import 'package:gymbro/Screens/Notifications/notifications_screen.dart';
import 'package:gymbro/Services/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro/Screens/Chats/chat_screen.dart';

/// HomeScreen of the application.
/// Provides Navigation to various pages in the application and maintains their
/// state.
/// Default first page is [TimelinePage].

class HomeScreen extends StatefulWidget {

  // create a new HomeScreen
  const HomeScreen({Key? key}) : super(key:key);

  // list of pages available from the home screen
  static const List<Widget> _homePages = <Widget>[
    TimelinePage(),
    Center(child: Text('SearchPage')),
    NewPostScreen(),
    // Center(child: Text('AchievementPage')),
    Center(child: Text('ProfilePage')),
  ];

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Control and manage a scrollable list of pages, typically used with
  // widgets like PageView or ViewPager.
  final PageController pageController = PageController();
  AuthService? _authService;
  final currentUserID = AuthService().currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _authService = AuthService(); // Initialize _authService
  }

  void navigateToLicensePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LicensePage(
          applicationName: 'GymBro',
          applicationVersion: '1.0.0',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.black;
    return Scaffold(
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        title:
          const Text(
              'GymBro',
              style: TextStyle(
                fontFamily: 'KaushanScript',
                color: Color(0xFF000000),
                fontSize: 35,
              ),
          ),
        automaticallyImplyLeading: false, // Hide the back button
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFFDEBB00),
        actions: [
          IconButton(
            icon:  const Icon(Icons.info_outline),
            onPressed: () {
              navigateToLicensePage(context);
            },
          ),
          IconButton(
            icon: const Icon(
                Icons.notifications_active_outlined,
                size: 28,
            ),
            onPressed: () {
              // Navigate to the notifications page or perform any other action
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.messenger_outline,
              size: 28,
            ),
            onPressed: () {
              // Navigate to the chat screen or perform any other action
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatPage(userID: currentUserID)),
              );
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.logout,
              size: 28,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Cancel button pressed, close the dialog
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Logout button pressed, close the dialog and perform logout
                          Navigator.of(context).pop(true);
                          await _authService?.signOut(); // Call the signOut method from auth.dart
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SignIn()),
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),

        ],
      ),
      // Displays a scrollable list of pages, and you can navigate
      // between these pages by swiping horizontally or programmatically
      // through a PageController.
      body: PageView(
        controller: pageController,
        // scrolling behavior of the PageView
        // won't be able to scroll the pages manually, and
        // the navigation between pages will be controlled
        // solely by the PageController.
        physics: const NeverScrollableScrollPhysics(),
        children: HomeScreen._homePages,
      ),
      bottomNavigationBar: _HomeScreenBottomNavBar(
        pageController: pageController,
      ),
    );
  }
}

class _HomeScreenBottomNavBar extends StatefulWidget {
  const _HomeScreenBottomNavBar({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  final PageController pageController;

  @override
  State<_HomeScreenBottomNavBar> createState() => _HomeScreenBottomNavBarState();
}

class _HomeScreenBottomNavBarState extends State<_HomeScreenBottomNavBar> {
  void _onNavigationItemTapped(int index) {
    if (index == 2) {
      // Navigate to AddPostScreen
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewPostScreen()),
      );
    }
    else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchPage()),
      );
    }
    else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfilePage()),
      );
    }
    else {
      widget.pageController.jumpToPage(index);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BottomNavigationBar(
        onTap: _onNavigationItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        iconSize: 28,
        currentIndex: widget.pageController.page?.toInt() ?? 0,
        backgroundColor: const Color(0xFFDEBB00),
        type: BottomNavigationBarType.fixed, // Add this line
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home'
          ),

          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search),
              activeIcon: Icon(
                Icons.search,
                size: 22,
              ),
              label: 'Search',
          ),

          BottomNavigationBarItem(
            icon: Icon(
                Icons.add_circle_outline,
                size: 40,
            ), // Add icon similar to Instagram
            activeIcon: Icon(Icons.add),
            label: 'Add Post',
          ),

          // BottomNavigationBarItem(
          //   icon: Icon(Icons.emoji_events_outlined), // Trophy/achievement icon
          //   activeIcon: Icon(Icons.emoji_events), // Active/tapped trophy/achievement icon
          //   label: 'Achievements',
          // ),

          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Person',
          ),
        ],
      ),
    );
  }
}

