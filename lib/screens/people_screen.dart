import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/people_provider.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final peopleProvider = Provider.of<PeopleProvider>(context);
    final nameController = TextEditingController();

    void addPerson() {
      final name = nameController.text.trim();
      if (name.isNotEmpty) {
        peopleProvider.addPerson(name);
        nameController.clear();
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('People')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addPerson,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: peopleProvider.people.length,
              itemBuilder: (ctx, i) {
                final person = peopleProvider.people[i];
                return ListTile(
                  title: Text(person.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => peopleProvider.removePerson(person.id),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
