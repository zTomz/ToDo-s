import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todoapp/models/data_storage.dart';
import 'package:todoapp/models/todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ToDo> todos = [];

  late TextEditingController newTodoTitleController;
  late TextEditingController newTodoContentController;

  @override
  void initState() {
    super.initState();

    newTodoTitleController = TextEditingController();
    newTodoContentController = TextEditingController();

    _loadTodos();

    // Checking if brightness changed, than setState to update the ui, otherwise the todo list 
    // will not use the material you design
    final window = WidgetsBinding.instance.window;
    // This callback is called every time the brightness changes.
    window.onPlatformBrightnessChanged = () async {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {});
    };
  }

  @override
  void dispose() {
    newTodoTitleController.dispose();
    newTodoContentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To Do App"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              title: const Text("Add new Todo"),
              contentPadding: const EdgeInsets.all(15),
              children: [
                TextField(
                  controller: newTodoTitleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Title",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newTodoContentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Content",
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() {
                      todos.add(
                        ToDo(
                          title: newTodoTitleController.text,
                          content: newTodoContentController.text,
                          completed: false,
                          from: DateTime.now(),
                        ),
                      );
                    });

                    newTodoTitleController.clear();
                    newTodoContentController.clear();

                    Navigator.of(context).pop();

                    await DataStorage.instance.saveTodos(todos);
                  },
                  icon: const Icon(Icons.done_rounded),
                  label: const Text("Add Todo"),
                ),
              ],
            ),
          );
        },
        label: const Text("Add Todo"),
        icon: const Icon(Icons.add_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.separated(
          itemBuilder: (context, index) => Slidable(
            key: ValueKey(todos[index]),
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              dismissible: DismissiblePane(
                onDismissed: () async {
                  setState(() {
                    todos.removeAt(index);
                  });
                  await DataStorage.instance.saveTodos(todos);
                },
              ),
              children: [
                SlidableAction(
                  onPressed: (context) {},
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onErrorContainer,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {},
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onErrorContainer,
                  icon: Icons.date_range_rounded,
                  label:
                      "${_addLeadingZero(todos[index].from.hour)}:${_addLeadingZero(todos[index].from.minute)}, ${todos[index].from.day}",
                ),
              ],
            ),
            child: ListTile(
              title: Text(todos[index].title),
              subtitle: Text(todos[index].content),
              trailing: IconButton(
                onPressed: () async {
                  final todo = todos[index];
                  setState(() {
                    todos[index] = ToDo(
                      title: todo.title,
                      content: todo.content,
                      completed: !todo.completed,
                      from: todo.from,
                    );
                  });

                  await DataStorage.instance.saveTodos(todos);
                },
                icon: Icon(
                  todos[index].completed
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
              ),
              tileColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          separatorBuilder: (context, index) => const SizedBox(
            height: 10,
          ),
          itemCount: todos.length,
        ),
      ),
    );
  }

  void _loadTodos() async {
    // Load todos
    todos = await DataStorage.instance.loadTodos();
    setState(() {});

    // Update the ui after one second, otherwise the todo list will not use the meterial you color scheme
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  String _addLeadingZero(int number) {
    if (number < 10) {
      return '0$number';
    } else {
      return number.toString();
    }
  }
}
