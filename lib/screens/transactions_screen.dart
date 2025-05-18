import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/models/auth_provider.dart';
import 'package:tech_challenge_flutter/models/transaction.dart';
import 'package:tech_challenge_flutter/models/transaction_provider.dart';
import 'package:tech_challenge_flutter/screens/login_screen.dart';
import 'package:tech_challenge_flutter/utils/app_routes.dart';
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuth = Provider.of<AuthProvider>(context).isAuth;

    return !isAuth
        ? LoginScreen()
        : Scaffold(
          appBar: AppBar(
            title: Text('Transações'),
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
              Text('GUILHERME, ajustar com o que você já fez'),
              FutureBuilder<List<TransactionModel>>(
                future:
                    Provider.of<TransactionProvider>(context).getTransactions(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar transações.'));
                  }

                  final transactions = snapshot.data ?? [];

                  if (transactions.isEmpty) {
                    return Center(child: Text('Nenhuma transação encontrada.'));
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (ctx, index) {
                        final transaction = transactions[index];
                        return ListTile(
                          leading:
                              transaction.image.isNotEmpty
                                  ? Image.network(
                                    transaction.image,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                  : Icon(Icons.receipt_long),
                          title: Text(transaction.description),
                          subtitle: Text(
                            'R\$ ${transaction.value.toStringAsFixed(2)} - ${transaction.category}',
                          ),
                          trailing: Text(
                            transaction.date.toDate().toString().split(' ')[0],
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
  }
}
