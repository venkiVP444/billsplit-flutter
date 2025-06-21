import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/person.dart';

class PeopleProvider with ChangeNotifier {
  final List<Person> _people = [
    Person(id: '1', name: 'You'),
    Person(id: '2', name: 'Friend'),
  ];

  List<Person> get people => _people;

  void addPerson(String name) {
    final person = Person(id: const Uuid().v4(), name: name);
    _people.add(person);
    notifyListeners();
  }

  void removePerson(String id) {
    _people.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
