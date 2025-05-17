import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/models/auth.dart';
import 'package:tech_challenge_flutter/models/auth_exception.dart';
import 'package:tech_challenge_flutter/utils/app_routes.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  Widget _createIcon(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> logout() async {
      Auth auth = Provider.of(context, listen: false);
      try {
        await auth.logout();
        Navigator.of(context).pushReplacementNamed(AppRoutes.LOGIN);
      } on AuthException catch (e) {
        print(e);
      }
    }

    return Drawer(
      child: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Theme.of(context).colorScheme.primary,
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/images/logo.png'),
          ),

          SizedBox(height: 20),

          _createIcon(
            Icons.dashboard,
            'Home',
            () => Navigator.of(context).pushReplacementNamed(AppRoutes.HOME),
          ),
          _createIcon(
            Icons.list_alt,
            'Transações',
            () => Navigator.of(
              context,
            ).pushReplacementNamed(AppRoutes.TRANSACTIONS),
          ),
          _createIcon(
            Icons.login,
            'Login',
            () => Navigator.of(context).pushReplacementNamed(AppRoutes.LOGIN),
          ),

          SizedBox(height: 20),

          Divider(
            color: Theme.of(context).colorScheme.secondary,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),

          _createIcon(Icons.logout, 'Sair', logout),
        ],
      ),
    );
  }
}
