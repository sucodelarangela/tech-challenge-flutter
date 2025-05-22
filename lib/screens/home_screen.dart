import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
          Consumer<TransactionProvider>(
            builder: (ctx, provider, _) {
              provider.isLoading
                  ? context.loaderOverlay.show()
                  : context.loaderOverlay.hide();

              if (provider.hasError) {
                return Center(
                  child: Text('Erro ao carregar dashboard: ${provider.error}'),
                );
              }

              final userBalance = provider.userBalance;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAULA, ajustar os gráficos. Dados disponíveis:',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Text('Email: ${userBalance?.email}'),
                    Text(
                      'Saldo: R\$ ${userBalance?.balance.toStringAsFixed(2)}',
                    ),
                    Text(
                      'Total saídas: -R\$ ${userBalance?.totalExpenses.toStringAsFixed(2)}',
                    ),
                    Text(
                      'Total entradas: R\$ ${userBalance?.totalIncome.toStringAsFixed(2)}',
                    ),
                    if (userBalance != null &&
                        userBalance.lastUpdated.toString().isNotEmpty)
                      Text(
                        'Última atualização: ${DateFormat('dd/MM HH:mm').format(userBalance.lastUpdated)}',
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
