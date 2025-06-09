import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:wallet_app/database/database_helper.dart';
import 'package:wallet_app/models/transaction_model.dart';
import 'package:wallet_app/styles/app_colors.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  double _totalIncome = 0;
  double _totalExpense = 0;

  bool _isLoading = true;

  Map<String, double> _categoryIncomes = {};
  Map<String, double> _categoryExpenses = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final transactions = await _dbHelper.getTransactions();
      final categoryIncomes = <String, double>{};
      final categoryExpenses = <String, double>{};

      for (var transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          categoryIncomes.update(
            transaction.category,
            (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount,
          );

          _totalIncome += transaction.amount;
        }

        if (transaction.type == TransactionType.expense) {
          categoryExpenses.update(
            transaction.category,
            (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount,
          );

          _totalExpense += transaction.amount;
        }
      }

      setState(() {
        _categoryIncomes = categoryIncomes;
        _categoryExpenses = categoryExpenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.main,
        title: Text(
          'Gráficos',
          style: TextStyle(fontSize: 16, color: AppColors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Entradas por Categoria: ',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'R\$${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_totalIncome)}',
                                style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 30),
                          Expanded(
                            child: _categoryIncomes.isEmpty
                                ? Center(child: null)
                                : PieChart(
                                    PieChartData(
                                      sections: _categoryIncomes.entries
                                          .toList()
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final index = entry.key;
                                            final category = entry.value.key;
                                            final amount = entry.value.value;
                                            return PieChartSectionData(
                                              showTitle: true,
                                              titlePositionPercentageOffset:
                                                  1.65,
                                              color: _getColor(index),
                                              value: amount,
                                              title:
                                                  '$category\nR\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(amount)}',
                                              radius: 50,
                                              titleStyle: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.black,
                                              ),
                                            );
                                          })
                                          .toList(),
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 30,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Despesas por Categoria: ',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'R\$${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_totalExpense)}',
                                style: TextStyle(
                                  color: AppColors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: _categoryExpenses.isEmpty
                                ? Center(child: null)
                                : PieChart(
                                    PieChartData(
                                      sections: _categoryExpenses.entries
                                          .toList()
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final index = entry.key;
                                            final category = entry.value.key;
                                            final amount = entry.value.value;
                                            return PieChartSectionData(
                                              showTitle: true,
                                              titlePositionPercentageOffset:
                                                  1.75,
                                              color: _getColor(index),
                                              value: amount,
                                              title:
                                                  '$category\nR\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(amount)}',
                                              radius: 50,
                                              titleStyle: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.black,
                                              ),
                                            );
                                          })
                                          .toList(),
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 30,
                                    ),
                                  ),
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

  Color _getColor(int index) {
    final colors = [
      AppColors.secondary,
      const Color(0xFFE91E63),
      const Color(0xFF4CAF50),
      const Color(0xFFFFC107),
      const Color(0xFF9C27B0),
      const Color(0xFF2196F3),
    ];

    return colors[index % colors.length];
  }
}
