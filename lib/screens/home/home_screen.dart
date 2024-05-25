import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_sync/screens/health/health_summary_screen.dart';
import 'package:health_sync/screens/meals/meal_log_screen.dart';
import 'package:health_sync/screens/settings/settings_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> screens = [];
  int selectedIndex = 0;
  late List<BottomNavigationBarItem> bottomNavItems;
  List<NavigationRailDestination> navRailItems = [];
  @override
  void initState() {
    super.initState();
    screens = [
      const Home(),
      HealthSummaryScreen(),
      const MealLogScreen(),
      Scaffold(appBar: AppBar(title: const Text("Chats"))),
      SettingsScreen(),
    ];
    bottomNavItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.dataset),
        label: "Health Data",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.fastfood_rounded),
        label: "Meals",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.chat),
        label: ("Chats"),
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: "Profile",
      ),
    ];
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        navRailItems = <NavigationRailDestination>[
          const NavigationRailDestination(
            icon: Icon(Icons.home),
            label: Text("Home"),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.dataset),
            label: Text("Health Data"),
            padding: EdgeInsets.only(top: 20),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.fastfood_rounded),
            label: Text("Meals"),
            padding: EdgeInsets.only(top: 10),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.chat),
            label: Text("Chats"),
            padding: EdgeInsets.only(top: 10),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.account_circle),
            label: Text("Profile"),
            padding: EdgeInsets.only(top: 40),
          ),
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQuerySize = MediaQuery.sizeOf(context);
    bool isDesktopOrTabletSize = mediaQuerySize.shortestSide > 600;
    // bool isDesktopOrTabletBigSize = mediaQuerySize.shortestSide > 800;
    return Scaffold(
      body: Row(
        children: [
          if (isDesktopOrTabletSize && navRailItems.isNotEmpty)
            NavigationRail(
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              labelType: NavigationRailLabelType.none,
              destinations: navRailItems,
              selectedIndex: selectedIndex,
              extended: false,
              elevation: 3,
              onDestinationSelected: (value) => setState(() {
                selectedIndex = value;
              }),
            ),
          Expanded(child: screens.elementAt(selectedIndex)),
        ],
      ),
      bottomNavigationBar: isDesktopOrTabletSize
          ? null
          : BottomNavigationBar(
              unselectedItemColor: Theme.of(context).colorScheme.secondary,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: selectedIndex,
              onTap: (value) => setState(() {
                selectedIndex = value;
              }),
              items: bottomNavItems,
            ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
    // ignore: dead_code
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Sync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Dashboard'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
        ),
      ),
    );
  }
}
