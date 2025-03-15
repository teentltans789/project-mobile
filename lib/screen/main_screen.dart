import 'package:flutter/material.dart';
import 'package:project/screen/setting_screen.dart';
import 'package:project/screen/timer_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Addgoal.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;
  bool isWatermarkVisible = false; // การแสดงลายน้ำ (เริ่มต้นไม่แสดง)

  // สร้าง list สำหรับเก็บ goal
  List<Map<String, String>> goals = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _checkFirstTime(); // ตรวจสอบการล็อกอินครั้งแรก
  }

  // ฟังก์ชันตรวจสอบการล็อกอินครั้งแรก
  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime');
    
    // ถ้าไม่เคยล็อกอินหรือเป็นครั้งแรก ให้แสดงลายน้ำ
    if (isFirstTime == null || isFirstTime) {
      setState(() {
        isWatermarkVisible = true; // แสดงลายน้ำ
      });
    }
  }

  // ฟังก์ชันที่ถูกเรียกเมื่อผู้ใช้เพิ่มเป้าหมาย
  void _saveGoal(String title, String description, String time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false); // ตั้งค่าเป็นไม่ใช่ครั้งแรกแล้ว
    setState(() {
      isWatermarkVisible = false; // ซ่อนลายน้ำเมื่อเพิ่มเป้าหมาย
      goals.add({
        'title': title,
        'description': description,
        'time': time,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Goal "$title" saved successfully at $time')),
    );

    // ลิงค์ไปยังหน้าจับเวลา
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerScreen(
          goalTitle: title,  // ส่งชื่อเป้าหมาย
          goalTime: time,    // ส่งเวลาที่กรอก
        ),
      ),
    );
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Tracking🏆'),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
      ),
      
      body: goals.isEmpty
           ? const Center(child: Text('No goals added yet!'))
           : ListView.builder(
               itemCount: goals.length,
               itemBuilder: (context, index) {
                 return Card(
                   margin: const EdgeInsets.all(8),
                   child: ListTile(
                     title: Text(goals[index]['title']!),
                     subtitle: Text(
                       '${goals[index]['description']} \nTime: ${goals[index]['time']} hr',
                     ),
                     isThreeLine: true,
                   ),
                 );
               },
             ),
      
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExpanded) ...[
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                // Show the Addgoal dialog and pass the _saveGoal callback
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Addgoal(onSaveGoal: _saveGoal); // ส่งฟังก์ชัน _saveGoal ไป
                  },
                );
              },
              backgroundColor: Colors.amber[700],
              child: const Icon(Icons.playlist_add),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () => _showMessage("View Progress"),
              backgroundColor: Colors.amber[700],
              child: const Icon(Icons.bar_chart),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "btn3",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingScreen()),
                );
              },
              backgroundColor: Colors.amber[700],
              child: const Icon(Icons.settings),
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton(
            heroTag: "toggle",
            onPressed: _toggleExpand,
            backgroundColor: Colors.amber[700],
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animationController,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
