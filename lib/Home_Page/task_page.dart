import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do/Home_Page/task_filter_sort.dart';
import 'package:to_do/Home_Page/task_list.dart';
import '../Signin_Signup/login_page.dart';
import 'addTask.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Map<String, dynamic>> tasks = [];
  String _filter = 'All';
  String _sortBy = 'Creation Date';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .listen((taskSnapshot) {
        setState(() {
          tasks = taskSnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'title': doc['title'],
              'description': doc['description'],
              'dueDate': doc['dueDate']?.toDate(),
              'priority': doc['priority'],
              'completed': doc['completed'],
            };
          }).toList();
        });
      });
    }
  }

  List<Map<String, dynamic>> get _filteredTasks {
    List<Map<String, dynamic>> filtered = [];

    if (_filter == 'All') {
      filtered = tasks;
    } else if (_filter == 'Completed') {
      filtered = tasks.where((task) => task['completed'] == true).toList();
    } else {
      filtered = tasks.where((task) => task['completed'] == false).toList();
    }

    return _sortTasks(filtered);
  }

  List<Map<String, dynamic>> _sortTasks(List<Map<String, dynamic>> list) {
    switch (_sortBy) {
      case 'Due Date':
        list.sort((a, b) {
          if (a['dueDate'] == null) return 1;
          if (b['dueDate'] == null) return -1;
          return (a['dueDate'] as DateTime).compareTo(b['dueDate'] as DateTime);
        });
        break;
      case 'Priority':
        const priorityMap = {'Low': 0, 'Medium': 1, 'High': 2};
        list.sort((a, b) =>
            priorityMap[a['priority']]!.compareTo(priorityMap[b['priority']]!));
        break;
      default:
        break;
    }
    return list;
  }

  void _openAddTaskDialog({Map<String, dynamic>? taskToEdit}) async {
    await showDialog(
      context: context,
      builder: (context) => AddTaskDialog(existingTask: taskToEdit),
    );
  }

  void _showUndoSnackbar(Map<String, dynamic> task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task marked as completed'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            FirebaseFirestore.instance
                .collection('tasks')
                .doc(task['id'])
                .update({'completed': false});
          },
        ),
      ),
    );
  }

  void _showFilterSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterSortBottomSheet(
        selectedFilter: _filter,
        selectedSort: _sortBy,
        onApply: (filter, sort) {
          setState(() {
            _filter = filter;
            _sortBy = sort;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _filteredTasks.isEmpty
          ? Center(
              child: Text('No tasks found',
                  style: TextStyle(fontWeight: FontWeight.bold)))
          : ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) => TaskTile(
                task: _filteredTasks[index],
                onEdit: () =>
                    _openAddTaskDialog(taskToEdit: _filteredTasks[index]),
                onComplete: () {
                  FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(_filteredTasks[index]['id'])
                      .update({'completed': true});
                  _showUndoSnackbar(_filteredTasks[index]);
                },
                onDelete: () async {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(_filteredTasks[index]['id'])
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task deleted')),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTaskDialog(),
        backgroundColor: Colors.blue.shade100,
        child: Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue.shade100,
      centerTitle: true,
      title: Text("To-Do App", style: TextStyle(fontWeight: FontWeight.bold)),
      leading: IconButton(
        icon: Icon(Icons.settings_power_rounded),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Get.offAll(() => LoginPage());
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_alt_outlined),
          onPressed: _showFilterSortOptions,
        ),
      ],
    );
  }
}
