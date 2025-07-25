import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/controllers/auth_controller.dart';
import 'package:tech_challenge_flutter/screens/home_screen.dart';
import 'package:tech_challenge_flutter/screens/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (ctx, auth, _) {
        return auth.isAuth ? HomeScreen() : LoginScreen();
      },
    );
  }
}
