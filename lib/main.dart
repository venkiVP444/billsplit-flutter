import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/expense.dart';
import 'providers/expense_provider.dart';
import 'providers/people_provider.dart';
import 'screens/home_screen.dart';
import 'screens/people_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register adapters
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());

  // Open Hive box
  final expensesBox = await Hive.openBox<Expense>('expensesBox');

  runApp(BillSplitApp(expensesBox: expensesBox));
}

class BillSplitApp extends StatelessWidget {
  final Box<Expense> expensesBox;

  const BillSplitApp({super.key, required this.expensesBox});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(expensesBox),
        ),
        ChangeNotifierProvider(
          create: (_) => PeopleProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'BillSplit',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomeScreen(),
        routes: {
          '/people': (ctx) => const PeopleScreen(),
        },
      ),
    );
  }
}
