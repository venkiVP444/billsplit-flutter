import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  /// Hive box injected from `main.dart`
  final Box<Expense> _box;

  ExpenseProvider(this._box) {
    // Load persisted data on startup
    _expenses.addAll(_box.values);
  }

  // ── in-memory cache ──
  final List<Expense> _expenses = [];
  Expense? _lastDeleted;

  // ── getters ──
  List<Expense> get expenses => List.unmodifiable(_expenses);

  List<Expense> expensesForMonth(DateTime month) => _expenses
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .toList();

  Map<String, double> spendingByCategory(DateTime month) {
    final map = <String, double>{};
    for (var e in expensesForMonth(month)) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  // ── CRUD ──
  void addExpense(
    String title,
    double amount,
    String paidBy,
    String category,
    DateTime date,
    List<String> participants,
  ) {
    final id = const Uuid().v4();
    final exp = Expense(
      id: id,
      title: title,
      amount: amount,
      paidBy: paidBy,
      category: category,
      date: date,
      participants: participants,
    );

    _box.put(id, exp);   // persist
    _expenses.add(exp);  // cache
    notifyListeners();
  }

  void removeExpense(String id) {
    _lastDeleted = _box.get(id);
    _box.delete(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void undoRemove() {
    if (_lastDeleted != null) {
      _box.put(_lastDeleted!.id, _lastDeleted!);
      _expenses.add(_lastDeleted!);
      _lastDeleted = null;
      notifyListeners();
    }
  }

  // ── Simple balance (You vs Friend) ──
  String balanceSummary(DateTime month) {
    double you = 0, friend = 0;
    for (var e in expensesForMonth(month)) {
      e.paidBy == 'You' ? you += e.amount : friend += e.amount;
    }
    final share = (you + friend) / 2;
    final diff  = friend - share;
    if (diff > 0) {
      return 'You owe Friend ₹${diff.toStringAsFixed(2)}';
    } else if (diff < 0) {
      return 'Friend owes you ₹${(-diff).toStringAsFixed(2)}';
    }
    return 'All settled up!';
  }
}
