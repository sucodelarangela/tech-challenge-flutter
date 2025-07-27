import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/controllers/auth_controller.dart';
import 'home_header_info.dart';
import 'home_empty_state.dart';
import 'home_bar_chart_card.dart';
import 'home_pie_chart_card.dart';

class HomeContent extends StatefulWidget {
  final AuthController authProvider;
  final dynamic userBalance;

  const HomeContent({
    super.key,
    required this.authProvider,
    required this.userBalance,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = widget.authProvider;
    final userBalance = widget.userBalance;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Financeiro',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          HomeHeaderInfo(authProvider: authProvider, userBalance: userBalance),
          if ((userBalance?.totalIncome ?? 0) == 0 &&
              (userBalance?.totalExpenses ?? 0) == 0)
            const HomeEmptyState()
          else
            Column(
              children: [
                SizedBox(
                  height: 400,
                  child: PageView(
                    controller: _controller,
                    onPageChanged:
                        (index) => setState(() => _currentPage = index),
                    children: [
                      HomeBarChartCard(
                        totalIncome: userBalance?.totalIncome ?? 0,
                        totalExpenses: userBalance?.totalExpenses ?? 0,
                      ),
                      HomePieChartCard(
                        totalIncome: userBalance?.totalIncome ?? 0,
                        totalExpenses: userBalance?.totalExpenses ?? 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed:
                          _currentPage > 0
                              ? () {
                                _controller.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                              : null,
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    IconButton(
                      onPressed:
                          _currentPage < 1
                              ? () {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                              : null,
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
