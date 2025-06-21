import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';
import 'bill_scanner_screen.dart';
import 'hive_debug_screen.dart';   // <- your in-app Hive logger screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedMonth = DateTime.now();

  Future<void> _pickMonth() async {
    final picked = await showMonthYearPicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedMonth = picked);
  }

  void _shareBalance(String summary) {
    final formatted = '${_selectedMonth.month}/${_selectedMonth.year}';
    Share.share('BillSplit summary for $formatted:\n$summary');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BillSplit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Manage People',
            onPressed: () => Navigator.pushNamed(context, '/people'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Pick month',
            onPressed: _pickMonth,
          ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: 'Hive debug',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HiveDebugScreen()),
              ),
            ),
        ],
      ),

      // ────────── BODY ──────────
      body: Consumer<ExpenseProvider>(
        builder: (_, provider, __) {
          final list   = provider.expensesForMonth(_selectedMonth);
          final summary = provider.balanceSummary(_selectedMonth);
          final byCat  = provider.spendingByCategory(_selectedMonth);

          return Column(
            children: [
              // --- summary & share ---
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        summary,
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      tooltip: 'Share',
                      onPressed: () => _shareBalance(summary),
                    ),
                  ],
                ),
              ),

              // --- pie chart ---
              if (byCat.isNotEmpty)
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sections: byCat.entries.map(
                        (e) => PieChartSectionData(
                          value: e.value,
                          title: e.key,
                          radius: 60,
                        ),
                      ).toList(),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // --- expense list ---
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('No expenses for this month'))
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final e = list[i];
                          return Dismissible(
                            key: ValueKey(e.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              provider.removeExpense(e.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${e.title} deleted'),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: provider.undoRemove,
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              leading: CircleAvatar(child: Text(e.category[0])),
                              title: Text(e.title),
                              subtitle: Text(
                                '${e.category} • Paid by: ${e.paidBy}\n'
                                'Shared: ${e.participants.isEmpty ? '—' : e.participants.join(', ')}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Text(
                                '₹${e.amount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),

      // ────────── FABs ──────────
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'scanFAB',
            tooltip: 'Scan bill',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BillScannerScreen()),
            ),
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addFAB',
            tooltip: 'Add expense',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
