import 'package:flutter/material.dart';
import 'second_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BugBustersGame(),
    );
  }
}

class BugBustersGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 30, height: 30),
                  SizedBox(width: 8),
                  Text(
                    'BUG BUSTERS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/Logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondPage()),
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF1A5319),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            Container(
              height: 50,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF1A5319),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
