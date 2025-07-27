import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/controllers/auth_controller.dart';

class HomeHeaderInfo extends StatelessWidget {
  final AuthController authProvider;
  final dynamic userBalance;

  const HomeHeaderInfo({
    super.key,
    required this.authProvider,
    required this.userBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 24, bottom: 24, left: 8, right: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authProvider.user?.name != null &&
                authProvider.user!.name!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authProvider.user?.name ?? '',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.email, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userBalance?.email ?? '',
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Saldo: R\$ ${userBalance?.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
