import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/controllers/auth_controller.dart';
import 'package:tech_challenge_flutter/controllers/transaction_controller.dart';
import 'package:tech_challenge_flutter/screens/home/widgets/home_content.dart';
import 'package:tech_challenge_flutter/screens/home/widgets/home_error.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Consumer2<AuthController, TransactionController>(
            builder: (ctx, authProvider, trProvider, _) {
              trProvider.isLoading
                  ? context.loaderOverlay.show()
                  : context.loaderOverlay.hide();

              if (trProvider.hasError) {
                return HomeError(errorMessage: trProvider.error);
              }

              final userBalance = trProvider.userBalance;

              return HomeContent(
                authProvider: authProvider,
                userBalance: userBalance,
              );
            },
          ),
        ],
      ),
    );
  }
}
