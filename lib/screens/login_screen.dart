import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/widgets/login_form.dart';
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Home')),
      drawer: MainDrawer(),

      // Container(
      // ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).canvasColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [LoginForm()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
