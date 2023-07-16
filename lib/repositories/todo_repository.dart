import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:lista_tarefas/home/widgets/models/todo.dart';

const toDoListKey = "todo_list";

class ToDoRepository {
  late SharedPreferences sharedPreferences;

  Future<List<ToDo>> getToDoList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(toDoListKey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => ToDo.fromJson(e)).toList();
  }

  void saveToDoList(List<ToDo> toDos) {
    final String jsonString = jsonEncode(toDos);
    sharedPreferences.setString(toDoListKey, jsonString);
  }
}
