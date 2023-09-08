import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/add_todo.dart';
import 'package:todo_app/database_notifier.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  late Future<void> todoFuture;
  @override
  void initState() {
    super.initState();
    todoFuture = ref.read(databaseNotifierProvider.notifier).fetchData();
  }

  void _openAddTodoScreen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const NewTodo()));
  }

  var scheme =
      ColorScheme.fromSeed(seedColor: const Color.fromRGBO(255, 5, 99, 125));

  @override
  Widget build(BuildContext context) {
    final todo = ref.watch(databaseNotifierProvider);
    return Scaffold(
      backgroundColor: scheme.onSecondaryContainer,
      appBar: AppBar(
        title: const Text('To-Do'),
        actions: [
          IconButton(onPressed: _openAddTodoScreen, icon: const Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder(
          future: todoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            } else {
              return ListView.builder(
                itemCount: todo.length,
                itemBuilder: (context, index) => Dismissible(
                  key: ValueKey(todo[index].id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      final toDelete = todo[index].id;
                      ref
                          .read(databaseNotifierProvider.notifier)
                          .deleteData(toDelete!);
                    });
                  },
                  background: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    alignment: Alignment.centerLeft,
                    color: Colors.redAccent.withOpacity(0.5),
                  ),
                  child: Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16.0), // Adjust padding here
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(todo[index].title!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time_filled_rounded),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(todo[index].time!),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(todo[index].desc!),
                          const Divider(),
                          Text(todo[index].date!),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
