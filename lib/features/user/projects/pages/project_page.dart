import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../main.dart';

class UserProjectPage extends StatefulWidget {
  final String projectName;
  final String description;
  final int projectId;
  final int teamId;
  final int userId;

  const UserProjectPage(
      {super.key,
      required this.projectName,
      required this.projectId,
      required this.teamId,
      required this.description,
      required this.userId});

  @override
  State<UserProjectPage> createState() => _UserProjectPageState();
}

class _UserProjectPageState extends State<UserProjectPage> {
  List<int> isExpanded = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _tasks = [];

  bool isTeam = false;
  List<int> chosenUsers = [];
  int isChosenTeam = -1;
  int chosenTeam = -1;
  bool isTeamSelected = false;
  int teamId = -1;

  void _addNewTask() {
    setState(() {
      _tasks.add({
        "taskController": TextEditingController(),
        "subtasks": <TextEditingController>[],
        "files": [],
      });
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _addSubtask(int taskIndex) {
    setState(() {
      _tasks[taskIndex]["subtasks"].add(TextEditingController());
    });
  }

  void _removeSubtask(int taskIndex, int subtaskIndex) {
    setState(() {
      _tasks[taskIndex]["subtasks"].removeAt(subtaskIndex);
    });
  }

  Future<void> _addFile(int taskIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _tasks[taskIndex]["files"].add(result.files.single.name);
      });
    }
  }

  void _removeFile(int taskIndex, int fileIndex) {
    setState(() {
      _tasks[taskIndex]["files"].removeAt(fileIndex);
    });
  }

  Future<void> createTasks() async {
    for (var task in _tasks) {
      String taskTitle = task["taskController"].text;
      final insertedTask = await SupaBase.from('tasks')
          .insert({
            'tasktitle': taskTitle,
            'projectid': widget.projectId,
            'assignedto': null,
            'duedate': null,
            'status': 'ToDo',
          })
          .select('taskid')
          .single();
      final int newTaskId = insertedTask['taskid'];

      for (var subtaskController in task["subtasks"]) {
        final String subtaskTitle = subtaskController.text;
        await SupaBase.from('subtasks').insert({
          'taskid': newTaskId,
          'subtasktitle': subtaskTitle,
          'assignedto': null,
          'duedate': null,
          'status': 'ToDo',
        });
      }
    }
    setState(() {
      _tasks.clear();
    });
  }

  Future<void> updateTasks(taskid, status) async {
    if (status == 'ToDo') {
      final updateToDone = await SupaBase.from('tasks').update({
        'status': 'Done',
        'assignedtorole': 'User',
        'assignedto': widget.userId,
        'duedate': DateFormat('yyyy-MM-dd').format(DateTime.now())
      }).eq('taskid', taskid);
    } else {
      final updateToNotDone = await SupaBase.from('tasks').update({
        'status': 'ToDo',
        'assignedto': null,
        'assignedtorole': null,
        'duedate': null
      }).eq('taskid', taskid);
    }
  }

  Future<void> updateSubTasks(subtaskid, status) async {
    if (status == 'ToDo') {
      final updateToDone = await SupaBase.from('subtasks').update({
        'assignedtorole': 'User',
        'status': 'Done',
        'assignedto': widget.userId,
        'duedate': DateFormat('yyyy-MM-dd').format(DateTime.now())
      }).eq('subtaskid', subtaskid);
    } else {
      final updateToNotDone = await SupaBase.from('subtasks').update({
        'status': 'ToDo',
        'assignedto': null,
        'assignedtorole': null,
        'duedate': null
      }).eq('subtaskid', subtaskid);
    }
  }

  @override
  Widget build(BuildContext context) {
    var getTeammembers =
        SupaBase.from('teammembers').select().eq('teamid', widget.teamId);
    var getTasks =
        SupaBase.from('tasks').select().eq('projectid', widget.projectId);
    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'توضیحات پروژه:',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal),
                          ),
                          Text(
                            widget.description,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'وظایف:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder(
                      future: getTasks,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final tasks = snapshot.data!;
                        if (tasks.isEmpty) {
                          // Display a message if there are no tasks
                          return Center(
                            child: Text(
                              'هیچ وظیفه‌ای تعریف نشده است.',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          );
                        }
                        return Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return FutureBuilder(
                                  future: SupaBase.from('subtasks')
                                      .select()
                                      .eq('taskid', task['taskid']),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    final subtasks = snapshot.data!;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: Colors.teal[50],
                                              border: Border.all(
                                                  color: Colors.teal, width: 2),
                                            ),
                                            child: CheckboxListTile(
                                              title: Text(
                                                task["tasktitle"],
                                                style: const TextStyle(
                                                    color: Colors.teal),
                                              ),
                                              value: task['status'] == 'Done',
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  updateTasks(task['taskid'],
                                                      task['status']);
                                                });
                                              },
                                            ),
                                          ),
                                          if (subtasks.isNotEmpty)
                                            ExpansionTile(
                                              title: const Text(
                                                'زیروظایف',
                                                style: TextStyle(
                                                    color: Colors.teal,
                                                    fontSize: 14),
                                              ),
                                              children: subtasks
                                                  .map<Widget>((subtask) {
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 8.0, left: 20),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    color: Colors.teal[50],
                                                    border: Border.all(
                                                        color: Colors.teal,
                                                        width: 2),
                                                  ),
                                                  child: CheckboxListTile(
                                                    title: Text(
                                                      subtask["subtasktitle"],
                                                      style: const TextStyle(
                                                          color: Colors.teal),
                                                    ),
                                                    value: subtask['status'] ==
                                                        'Done',
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        updateSubTasks(
                                                            subtask[
                                                                'subtaskid'],
                                                            subtask['status']);
                                                      });
                                                    },
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  // Team Name Section
                  FutureBuilder(
                    future: SupaBase.from('teams').select().eq('teamid', widget.teamId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final teams = snapshot.data!;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal, width: 1),
                        ),
                        child: Text(
                          'اعضای تیم ${teams[0]['teamname']}:',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      );
                    },
                  ),

                  // Team Members Section
                  FutureBuilder(
                    future: getTeammembers,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final members = snapshot.data!;
                      if (members.isEmpty) {
                        return const Center(
                          child: Text(
                            'هیچ عضوی در این تیم وجود ندارد.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.teal, width: 1),
                            ),
                            child: FutureBuilder(
                              future: SupaBase.from('users').select().eq('userid', member['userid']),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                final users = snapshot.data!;
                                if (users.isEmpty) {
                                  return const Text(
                                    'اطلاعات کاربر موجود نیست.',
                                    style: TextStyle(color: Colors.grey),
                                  );
                                }
                                final user = users[0];
                                return ListTile(
                                  leading: Icon(Icons.person, color: Color(0xFF0A3747)),
                                  title: Text(
                                    user['fullname'],
                                    style:
                                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    user['email'] ?? 'No Email',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(120.0),
      child: AppBar(
        backgroundColor: Colors.teal[700],
        flexibleSpace: Container(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.projectName,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '',
                    style: TextStyle(fontSize: 16, color: Color(0xFF0A3747)),
                  ),
                ],
              ),
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
