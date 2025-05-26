import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/core/providers/auth_provider.dart';
import 'package:tech_challenge_flutter/core/providers/transaction_provider.dart';
import 'package:tech_challenge_flutter/utils/app_routes.dart';
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TransactionProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<TransactionProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.loadBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
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

      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer2<AuthProvider, TransactionProvider>(
              builder: (ctx, authProvider, trProvider, _) {
                trProvider.isLoading
                    ? context.loaderOverlay.show()
                    : context.loaderOverlay.hide();

                if (trProvider.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 48.0,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Erro ao carregar os dados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            trProvider.error ?? 'Tente novamente mais tarde.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final userBalance = trProvider.userBalance;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard Financeiro',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.only(
                          top: 24,
                          bottom: 24,
                          left: 8,
                          right: 8,
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (authProvider.user?.name != null &&
                                  authProvider.user!.name!.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.blueGrey),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authProvider.user?.name ?? '',
                                        style: TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.email, color: Colors.blueGrey),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      userBalance?.email ?? '',
                                      style: TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Saldo: R\$ ${userBalance?.balance.toStringAsFixed(2)}',
                                    style: TextStyle(
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
                      ),
                      if ((userBalance?.totalIncome ?? 0) == 0 &&
                          (userBalance?.totalExpenses ?? 0) == 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 48.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insights_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma movimentação encontrada',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Adicione uma transação para visualizar seus dados financeiros.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 400,
                          child: PageView(
                            children: [
                              Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 42.0,
                                    left: 16.0,
                                    right: 16.0,
                                    bottom: 16.0,
                                  ),
                                  child: SizedBox.expand(
                                    child: Center(
                                      child: BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                            horizontalInterval: 100,
                                          ),
                                          barGroups: [
                                            BarChartGroupData(
                                              x: 0,
                                              showingTooltipIndicators: [0],
                                              barRods: [
                                                BarChartRodData(
                                                  toY:
                                                      userBalance
                                                          ?.totalIncome ??
                                                      0,
                                                  color: Colors.green,
                                                  width: 20,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ],
                                            ),
                                            BarChartGroupData(
                                              x: 1,
                                              showingTooltipIndicators: [0],
                                              barRods: [
                                                BarChartRodData(
                                                  toY:
                                                      userBalance
                                                          ?.totalExpenses ??
                                                      0,
                                                  color: Colors.red,
                                                  width: 20,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ],
                                            ),
                                          ],
                                          barTouchData: BarTouchData(
                                            enabled: true,
                                            handleBuiltInTouches: true,
                                            touchCallback: (event, response) {},
                                            touchTooltipData:
                                                BarTouchTooltipData(
                                                  tooltipBgColor: Color(
                                                    0xFFF0F0F0,
                                                  ),
                                                  tooltipPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 2,
                                                      ),
                                                  tooltipMargin: 4,
                                                  getTooltipItem: (
                                                    group,
                                                    groupIndex,
                                                    rod,
                                                    rodIndex,
                                                  ) {
                                                    final value = rod.toY
                                                        .toStringAsFixed(2);
                                                    return BarTooltipItem(
                                                      'R\$ $value',
                                                      TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 10,
                                                      ),
                                                    );
                                                  },
                                                ),
                                          ),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: 500,
                                                getTitlesWidget: (value, meta) {
                                                  final intValue =
                                                      value.toInt();
                                                  if (intValue % 500 != 0)
                                                    return const SizedBox.shrink();

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 4,
                                                        ),
                                                    child: Text(
                                                      intValue.toString(),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                  );
                                                },
                                                reservedSize: 30,
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, _) {
                                                  switch (value.toInt()) {
                                                    case 0:
                                                      return Text('Entrada');
                                                    case 1:
                                                      return Text('Saída');
                                                    default:
                                                      return Text('');
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: userBalance?.totalIncome ?? 0,
                                          title:
                                              'Entradas\nR\$ ${userBalance?.totalIncome.toStringAsFixed(2)}',
                                          color: Colors.green,
                                          radius: 60,
                                          titleStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          value:
                                              userBalance?.totalExpenses ?? 0,
                                          title:
                                              'Saídas\nR\$ ${userBalance?.totalExpenses.toStringAsFixed(2)}',
                                          color: Colors.red,
                                          radius: 60,
                                          titleStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final provider = Provider.of<TransactionProvider>(context);
          final userBalance = provider.userBalance;

          if (userBalance == null ||
              userBalance.lastUpdated.toString().isEmpty) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.update, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Última atualização: ${DateFormat('dd/MM HH:mm').format(userBalance.lastUpdated)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
