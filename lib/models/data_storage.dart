import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todoapp/encryption_key.dart';
import 'package:todoapp/models/todo.dart';

class DataStorage {
  static final DataStorage instance = DataStorage._internal();

  factory DataStorage() {
    return instance;
  }

  DataStorage._internal() {
    // initialization logic
  }

  // Variables for encryption and decryption
  static final Key key = Key.fromBase64(
    encryptionKey,
  ); // This is your key, you can use whatever you want
  static final Encrypter encrypter = Encrypter(AES(key));
  static final IV iv = IV.fromLength(16);

  // Your todo file
  File todoStorage = File("");

  Future _loadTodoFile() async {
    todoStorage = File(
      "${(await getApplicationDocumentsDirectory()).path}/todos.json",
    );
  }

  Future<void> saveTodos(List<ToDo> todos) async {
    // Create a list for all todos to save them
    List<String> encryptedTodos = List.generate(
      todos.length,
      (index) => jsonEncode(todos[index].toEncryptJson(encrypter, iv)),
    );

    // Write to the file
    todoStorage.writeAsStringSync('{"todos": $encryptedTodos}');
  }

  Future<List<ToDo>> loadTodos() async {
    // Make sure todo file is loaded
    if (todoStorage.path == "") {
      await _loadTodoFile();
    }

    List<ToDo> todos = [];

    // Read the json data
    final data = jsonDecode(todoStorage.readAsStringSync());
    List encryptedTodos = data["todos"];

    // Iterate over each todo and convert it to the todo class
    for (int i = 0; i < encryptedTodos.length; i++) {
      Map<String, dynamic> json = encryptedTodos[i];
      todos.add(ToDo.fromJson(json, encrypter, iv));
    }

    return todos;
  }
}
