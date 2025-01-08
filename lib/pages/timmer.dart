import 'package:flutter/material.dart';
import 'dart:async';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer App',
      home: TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;
  int _remainingTime = 0; // Total time in seconds
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    setState(() {
      _remainingTime = _selectedHours * 3600 + _selectedMinutes * 60 + _selectedSeconds;
    });

    if (_remainingTime > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            timer.cancel();
          }
        });
      });
    }
  }

  void _stopTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
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
        title: const Text('Timer App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Set Time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dropdown for Hours
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
                  },
                ),
                const SizedBox(width: 10),
                // Dropdown for Minutes
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
                  },
                ),
                const SizedBox(width: 10),
                // Dropdown for Seconds
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
                  onPressed: _stopTimer,
                  child: const Text('Stop'),
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
