import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/core/providers/transaction_provider.dart';
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

    userBalance == null
        ? context.loaderOverlay.show()
        : context.loaderOverlay.hide();

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

      body: Column(
        children: [
          Text('PAULA, ajustar com o que você já fez'),
          Text('SALDO: ${provider.userBalance?.balance.toString() ?? 0}'),
        ],
      ),
    );
  }
}
