import 'package:flutter/material.dart';
import 'second_page.dart';
import 'app_lang.dart';

// ✅ ADD these imports
import 'auth/auth_service.dart';
import 'dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLangController.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLangController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // ✅ ONLY CHANGE: use auth check at startup
          home: const _AuthHome(),
        );
      },
    );
  }
}

// ✅ NEW (NO UI change): decides where to go on app start
class _AuthHome extends StatelessWidget {
  const _AuthHome();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final loggedIn = snapshot.data ?? false;
        return loggedIn ? DashboardPage() : const BugBustersGame();
      },
    );
  }
}

class BugBustersGame extends StatelessWidget {
  const BugBustersGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Column(
          children: [
            // App Title
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(width: 30, height: 30),
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

            // Logo
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

            // Swipe Up Text + Arrow Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondPage()),
                );
              },
              child: Column(
                children: [
                  Text(
                    T.t("Swipe up", "ඉහළට ස්වයිප් කරන්න"),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 115, 117, 115),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF1A5319),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Bar
            Container(
              height: 50,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A5319),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}