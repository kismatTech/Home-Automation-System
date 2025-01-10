import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;
  int _remainingTime = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadTimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final startTime = prefs.getInt('start_time') ?? 0;
    final duration = prefs.getInt('duration') ?? 0;

    if (startTime > 0 && duration > 0) {
      final elapsed = DateTime.now().millisecondsSinceEpoch ~/ 1000 - startTime;
      final remaining = duration - elapsed;

      if (remaining > 0) {
        setState(() {
          _remainingTime = remaining;
        });
        _startCountdown();
      } else {
        _clearTimerState();
      }
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await prefs.setInt('start_time', currentTime);
    await prefs.setInt('duration', _remainingTime);
  }

  Future<void> _clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('start_time');
    await prefs.remove('duration');
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    setState(() {
      _remainingTime = _selectedHours * 3600 + _selectedMinutes * 60 + _selectedSeconds;
    });

    if (_remainingTime > 0) {
      _saveTimerState();
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _saveTimerState();
        } else {
          timer.cancel();
          _clearTimerState();
        }
      });
    });
  }

  void _stopTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _clearTimerState();
  }

  void _resetTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _clearTimerState();
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
        title: const Text('Timer'),
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
