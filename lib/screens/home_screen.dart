import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),

      drawer: MainDrawer(),

      body: Center(child: Text('Aqui teremos a DASHBOARD e o GRÁFICO')),
    );
  }
}
