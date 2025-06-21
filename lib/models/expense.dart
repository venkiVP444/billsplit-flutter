import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String paidBy;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final List<String> participants;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.category,
    required this.date,
    required this.participants,
  });
}
