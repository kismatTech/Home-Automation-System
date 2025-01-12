import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final _database = FirebaseDatabase.instance.ref('smart_devices');
  String? _selectedDevice;
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;
  int _remainingTime = 0;
  bool _isOn = true; // Toggle state for On/Off
  Timer? _timer;

  final Map<String, String> deviceMap = {
    'L1': 'Smart Light',
    'L2': 'Smart AC',
    'L3': 'Smart Tv',
    'L4': 'Smart Fan',
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDevice = prefs.getString('selectedDevice');
      _selectedHours = prefs.getInt('selectedHours') ?? 0;
      _selectedMinutes = prefs.getInt('selectedMinutes') ?? 0;
      _selectedSeconds = prefs.getInt('selectedSeconds') ?? 0;
      _remainingTime = prefs.getInt('remainingTime') ?? 0;
      _isOn = prefs.getBool('isOn') ?? true;
    });

    if (_remainingTime > 0) {
      _startCountdown();
    }
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDevice', _selectedDevice ?? '');
    await prefs.setInt('selectedHours', _selectedHours);
    await prefs.setInt('selectedMinutes', _selectedMinutes);
    await prefs.setInt('selectedSeconds', _selectedSeconds);
    await prefs.setInt('remainingTime', _remainingTime);
    await prefs.setBool('isOn', _isOn);
  }

  void _startTimer() {
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a device!')),
      );
      return;
    }

    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    setState(() {
      _remainingTime = _selectedHours * 3600 + _selectedMinutes * 60 + _selectedSeconds;
    });

    if (_remainingTime > 0) {
      _savePreferences();
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          _updateFirebase();
        }
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('remainingTime', _remainingTime);
    });
  }

  void _updateFirebase() async {
    if (_selectedDevice != null) {
      final databaseKey = deviceMap.entries.firstWhere(
        (entry) => entry.value == _selectedDevice,
      ).key;

      await _database.child(databaseKey).set(_isOn ? 1 : 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Updated $databaseKey ($_selectedDevice) to ${_isOn ? "1 (On)" : "0 (Off)"}',
          ),
        ),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('remainingTime', 0);
    }
  }

  void _resetTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    setState(() {
      _selectedHours = 0;
      _selectedMinutes = 0;
      _selectedSeconds = 0;
      _remainingTime = 0;
    });

    _savePreferences();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Timer App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Device',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedDevice,
              hint: const Text('Choose a device'),
              items: deviceMap.values.map((deviceName) {
                return DropdownMenuItem(
                  value: deviceName,
                  child: Text(deviceName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDevice = value;
                });
                _savePreferences();
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Action:',
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  value: _isOn,
                  onChanged: (value) {
                    setState(() {
                      _isOn = value;
                    });
                    _savePreferences();
                  },
                ),
                Text(
                  _isOn ? 'On' : 'Off',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Set Time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: _selectedHours,
                  items: List.generate(24, (index) => index).map((hour) {
                    return DropdownMenuItem(
                      value: hour,
                      child: Text('$hour hr'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedHours = value ?? 0;
                    });
                    _savePreferences();
                  },
                ),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: _selectedMinutes,
                  items: List.generate(60, (index) => index).map((minute) {
                    return DropdownMenuItem(
                      value: minute,
                      child: Text('$minute min'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMinutes = value ?? 0;
                    });
                    _savePreferences();
                  },
                ),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: _selectedSeconds,
                  items: List.generate(60, (index) => index).map((second) {
                    return DropdownMenuItem(
                      value: second,
                      child: Text('$second sec'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSeconds = value ?? 0;
                    });
                    _savePreferences();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Remaining Time: ${_formatTime(_remainingTime)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _startTimer,
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
