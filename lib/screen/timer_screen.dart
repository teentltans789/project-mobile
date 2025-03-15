import 'package:flutter/material.dart';
import 'dart:async'; // ใช้สำหรับการจับเวลา
import 'package:flutter/animation.dart';
import 'package:intl/intl.dart'; // สำหรับแปลงเวลา

class TimerScreen extends StatefulWidget {
  final String goalTitle;
  final String goalTime; // Time ที่กรอกใน Addgoal

  const TimerScreen(
      {super.key, required this.goalTitle, required this.goalTime});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _timer;
  int _remainingTime = 0; // เวลานับถอยหลัง (เริ่มต้น)
  bool _isTimeUp = false;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _convertTimeToSeconds(widget.goalTime)),
    );
    _animationController.forward();
  }

  // ฟังก์ชันแปลงเวลาจากรูปแบบ hh:mm:ss หรือ hh:mm เป็นวินาที
  int _convertTimeToSeconds(String time) {
    List<String> timeParts = time.split(':');

    // ถ้าหากเวลามีแค่ 2 ส่วน เช่น hh:mm
    if (timeParts.length == 2) {
      try {
        int hours = int.parse(timeParts[0]);
        int minutes = int.parse(timeParts[1]);
        return hours * 3600 + minutes * 60; // คำนวณเวลาเป็นวินาที
      } catch (e) {
        throw FormatException(
            'กรุณากรอกเวลาในรูปแบบที่ถูกต้อง (hh:mm หรือ hh:mm:ss)');
      }
    }
    // ถ้ามี 3 ส่วน เช่น hh:mm:ss
    else if (timeParts.length == 3) {
      try {
        int hours = int.parse(timeParts[0]);
        int minutes = int.parse(timeParts[1]);
        int seconds = int.parse(timeParts[2]);
        return hours * 3600 + minutes * 60 + seconds; // คำนวณเวลาเป็นวินาที
      } catch (e) {
        throw FormatException('กรุณากรอกเวลาในรูปแบบที่ถูกต้อง (hh:mm:ss)');
      }
    }
    // ถ้ารูปแบบเวลาไม่ตรงตามที่คาดหวัง
    else {
      throw FormatException(
          'กรุณากรอกเวลาในรูปแบบที่ถูกต้อง (hh:mm หรือ hh:mm:ss)');
    }
  }

  // ฟังก์ชันเริ่มต้นจับเวลา
  void _initializeTimer() {
    _remainingTime =
        _convertTimeToSeconds(widget.goalTime); // กำหนดเวลาเริ่มต้นจาก goalTime
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == 0) {
        _timer.cancel();
        setState(() {
          _isTimeUp = true; // เมื่อเวลาหมด
        });
        _showSuccessMessage();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  // ฟังก์ชันที่จะแสดงข้อความเมื่อเวลาหมด
  void _showSuccessMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("เก่งมาก! เป้าหมายสำเร็จแล้ว"),
          content: const Text("คุณได้ทำตามเป้าหมายของคุณเสร็จแล้ว!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goalTitle),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _isTimeUp
            ? Stack(
                children: [
                  // เอฟเฟคพลุ
                  Positioned(
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 2),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      height: 100,
                      width: 100,
                    ),
                  ),
                  // ข้อความสำเร็จ
                  Center(
                    child: Text(
                      "เก่งมาก! เป้าหมายสำเร็จแล้ว",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value:
                        _remainingTime / _convertTimeToSeconds(widget.goalTime),
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                  Text(
                    "${_remainingTime}s",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
