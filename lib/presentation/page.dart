import 'package:todo2/bloc/todo_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _key = GlobalKey<FormState>();
    final _controller = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Todo List'),
              Row(
                children: [
                  Column(
                    children: [
                      Text('Selected Date'),
                      BlocBuilder<TodoBloc, TodoState>(
                        builder: (context, state) {
                          if (state is TodoLoaded) {
                            if (state.selectedDate != null) {
                              return Text(
                                '${state.selectedDate!.day}/${state.selectedDate!.month}/${state.selectedDate!.year}',
                              );
                            }
                          }
                          return Text('No date selected');
                        },
                      ),
                      SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          ).then((selectedDate) {
                            if (selectedDate != null) {
                              context.read<TodoBloc>().add(
                                    TodoSelectDate(date: selectedDate),
                                  );
                            }
                          });
                        },
                        child: Text('Select Date'),
                      ),
                    ],
                  ),
                ],
              ),
              Form(
                key: _key,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Todo',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a todo";
                          }
                          return null;
                        },
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (_key.currentState!.validate()) {
                          final selectedDate = context.read<TodoBloc>().state;
                          if (selectedDate is TodoLoaded) {
                            context.read<TodoBloc>().add(
                                  TodoEventAdd(
                                    title: _controller.text,
                                    selectedDate: selectedDate.selectedDate!,
                                  ),
                                );
                            _controller.clear();
                            selectedDate.selectedDate = null;
                          }
                        }
                      },
                      child: Text('Tambah'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),  // Added spacing after form

              Expanded(
                child: BlocBuilder<TodoBloc, TodoState>(
                  builder: (context, state) {
                    if (state is TodoLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is TodoLoaded) {
                      if (state.todos.isEmpty) {
                        return Center(child: Text('Todo list is empty'));
                      }
                      return ListView.builder(
                        itemCount: state.todos.length,
                        itemBuilder: (context, index) {
                          final todo = state.todos[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 8.0),
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      todo.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      '${todo.date.day}/${todo.date.month}/${todo.date.year}',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      todo.isCompleted
                                          ? 'Completed'
                                          : 'Not Completed',
                                      style: TextStyle(
                                        color: todo.isCompleted
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                Checkbox(
                                  value: todo.isCompleted,
                                  onChanged: (value) {
                                    context.read<TodoBloc>().add(
                                          TodoEventComplete(index: index),
                                        );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: Text('No todos available'));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

