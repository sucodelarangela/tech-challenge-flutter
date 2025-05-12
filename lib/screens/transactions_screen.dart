import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transações')),

      drawer: MainDrawer(),

      body: Center(child: Text('Aqui teremos a LISTA DE TRANSAÇÕES e FILTROS')),
    );
  }
}
