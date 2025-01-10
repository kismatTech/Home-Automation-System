import 'package:flutter/material.dart';
import 'timmer.dart';
import 'home_page.dart';
import 'profile.dart';

class PowerUsagesPage extends StatefulWidget {
  @override
  _PowerUsagesPageState createState() => _PowerUsagesPageState();
}

class _PowerUsagesPageState extends State<PowerUsagesPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Power Usages'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Power Usage Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  PowerUsageTile(
                    appliance: 'Air Conditioner',
                    usage: '1200 kWh',
                  ),
                  PowerUsageTile(
                    appliance: 'Refrigerator',
                    usage: '800 kWh',
                  ),
                  PowerUsageTile(
                    appliance: 'Washing Machine',
                    usage: '500 kWh',
                  ),
                  PowerUsageTile(
                    appliance: 'Television',
                    usage: '300 kWh',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}

class PowerUsageTile extends StatelessWidget {
  final String appliance;
  final String usage;

  const PowerUsageTile({
    required this.appliance,
    required this.usage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(appliance),
        subtitle: Text('Power Usage: $usage'),
      ),
    );
  }
}
