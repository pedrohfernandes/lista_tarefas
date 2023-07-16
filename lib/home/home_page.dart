import 'package:flutter/material.dart';
import 'package:lista_tarefas/home/widgets/models/todo.dart';
import 'package:lista_tarefas/home/widgets/todo_list_item.dart';
import 'package:lista_tarefas/repositories/todo_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController toDoController = TextEditingController();
  final ToDoRepository toDoRepository = ToDoRepository();

  List<ToDo> toDos = [];

  ToDo? deletedToDo;
  int? deletedToDoPos;

  String? errorText;

  @override
  void initState() {
    super.initState();

    toDoRepository.getToDoList().then((value) {
      setState(() {
        toDos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: toDoController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Adicione uma tarefa",
                          hintText: "Ex.: Estudar Flutter",
                          errorText: errorText,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        String text = toDoController.text;
                        if (text.isEmpty) {
                          setState(() {
                            errorText = "O título não pode ser vazio!";
                          });
                          return;
                        }
                        setState(() {
                          ToDo newToDo = ToDo(
                            title: text,
                            dateTime: DateTime.now(),
                          );
                          toDos.add(newToDo);
                          errorText = null;
                        });
                        toDoController.clear();
                        toDoRepository.saveToDoList(toDos);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(14),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (ToDo toDo in toDos)
                        ToDoListItem(
                          toDo: toDo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        toDos.isEmpty
                            ? "Você não possui tarefas pendentes"
                            : toDos.length == 1
                                ? "Você possui ${toDos.length} tarefa pendente"
                                : "Você possui ${toDos.length} tarefas pendentes",
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: showDeleteToDosConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(14),
                      ),
                      child: Text(
                        "Limpar tudo",
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(ToDo toDo) {
    deletedToDo = toDo;
    deletedToDoPos = toDos.indexOf(toDo);

    setState(() {
      toDos.remove(toDo);
    });
    toDoRepository.saveToDoList(toDos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Tarefa ${toDo.title} foi removida com sucesso!",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: "Desfazer",
          onPressed: () {
            setState(() {
              toDos.insert(deletedToDoPos!, deletedToDo!);
            });
            toDoRepository.saveToDoList(toDos);
          },
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void showDeleteToDosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Limpar tudo?"),
        content: Text("Você tem certeza que deseja limpar todas as tarefas?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllToDos();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text("Limpar tudo"),
          ),
        ],
      ),
    );
  }

  void deleteAllToDos() {
    setState(() {
      toDos.clear();
    });
    toDoRepository.saveToDoList(toDos);
  }
}
