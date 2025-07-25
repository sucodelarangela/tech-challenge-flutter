import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/data/api/auth_provider.dart';
import 'package:tech_challenge_flutter/screens/login_screen.dart';
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController nameController;
  late TextEditingController passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    passwordController.dispose();
    _isLoading = false;
  }

  Future<void> _updateUserName(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).updateUser(nameController.text);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nome do usuário atualizado!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar o nome do usuário.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(BuildContext context) async {
    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).deleteUser(passwordController.text);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Conta excluída com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao solicitar exclusão da conta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = Provider.of<AuthProvider>(context).isAuth;

    if (!isAuth) {
      return const LoginScreen();
    }

    _isLoading ? context.loaderOverlay.show() : context.loaderOverlay.hide();

    void _showUsernameDialog() => showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Seu nome',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              autofocus: true,
              controller: nameController,
              decoration: InputDecoration(labelText: 'Digite seu nome'),
            ),
            actions: [
              TextButton(
                onPressed: () => _updateUserName(context),
                child: const Text('SALVAR'),
              ),
            ],
          ),
    );

    void _showDeleteDialog() => showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Excluir conta?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Para excluir sua conta, digite novamente sua senha:'),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Confirme sua senha'),
                  obscureText: true,
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () => _deleteUser(context),
                child: const Text('EXCLUIR'),
              ),
            ],
          ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Configurações')),

      drawer: MainDrawer(),

      body: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              'Configurações de Conta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                onPressed: _showUsernameDialog,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'Nome do usuário',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Clique para definir um nome de usuário',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                onPressed: _showDeleteDialog,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'Excluir conta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Clique para excluir sua conta',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
