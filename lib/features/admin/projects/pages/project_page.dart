import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../main.dart';
import '../../home_page/pages/home_page.dart';
import 'dart:typed_data';

class ProjectPage extends StatefulWidget {
  final String projectName;
  final String description;
  final bool isDone;
  final int projectId;
  final int teamId;
  final int userId;

  const ProjectPage(
      {super.key,
      required this.projectName,
      required this.projectId,
      required this.teamId,
      required this.description,
      required this.isDone,
      required this.userId});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
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
        'assignedto': widget.userId,
        'assignedtorole': 'Admin',
        'duedate': DateFormat('yyyy-MM-dd').format(DateTime.now())
      }).eq('taskid', taskid);
    } else {
      final updateToNotDone = await SupaBase.from('tasks').update({
        'status': 'ToDo',
        'assignedto': null,
        'duedate': null,
        'assignedtorole': null,
      }).eq('taskid', taskid);
    }
  }

  Future<void> updateSubTasks(subtaskid, status) async {
    if (status == 'ToDo') {
      final updateToDone = await SupaBase.from('subtasks').update({
        'status': 'Done',
        'assignedto': widget.userId,
        'assignedtorole': 'Admin',
        'duedate': DateFormat('yyyy-MM-dd').format(DateTime.now())
      }).eq('subtaskid', subtaskid);
    } else {
      final updateToNotDone = await SupaBase.from('subtasks').update({
        'status': 'ToDo',
        'assignedto': null,
        'duedate': null,
        'assignedtorole': null,
      }).eq('subtaskid', subtaskid);
    }
  }

  Future<void> finishProject() async {
    final updateToDone = await SupaBase.from('projects')
        .update({'isdone': true}).eq('projectid', widget.projectId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("پروژه اتمام یافت!")),
    );

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext ctx) => AdminHomePage(
                  userId: widget.userId,
                )));
  }

  @override
  Widget build(BuildContext context) {
    var getTeammembers =
        SupaBase.from('teammembers').select().eq('teamid', widget.teamId);
    var getTasks =
        SupaBase.from('tasks').select().eq('projectid', widget.projectId);
    return Scaffold(
      backgroundColor: Color(0x343F5F68),
      appBar: _buildCustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFF0A3747), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 6,
                      offset: Offset(0, 3), // سایه
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'توضیحات پروژه:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A3747),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'وظایف:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              FutureBuilder(
                future: getTasks,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tasks = snapshot.data!;
                  if (tasks.isEmpty) {
                    // پیام در صورت نبودن تسک‌ها
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'هنوز وظیفه‌ای ایجاد نشده است',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A3747), // آبی تیره
                          ),
                        ),
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
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: task['status'] == 'Done'
                                            ? Color(0xFFE1F5FE) // آبی روشن برای انجام‌شده
                                            : Color(0xFFFFFFFF), // سفید برای ناتمام
                                        border: Border.all(
                                          color: Color(0xFF0A3747), // آبی تیره
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            blurRadius: 6,
                                            spreadRadius: 2,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          task["tasktitle"],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF0A3747), // رنگ متن
                                          ),
                                        ),
                                        trailing: (subtasks.isNotEmpty)
                                            ? IconButton(
                                          icon: Icon(
                                            isExpanded.contains(task['taskid'])
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: Color(0xFF0A3747), // آبی تیره
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (isExpanded.contains(task['taskid'])) {
                                                isExpanded.remove(task['taskid']);
                                              } else {
                                                isExpanded.add(task['taskid']);
                                              }
                                            });
                                          },
                                        )
                                            : null,
                                        leading: Checkbox(
                                          value: task['status'] == 'Done',
                                          onChanged: (bool? value) {
                                            setState(() {
                                              updateTasks(task['taskid'], task['status']);
                                            });
                                          },
                                          activeColor: Color(0xFF0A3747), // آبی تیره
                                        ),
                                      ),
                                    ),
                                    if (isExpanded.contains(task['taskid']))
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                        child: Column(
                                          children: subtasks.map<Widget>((subtask) {
                                            return Container(
                                              margin: const EdgeInsets.symmetric(vertical: 4),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: subtask['status'] == 'Done'
                                                    ? Color(0xFFE1F5FE)
                                                    : Color(0xFFFFFFFF),
                                                border: Border.all(
                                                  color: Color(0xFF0A3747),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  subtask["subtasktitle"],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF0A3747),
                                                  ),
                                                ),
                                                leading: Checkbox(
                                                  value: subtask['status'] == 'Done',
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      updateSubTasks(subtask['subtaskid'],
                                                          subtask['status']);
                                                    });
                                                  },
                                                  activeColor: Color(0xFF0A3747),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
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
              ..._tasks.asMap().entries.map((entry) {
                int taskIndex = entry.key;
                Map<String, dynamic> task = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF0A3747), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tasks[taskIndex]["taskController"],
                                decoration: InputDecoration(
                                  hintText: 'وظیفه جدید را وارد کنید',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFF0A3747)),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _removeTask(taskIndex),
                            ),
                          ],
                        ),
                        ...task["subtasks"].asMap().entries.map((subEntry) {
                          int subtaskIndex = subEntry.key;
                          TextEditingController subtaskController = subEntry.value;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: subtaskController,
                                    decoration: InputDecoration(
                                      hintText: 'زیر وظیفه را وارد کنید',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Color(0xFF0A3747)),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _removeSubtask(taskIndex, subtaskIndex),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Color(0xFF0A3747)),
                              onPressed: () => _addSubtask(taskIndex),
                            ),
                            const Text(
                              'افزودن زیر وظیفه',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              }).toList(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HoverButton(
                    onTap: _addNewTask,
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'اضافه کردن وظیفه جدید',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(width: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_tasks.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => {
                      setState(() {
                        createTasks();
                      }),
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0A3747),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'ذخیره وظیفه و زیروظیفه های جدید',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Column(
                children: [
                  FutureBuilder(
                      future: getTeammembers,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final members = snapshot.data!;
                        return Column(
                          children: [
                            FutureBuilder(
                              future: SupaBase.from('teams')
                                  .select()
                                  .eq('teamid', widget.teamId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                final teams = snapshot.data!;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    final team = teams[0];
                                    return Row(
                                      children: [
                                        Spacer(),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(vertical: 8),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Color(0xFF0A3747), width: 2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.3),
                                                  spreadRadius: 2,
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                'اعضای تیم ${team['teamname']}:',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0A3747),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: members.length,
                              itemBuilder: (context, index) {
                                final member = members[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Color(0xFF0A3747), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: FutureBuilder(
                                    future: SupaBase.from('users')
                                        .select()
                                        .eq('userid', member['userid']),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      final users = snapshot.data!;
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: users.length,
                                        itemBuilder: (context, index) {
                                          final user = users[index];
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
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      })
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              if(!widget.isDone)Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: finishProject,
                        icon: const Icon(Icons.task_alt, color: Colors.white),
                        label: const Text(
                          'اتمام پروژه',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered)) {
                                return const Color(0xFF3A685B);
                              }
                              return const Color(0xFF0A3747);
                            },
                          ),
                          shadowColor: MaterialStateProperty.all(
                            const Color(0xFF0A3747).withOpacity(0.5), // سایه سبز
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // گوشه‌های گرد
                            ),
                          ),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          uploadFile();
                        },
                        icon: const Icon(Icons.upload_file, color: Colors.white),
                        label: const Text(
                          'دانلود فایل پروژه',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered)) {
                                return const Color(0xFF003F63);
                              }
                              return const Color(0xFF005B8F);
                            },
                          ),
                          shadowColor: MaterialStateProperty.all(
                            const Color(0xFF005B8F).withOpacity(0.5),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fileName = '';
  Uint8List? _fileBytes;

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.first;
      setState(() {
        _fileName = file.name;
        _fileBytes = file.bytes;
      });
    }

    final filePath = 'user_${widget.userId}/project_${widget.projectId}/$_fileName';
    final addToFiles = await SupaBase.from('files').insert({
      'filename': _fileName,
      'filepath': filePath,
      'uploadedby': widget.userId,
      'projectid': widget.projectId,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("فایل آپلود شد!")),
    );
    return;
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(120.0),
      child: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A3747), Color(0xFF0C4B5E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
