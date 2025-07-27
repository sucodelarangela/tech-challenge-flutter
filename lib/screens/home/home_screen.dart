import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/controllers/transaction_controller.dart';
import 'package:tech_challenge_flutter/utils/app_routes.dart';
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';
import 'package:tech_challenge_flutter/screens/home/widgets/home_body.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TransactionController provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<TransactionController>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.loadBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: HomeBody(),
      bottomNavigationBar: Builder(
        builder: (context) {
          final provider = Provider.of<TransactionController>(context);
          final userBalance = provider.userBalance;

          if (userBalance == null ||
              userBalance.lastUpdated.toString().isEmpty) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.update, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Última atualização: ${DateFormat('dd/MM HH:mm').format(userBalance.lastUpdated)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
