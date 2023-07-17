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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Lista de Tarefas",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: toDoController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: "Adicione uma tarefa",
                              hintText: "Ex.: Estudar Flutter",
                              errorText: errorText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                            padding: const EdgeInsets.all(14),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
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
                  ],
                ),
              ),
              const SizedBox(
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
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: showDeleteToDosConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Text(
                      "Limpar tudo",
                    ),
                  ),
                ],
              ),
            ],
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
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.grey[100],
        action: SnackBarAction(
          label: "Desfazer",
          onPressed: () {
            setState(() {
              toDos.insert(deletedToDoPos!, deletedToDo!);
            });
            toDoRepository.saveToDoList(toDos);
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showDeleteToDosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Limpar tudo?"),
        content:
            const Text("Você tem certeza que deseja limpar todas as tarefas?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllToDos();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Limpar tudo"),
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
