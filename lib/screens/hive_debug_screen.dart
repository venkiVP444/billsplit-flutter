import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/expense.dart';
import 'package:logging/logging.dart';

final log = Logger('HiveDebugScreen');

class HiveDebugScreen extends StatefulWidget {
  const HiveDebugScreen({super.key});

  @override
  State<HiveDebugScreen> createState() => _HiveDebugScreenState();
}

class _HiveDebugScreenState extends State<HiveDebugScreen> {
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _readHiveData();
  }

  Future<void> _readHiveData() async {
    final box = Hive.box<Expense>('expensesBox'); // ✅ correct box name
    final keys = box.keys.toList();
    final newLogs = <String>[];

    log.info('🔍 All stored expenses in Hive:');

    for (var key in keys) {
      final exp = box.get(key);
      final entry = '➡️ [$key]: ${exp?.title} - ₹${exp?.amount} - ${exp?.paidBy}';
      log.info(entry);
      newLogs.add(entry);
    }

    setState(() {
      _logs = newLogs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hive Debug')),
      body: ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (ctx, i) => ListTile(title: Text(_logs[i])),
      ),
    );
  }
}
