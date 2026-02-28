import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'dashboard_page.dart';
import 'second_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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

        return (snapshot.data ?? false)
            ? const DashboardPage()
            : const SecondPage();
      },
    );
  }
}