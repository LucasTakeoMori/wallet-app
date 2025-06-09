import 'package:flutter/material.dart';
import 'package:wallet_app/database/database_helper.dart';
import 'package:wallet_app/models/category_model.dart';
import 'package:wallet_app/models/transaction_model.dart';
import 'package:wallet_app/styles/app_colors.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewTransactionScreenState createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newCategoryController = TextEditingController();

  TransactionType _type = TransactionType.income;
  double? _amount;
  String _category = 'Salário';
  String _description = '';
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _addCategory() async {
    if (_newCategoryController.text.isNotEmpty) {
      final category = Category(name: _newCategoryController.text);
      await _dbHelper.insertCategory(category);
      _newCategoryController.clear();
      _loadCategories();
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final transaction = TransactionModel(
        type: _type,
        amount: _amount!,
        category: _category,
        description: _description,
        date: DateTime.now(),
      );
      await _dbHelper.insertTransaction(transaction);

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Transação', style: TextStyle(fontSize: 16)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<TransactionType>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('Entrada'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('Saída'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Tipo'),
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Valor inválido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.name,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Categoria'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Observação'),
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              TextFormField(
                controller: _newCategoryController,
                decoration: InputDecoration(
                  labelText: 'Nova Categoria',
                  hintText: 'Digite para adicionar uma nova categoria',
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _addCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main,
                ),
                child: Text(
                  'Adicionar Categoria',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main,
                ),
                child: Text('Salvar', style: TextStyle(color: AppColors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
