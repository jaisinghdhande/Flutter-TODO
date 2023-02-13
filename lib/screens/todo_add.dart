import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/services/todo_service.dart';

import '../utils/snackbar_helper.dart';

class TodoAdd extends StatefulWidget {
  final Map? todo;
  const TodoAdd({super.key, this.todo});

  @override
  State<TodoAdd> createState() => _TodoAddState();
}

class _TodoAddState extends State<TodoAdd> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      setState(() {
        isEdit = true;
        final title = todo['title'];
        final description = todo['description'];
        titleController.text = title;
        descriptionController.text = description;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'EDIT TODO' : 'ADD TODO'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Title',
            ),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'Description',
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 10,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData,
            child: Text(isEdit ? 'UPDATE' : 'SUBMIT'),
          )
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print('error updating');
      return;
    }
    final id = todo['_id'];

    //submit- UPDATED data to server
    final isSuccess = await TodoService.updateTodo(id, body);
    //check the response
    if (isSuccess) {
      showSuccessMessage(context, message: 'Updation successful');
    } else {
      showErrorMessage(context, message: 'Updation failed');
    }
  }

  Future<void> submitData() async {
    //get data from form

    //submit data to server
    final isSuccess = await TodoService.addTodo(body);
    //check the response
    if (isSuccess) {
      showSuccessMessage(context, message: 'Creation successful');
      titleController.text = '';
      descriptionController.text = '';
    } else {
      showErrorMessage(context, message: 'Creation failed');
    }
  }

  Map get body {
    final title = titleController.text;
    final description = descriptionController.text;
    return {"title": title, "description": description, "is_completed": false};
  }
}
