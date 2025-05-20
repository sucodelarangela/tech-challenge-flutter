import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/core/providers/auth_provider.dart';
import 'package:tech_challenge_flutter/core/models/auth_exception.dart';
import 'package:tech_challenge_flutter/utils/app_routes.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  Widget _createIcon(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of(context, listen: false);

    Future<void> logout() async {
      try {
        await auth.logout();
        Navigator.of(context).pushReplacementNamed(AppRoutes.SPLASH);
      } on AuthException catch (e) {
        print(e);
      }
    }

    return Drawer(
      child: Column(
        children: [
          Container(
            // height: 140,
            width: double.infinity,
            padding: EdgeInsets.only(top: 40, bottom: 20),
            color: Theme.of(context).colorScheme.primary,
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png'),
                SizedBox(height: 10),
                Text(
                  'Olá, ${auth.user?.name ?? auth.user?.email}!',
                  style: TextStyle(
                    color: Theme.of(context).canvasColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          _createIcon(
            Icons.dashboard,
            'Home',
            () => Navigator.of(context).pushReplacementNamed(AppRoutes.SPLASH),
          ),
          _createIcon(
            Icons.list_alt,
            'Transações',
            () => Navigator.of(
              context,
            ).pushReplacementNamed(AppRoutes.TRANSACTIONS),
          ),

          SizedBox(height: 20),

          Divider(
            color: Theme.of(context).colorScheme.secondary,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),

          // _createIcon(Icons.settings, 'Configurações', null),
          _createIcon(Icons.logout, 'Sair', logout),
        ],
      ),
    );
  }
}
