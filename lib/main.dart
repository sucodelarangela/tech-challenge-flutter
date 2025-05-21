import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tech_challenge_flutter/core/providers/auth_provider.dart';
import 'package:tech_challenge_flutter/core/providers/transaction_provider.dart';
import 'package:tech_challenge_flutter/screens/splash_screen.dart';
import 'package:tech_challenge_flutter/screens/transaction_form_screen.dart';
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
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
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

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('pt', 'BR'), // Portuguese (Brazil)
        ],

        // ROTAS DE NAVEGAÇÃO
        routes: {
          AppRoutes.SPLASH: (ctx) => SplashScreen(),
          AppRoutes.TRANSACTIONS: (ctx) => const TransactionsScreen(),
        },

        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
