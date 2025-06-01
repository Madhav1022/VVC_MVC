import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import 'homepage.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  static const String routeName = '/';
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();

    return StreamBuilder<UserModel?>(
      stream: authController.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is logged in, navigate to home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.goNamed(HomePage.routeName);
          });
        } else {
          // User is not logged in, navigate to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.goNamed(LoginPage.routeName);
          });
        }

        // Return a loading screen while redirecting
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}