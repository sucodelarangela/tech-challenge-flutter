import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/models/auth.dart';
import 'package:tech_challenge_flutter/screens/home_screen.dart';
import 'package:tech_challenge_flutter/screens/login_screen.dart';
import 'package:tech_challenge_flutter/screens/transactions_screen.dart';
import 'package:tech_challenge_flutter/utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => Auth())],
      child: MaterialApp(
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

        initialRoute: AppRoutes.LOGIN,

        // ROTAS DE NAVEGAÇÃO
        routes: {
          AppRoutes.LOGIN: (ctx) => LoginScreen(),
          AppRoutes.HOME: (ctx) => const HomeScreen(),
          AppRoutes.TRANSACTIONS: (ctx) => const TransactionsScreen(),
        },

        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
