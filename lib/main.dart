import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/screens/home_screen.dart';
import 'package:tech_challenge_flutter/screens/transactions_screen.dart';
import 'package:tech_challenge_flutter/utils/app_routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bytebank',

      // THEME:
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.cyan,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.cyan,
        ).copyWith(
          primary: Color(0xff004d61),
          secondary: Color.fromRGBO(132, 204, 22, 1),
        ),
        canvasColor: Color(0xffe4ede3),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Color(0xffe4ede3)),
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            color: Color(0xffe4ede3),
          ),
        ),
      ),

      // ROTAS DE NAVEGAÇÃO
      routes: {
        AppRoutes.HOME: (ctx) => HomeScreen(),
        AppRoutes.TRANSACTIONS: (ctx) => TransactionsScreen(),
      },
    );
  }
}
