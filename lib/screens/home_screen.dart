import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/models/transaction_provider.dart';
import 'package:tech_challenge_flutter/utils/app_routes.dart';
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TransactionProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.loadBalance();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    final userBalance = provider.userBalance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.TRANSACTION_FORM);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),

      drawer: MainDrawer(),

      body:
          userBalance == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Text('PAULA, ajustar com o que você já fez'),
                  Text('SALDO: ${provider.userBalance!.balance.toString()}'),
                ],
              ),
    );
  }
}
