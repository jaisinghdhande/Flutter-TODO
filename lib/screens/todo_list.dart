import 'dart:convert';
import 'package:todo_app/services/todo_service.dart';
import 'package:todo_app/widgets/todo_card.dart';

import '../utils/snackbar_helper.dart';
import './todo_add.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodoList();
  }

  @override
  Widget build(BuildContext context) {
    print('wid built');
    return Scaffold(
        appBar: AppBar(
          title: Text('TODO LIST'),
        ),
        body: Visibility(
          visible: isLoading,
          child: Center(child: CircularProgressIndicator()),
          replacement: RefreshIndicator(
            onRefresh: fetchTodoList,
            child: Visibility(
              visible: items.isNotEmpty,
              replacement: Center(
                child: Text('NO TODO'),
              ),
              child: ListView.builder(
                  itemCount: items.length,
                  padding: EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final item = items[index] as Map;
                    final id = item['_id'] as String;
                    return TodoCard(
                        index: index,
                        item: item,
                        navigateEdit: navigateToEditTodo,
                        deleteById: deleteById);
                  }),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddTodo,
          label: Text('ADD TODO'),
        ));
  }

  Future<void> navigateToAddTodo() async {
    final route = MaterialPageRoute(builder: (context) => TodoAdd());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodoList();
  }

  Future<void> navigateToEditTodo(Map item) async {
    final route = MaterialPageRoute(builder: (context) => TodoAdd(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodoList();
  }

  Future<void> deleteById(String id) async {
    final isSuccess = await TodoService.deleteById(id);
    if (isSuccess) {
      final filter = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filter;
      });
    } else {
      showErrorMessage(context, message: 'Deletion failed');
    }
  }

  Future<void> fetchTodoList() async {
    final response = await TodoService.fetchTodo();
    if (response != null) {
      setState(() {
        items = response;
      });
    } else {
      showErrorMessage(context, message: 'Something went Wrong!');
    }
    setState(() {
      isLoading = false;
    });
  }
}
