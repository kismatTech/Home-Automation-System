import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homeautomation/util/smart_device_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref("smart_devices");
  // padding constants
  final double horizontalPadding = 40;
  final double verticalPadding = 25;
  final user = FirebaseAuth.instance.currentUser;
  // list of smart devices
  List mySmartDevices = [
    // [ smartDeviceName, iconPath , powerStatus, databaseKey ]
    ["Smart Light", "lib/icons/light-bulb.png", true, "L1"],
    ["Smart AC", "lib/icons/air-conditioner.png", false, "L2"],
    ["Smart TV", "lib/icons/smart-tv.png", false, "L3"],
    ["Smart Fan", "lib/icons/fan.png", false, "L4"],
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncWithFirebase();
  }

  // Sync with Firebase
  void _syncWithFirebase() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        for (int i = 0; i < mySmartDevices.length; i++) {
          String key = mySmartDevices[i][3]; // Get the databaseKey
          if (data.containsKey(key)) {
            mySmartDevices[i][2] = data[key] == 1; // Update powerStatus
          }
        }
      });
    }
  }

  // power button switched
  void powerSwitchChanged(bool value, int index) {
    setState(() {
      mySmartDevices[index][2] = value;
    });

    String key = mySmartDevices[index][3]; // Get the databaseKey
    int firebaseValue = value ? 1 : 0; // Convert boolean to 1 or 0 for Firebase

    _dbRef.child(key).set(firebaseValue).then((_) {
      print("Updated ${mySmartDevices[index][0]} in Firebase.");
    }).catchError((error) {
      print("Failed to update Firebase: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // app bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // menu icon
                  Image.asset(
                    'lib/icons/menu.png',
                    height: 45,
                    color: Colors.grey[800],
                  ),
                  // account icon
                  IconButton(
                    onPressed: signUserOut, // Calls signUserOut when pressed
                    icon: Icon(Icons.logout), // Logout icon
                    iconSize: 40, // Icon size (optional)
                    color: Colors.grey[800], // Icon color (optional)
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // welcome home
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

            // smart devices grid
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

            // grid
            Expanded(
              child: GridView.builder(
                itemCount: 4,
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
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(seconds: 1),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
            label: ' Set Timer',
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

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}
