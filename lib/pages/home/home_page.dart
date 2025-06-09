import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:wallet_app/database/database_helper.dart';
import 'package:wallet_app/models/transaction_model.dart';
import 'package:wallet_app/pages/chart/chart_page.dart';
import 'package:wallet_app/pages/transaction/all_transaction_page.dart';
import 'package:wallet_app/pages/transaction/new_transaction_page.dart';
import 'package:wallet_app/styles/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  double _balance = 0.0;
  bool _isVisible = true;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final balance = await _dbHelper.getBalance();
      final transactions = await _dbHelper.getTransactions();
      setState(() {
        _balance = balance;
        _transactions = transactions;
      });
    } catch (err) {
      print('Erro ao carregar dados: $err');
    }
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carteira',
          style: TextStyle(fontSize: 16, color: AppColors.white),
        ),
      ),
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 4.0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seu Saldo',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: _toggleVisibility,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _isVisible
                              ? 'R\$${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_balance)}'
                              : '*****',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isVisible ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewTransactionScreen(),
                        ),
                      ).then((_) {
                        _loadData();
                      });
                    },
                    backgroundColor: AppColors.lightGray,
                    foregroundColor: AppColors.black,
                    shape: CircleBorder(),
                    elevation: 4,
                    mini: true,
                    heroTag: 'add_transaction',
                    child: Icon(Icons.add, size: 25),
                  ),
                  SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChartPage()),
                      );
                    },
                    backgroundColor: AppColors.lightGray,
                    foregroundColor: AppColors.black,
                    shape: CircleBorder(),
                    elevation: 4,
                    mini: true,
                    heroTag: 'view_chart',
                    child: Icon(Icons.bar_chart, size: 25),
                  ),
                  SizedBox(width: 16),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 10,
                      horizontal: 5,
                    ),
                  ),
                  Text(
                    'Lançamentos ',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllTransactionScreen(),
                        ),
                      );
                    },

                    child: Text('Mostrar tudo'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: _transactions.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma transação registrada',
                      style: TextStyle(color: AppColors.black),
                    ),
                  )
                : ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
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
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 14,
                              ),
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
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
