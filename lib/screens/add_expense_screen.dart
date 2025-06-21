import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/people_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? prefillTitle;
  final double? prefillAmount;
  final String? prefillCategory;
  final String? prefillPaidBy;
  final DateTime? prefillDate;

  const AddExpenseScreen({
    super.key,
    this.prefillTitle,
    this.prefillAmount,
    this.prefillCategory,
    this.prefillPaidBy,
    this.prefillDate,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _title = TextEditingController();
  final _amount = TextEditingController();

  final List<String> _categories = ['Food', 'Movie', 'Travel', 'Other'];
  String _paidBy = 'You';
  String _category = 'Food';
  late DateTime _date;
  List<String> selectedParticipants = [];

  @override
  void initState() {
    super.initState();
    _title.text = widget.prefillTitle ?? '';
    _amount.text = widget.prefillAmount?.toString() ?? '';
    _category = widget.prefillCategory ?? _category;
    _paidBy = widget.prefillPaidBy ?? _paidBy;
    _date = widget.prefillDate ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final title = _title.text.trim();
    final amt = double.tryParse(_amount.text.trim());

    if (title.isEmpty || amt == null || amt <= 0 || selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields and select participants')),
      );
      return;
    }

    Provider.of<ExpenseProvider>(context, listen: false).addExpense(
      title,
      amt,
      _paidBy,
      _category,
      _date,
      selectedParticipants,
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peopleProvider = Provider.of<PeopleProvider>(context);
    final personNames = peopleProvider.people.map((p) => p.name).toSet().toList();
    final allPeople = ['You', ...personNames.where((n) => n != 'You')];

    if (!allPeople.contains(_paidBy)) {
      _paidBy = allPeople.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amount,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _paidBy,
              decoration: const InputDecoration(labelText: 'Paid By'),
              items: allPeople
                  .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                  .toList(),
              onChanged: (v) => setState(() => _paidBy = v!),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Date: ${_date.toIso8601String().split('T')[0]}'),
                ),
                TextButton(onPressed: _pickDate, child: const Text('Pick Date')),
              ],
            ),
            const SizedBox(height: 16),

            // ─────────── Participants ───────────
            const Text('Participants', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: allPeople.map((person) {
                final selected = selectedParticipants.contains(person);
                return FilterChip(
                  label: Text(person),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selectedParticipants.add(person);
                      } else {
                        selectedParticipants.remove(person);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
