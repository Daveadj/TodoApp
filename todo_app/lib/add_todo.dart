import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/database_notifier.dart';

final formatter = DateFormat.yMd();

class NewTodo extends ConsumerStatefulWidget {
  const NewTodo({super.key});

  @override
  ConsumerState<NewTodo> createState() => _NewTodoState();
}

class _NewTodoState extends ConsumerState<NewTodo> {
  final _fromKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final presentDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2022),
        lastDate: DateTime(2121));

    setState(() {
      _selectedDate = presentDate;
    });
  }

  void _pickedTime() async {
    final presentTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
      _selectedTime = presentTime;
    });
  }

  void _saveTodo() {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }
    // Todo todo = Todo(
    //     title: _titleController.text,
    //     desc: _descController.text,
    //     time: _selectedTime!.format(context),
    //     date: formatter.format(_selectedDate!));

    ref.read(databaseNotifierProvider.notifier).addData(
        _titleController.text,
        _descController.text,
        formatter.format(_selectedDate!),
        _selectedTime!.format(context));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add To-Do'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _fromKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Title',
                      ),
                      Container(
                        height: 52,
                        margin: const EdgeInsets.only(top: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadiusDirectional.circular(12),
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter your title',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          autofocus: false,
                          controller: _titleController,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                      ),
                      Container(
                        height: 100,
                        margin: const EdgeInsets.only(top: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadiusDirectional.circular(12),
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter your Note',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 6,
                          autofocus: false,
                          controller: _descController,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                            ),
                            Container(
                              height: 52,
                              margin: const EdgeInsets.only(top: 8.0),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1.0),
                                borderRadius:
                                    BorderRadiusDirectional.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: _selectedDate == null
                                            ? 'Select date'
                                            : formatter.format(_selectedDate!),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 16.0),
                                      ),
                                      readOnly: true,
                                      autofocus: false,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _presentDatePicker,
                                    icon: const Icon(
                                        Icons.calendar_today_outlined),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time',
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 52,
                              margin: const EdgeInsets.only(top: 8.0),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1.0),
                                borderRadius:
                                    BorderRadiusDirectional.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: _selectedTime == null
                                            ? 'Select time'
                                            : _selectedTime!.format(context),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 16.0),
                                      ),
                                      readOnly: true,
                                      autofocus: false,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _pickedTime,
                                    icon: const Icon(Icons.alarm_add_outlined),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                          ),
                          Container(
                            height: 52,
                            margin: const EdgeInsets.only(top: 8.0),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 1.0),
                              borderRadius:
                                  BorderRadiusDirectional.circular(12),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(150, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              onPressed: _saveTodo,
                              child: const Text('Save'),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
