import 'package:flutter/material.dart';

import '../../../shared/money/money.dart';
import '../application/create_transaction_use_case.dart';
import '../application/get_recent_transactions_use_case.dart';
import '../data/in_memory_transaction_repository.dart';
import '../data/seed_categories.dart';
import '../domain/category.dart';
import '../domain/transaction.dart';
import '../domain/transaction_type.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _amountController = TextEditingController();
  final _repository = InMemoryTransactionRepository();

  late final _create = CreateTransactionUseCase(repository: _repository);
  late final _getRecent = GetRecentTransactionsUseCase(repository: _repository);

  TransactionType _type = TransactionType.expense;
  Category? _selectedCategory;
  List<Transaction> _recent = [];
  String? _errorText;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<Category> get _visibleCategories {
    return seedCategories.where((category) => category.type == _type).toList();
  }

  Future<void> _save() async {
    final category = _selectedCategory;
    if (category == null) {
      setState(() => _errorText = '请选择分类');
      return;
    }

    try {
      await _create(
        type: _type,
        money: Money.parseCny(_amountController.text),
        category: category,
      );
      final recent = await _getRecent(limit: 10);
      setState(() {
        _amountController.clear();
        _recent = recent;
        _errorText = null;
      });
    } on FormatException catch (error) {
      setState(() => _errorText = error.message);
    } on ArgumentError catch (error) {
      setState(() => _errorText = error.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('记账')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('amount_input'),
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '金额',
              prefixText: '¥ ',
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(value: TransactionType.expense, label: Text('支出')),
              ButtonSegment(value: TransactionType.income, label: Text('收入')),
            ],
            selected: {_type},
            onSelectionChanged: (selection) {
              setState(() {
                _type = selection.single;
                _selectedCategory = null;
              });
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in _visibleCategories)
                ChoiceChip(
                  label: Text(category.name),
                  selected: _selectedCategory?.id == category.id,
                  onSelected: (_) {
                    setState(() => _selectedCategory = category);
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('保存')),
          const SizedBox(height: 24),
          Text('最近账单', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_recent.isEmpty)
            const Text('暂无账单')
          else
            for (final transaction in _recent)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_categoryName(transaction.categoryId)),
                trailing: Text(
                  Money.fromMinorUnits(transaction.amountMinor).displayText,
                ),
              ),
        ],
      ),
    );
  }

  String _categoryName(String categoryId) {
    return seedCategories
        .firstWhere((category) => category.id == categoryId)
        .name;
  }
}
