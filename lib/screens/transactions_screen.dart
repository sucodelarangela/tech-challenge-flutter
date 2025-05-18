import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/models/auth.dart';
import 'package:tech_challenge_flutter/screens/login_screen.dart';
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuth = Provider.of<Auth>(context).isAuth;

    return !isAuth
        ? LoginScreen()
        : Scaffold(
          appBar: AppBar(title: Text('Transações')),

          drawer: MainDrawer(),

          body: Center(
            child: Text('Aqui teremos a LISTA DE TRANSAÇÕES e FILTROS'),
          ),
        );
  }
}
