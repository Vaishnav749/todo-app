import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app/screens/add_todo.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/services/todo_services.dart';
import 'package:todo_app/utils/snackbar.dart';
import 'package:todo_app/widgets/todo_card.dart';

class HomeTodo extends StatefulWidget {
  const HomeTodo({super.key});

  @override
  State<HomeTodo> createState() => _HomeTodoState();
}

class _HomeTodoState extends State<HomeTodo> {
  bool isloading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchtodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Center(
          child: Text("Todo App"),
        ),
      ),
      body: Visibility(
        visible: isloading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchtodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(child: Text("No items found")),
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                return TodoCard(
                  index: index,
                  item: item,
                  navigateTodoeditpage: navigateTodoeditpage,
                  deleteByid: deleteByid,
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateTodoaddpage, label: Text("ADD LEAD")),
    );
  }

  Future<void> navigateTodoaddpage() async {
    final Route = MaterialPageRoute(builder: (context) => Add_todo());
    await Navigator.push(context, Route);
    setState(() {
      isloading = false;
    });
    fetchtodo();
  }

  Future<void> navigateTodoeditpage(Map item) async {
    final Route = MaterialPageRoute(builder: (context) => Add_todo(todo: item));
    await Navigator.push(context, Route);
    setState(() {
      isloading = false;
    });
    fetchtodo();
  }

  Future<void> deleteByid(String id) async {
    final isSuccess = await todoservices.deleteByid(id);
    if (isSuccess) {
      print("deleted successfully");
      final filterd = items.where((element) => element["_id"] != id).toList();
      setState(() {
        items = filterd;
      });
    } else {
      print("failed to delete");
    }
  }

  Future<void> fetchtodo() async {
    setState(() {
      isloading = true;
    });

    final response = await todoservices.fetchtodos();
    if (response != Null) {
      setState(() {
        items = response!;
        isloading = false;
      });
    } else {
      showerrorMessage(context, message: "Somthing went wrong");
    }
    setState(() {
      isloading = false;
    });
  }
}
