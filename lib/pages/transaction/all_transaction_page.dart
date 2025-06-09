import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wallet_app/database/database_helper.dart';
import 'package:wallet_app/models/transaction_model.dart';
import 'package:wallet_app/styles/app_colors.dart';

class AllTransactionScreen extends StatefulWidget {
  const AllTransactionScreen({super.key});

  @override
  State<AllTransactionScreen> createState() => _AllTransactionScreenState();
}

class _AllTransactionScreenState extends State<AllTransactionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _latestTransactions = [];

  double _totalIncome = 0;
  double _totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await _dbHelper.getTransactions();
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      }
      if (transaction.type == TransactionType.expense) {
        totalExpense += transaction.amount;
      }
    }

    final lastTransactions = transactions
      ..sort((a, b) => b.date.compareTo(a.date));
    final limitedTransactions = lastTransactions.take(10).toList();

    setState(() {
      _transactions = transactions;
      _latestTransactions = limitedTransactions;
      _totalIncome = totalIncome;
      _totalExpense = totalExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Histórico das transações',
          style: TextStyle(fontSize: 16, color: AppColors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.0, top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Total de entradas: ',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_totalIncome)}',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Total de saídas: ',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_totalExpense)}',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Card(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 4.0,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Últimas 10 Movimentações',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    width: 380,
                    child: _latestTransactions.isEmpty
                        ? Center(
                            child: Text(
                              'Sem movimentações',
                              style: TextStyle(color: AppColors.black),
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceEvenly,
                              maxY: _latestTransactions.isEmpty
                                  ? 100
                                  : _latestTransactions
                                            .map((t) => t.amount)
                                            .reduce((a, b) => a > b ? a : b) *
                                        1.2,
                              barGroups: _latestTransactions
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final index = entry.key;
                                    final transaction = entry.value;
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: transaction.amount,
                                          color:
                                              transaction.type ==
                                                  TransactionType.income
                                              ? AppColors.green
                                              : AppColors.red,
                                          width: 6,
                                        ),
                                      ],
                                    );
                                  })
                                  .toList(),
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= _latestTransactions.length) {
                                        return SizedBox();
                                      }
                                      final date = DateFormat(
                                        'dd/MM',
                                      ).format(_latestTransactions[index].date);
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          date,
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: false),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: AppColors.lightGray,
                    child: ListTile(
                      title: Text(
                        '${transaction.category} - R\$ ${transaction.amount}',
                        style: TextStyle(color: AppColors.black, fontSize: 14),
                      ),
                      subtitle: Text(
                        '${transaction.type == TransactionType.income ? 'Entrada' : 'Saída'} - ${DateFormat('dd/MM/yyyy').format(transaction.date)}\n${transaction.description}',
                        style: TextStyle(color: AppColors.black),
                      ),
                      trailing: Icon(
                        transaction.type == TransactionType.income
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: transaction.type == TransactionType.income
                            ? AppColors.green
                            : AppColors.red,
                        size: 22,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
