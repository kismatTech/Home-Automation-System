import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homeautomation/util/smart_device_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'profile.dart';
import 'timmer.dart';
import 'power_usages.dart';
import 'dart:async'; // Required for Timer

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref("smart_devices");
  final user = FirebaseAuth.instance.currentUser;
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  Timer? _timer;

  final double horizontalPadding = 40;
  final double verticalPadding = 25;

  List mySmartDevices = [
    ["Smart Light", "lib/icons/light-bulb.png", true, "L1"],
    ["Smart AC", "lib/icons/air-conditioner.png", false, "L2"],
    ["Smart TV", "lib/icons/smart-tv.png", false, "L3"],
    ["Smart Fan", "lib/icons/fan.png", false, "L4"],
  ];

  @override
  void initState() {
    super.initState();
    _startPeriodicUpdate();
  }

  // Start a periodic timer to fetch data every 5 seconds (adjustable)
  void _startPeriodicUpdate() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _fetchDataFromFirebase();
    });
  }

  // Fetch data from Firebase and compare with the local data
  Future<void> _fetchDataFromFirebase() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        for (int i = 0; i < mySmartDevices.length; i++) {
          String key = mySmartDevices[i][3]; // Get the database key
          if (data.containsKey(key)) {
            mySmartDevices[i][2] = data[key] == 1; // Update powerStatus
          }
        }
      });
    }
  }

  // Handling power switch changes
  void powerSwitchChanged(bool value, int index) {
    setState(() {
      mySmartDevices[index][2] = value;
    });

    String key = mySmartDevices[index][3]; // Firebase key for the device
    int firebaseValue = value ? 1 : 0;

    _dbRef.child(key).set(firebaseValue).then((_) {
      print("Updated ${mySmartDevices[index][0]} in Firebase.");
    }).catchError((error) {
      setState(() {
        mySmartDevices[index][2] =
            !value; // Revert the toggle state if update fails
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to update ${mySmartDevices[index][0]}: $error"),
      ));
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          buildHomePage(),
          TimerPage(),
          PowerUsagesPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(seconds: 1),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer_rounded),
            label: 'Set Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.power_settings_new_outlined),
            selectedIcon: Icon(Icons.power_settings_new_sharp),
            label: 'Power Usage',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildHomePage() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'lib/icons/menu.png',
                  height: 45,
                  color: Colors.grey[800],
                ),
                IconButton(
                  onPressed: signUserOut,
                  icon: const Icon(Icons.logout),
                  iconSize: 40,
                  color: Colors.grey[800],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Home,",
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade800),
                ),
                Text(
                  '${user!.email}',
                  style: GoogleFonts.bebasNeue(fontSize: 30),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Divider(
              thickness: 1,
              color: Color.fromARGB(255, 204, 204, 204),
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Text(
              "Smart Devices",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              itemCount: mySmartDevices.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1.3,
              ),
              itemBuilder: (context, index) {
                return SmartDeviceBox(
                  smartDeviceName: mySmartDevices[index][0],
                  iconPath: mySmartDevices[index][1],
                  powerOn: mySmartDevices[index][2],
                  onChanged: (value) => powerSwitchChanged(value, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}
