import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../main.dart';
import '../../home_page/pages/home_page.dart';

class ProjectPage extends StatefulWidget {
  final String projectName;
  final String description;
  final int projectId;
  final int teamId;
  final int userId;

  const ProjectPage(
      {super.key,
      required this.projectName,
      required this.projectId,
      required this.teamId,
      required this.description,
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
      appBar: AppBar(
        title: Text(widget.projectName),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'توضیحات پروژه:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.description,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              const Text(
                'وظایف:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              FutureBuilder(
                  future: getTasks,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final tasks = snapshot.data!;
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
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: Colors.white,
                                                  // Background color
                                                  border: Border.all(
                                                    color: Colors.purple,
                                                    // Border color
                                                    width: 2, // Border width
                                                  ),
                                                ),
                                                child: CheckboxListTile(
                                                  title:
                                                      Text(task["tasktitle"]),
                                                  value:
                                                      task['status'] == 'Done'
                                                          ? true
                                                          : false,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      updateTasks(
                                                          task['taskid'],
                                                          task['status']);
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            (subtasks.length > 0)
                                                ? (isExpanded.contains(
                                                        task['taskid'])
                                                    ? IconButton(
                                                        icon: const Icon(
                                                            Icons
                                                                .keyboard_arrow_up_sharp,
                                                            color:
                                                                Colors.purple),
                                                        onPressed: () => {
                                                              setState(() {
                                                                isExpanded
                                                                    .remove(task[
                                                                        'taskid']);
                                                              })
                                                            })
                                                    : IconButton(
                                                        icon: const Icon(
                                                            Icons
                                                                .keyboard_arrow_down_sharp,
                                                            color:
                                                                Colors.purple),
                                                        onPressed: () => {
                                                              setState(() {
                                                                isExpanded.add(
                                                                    task[
                                                                        'taskid']);
                                                              })
                                                            }))
                                                : const SizedBox(
                                                    width: 38,
                                                  )
                                          ],
                                        ),
                                        if (isExpanded.contains(task['taskid']))
                                          Column(
                                            children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: subtasks.length,
                                                itemBuilder: (context, index) {
                                                  final subtask =
                                                      subtasks[index];
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 8.0,
                                                            left: 72.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      color: Colors.white,
                                                      // Background color
                                                      border: Border.all(
                                                        color: Colors.purple,
                                                        // Border color
                                                        width:
                                                            2, // Border width
                                                      ),
                                                    ),
                                                    child: CheckboxListTile(
                                                      title: Text(subtask[
                                                          "subtasktitle"]),
                                                      value:
                                                          subtask['status'] ==
                                                                  'Done'
                                                              ? true
                                                              : false,
                                                      onChanged: (bool? value) {
                                                        setState(() {
                                                          updateSubTasks(
                                                              subtask[
                                                                  'subtaskid'],
                                                              subtask[
                                                                  'status']);
                                                        });
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                          ),
                                      ],
                                    ),
                                  );
                                });
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),
              ..._tasks.asMap().entries.map((entry) {
                int taskIndex = entry.key;
                Map<String, dynamic> task = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tasks[taskIndex]["taskController"],
                              decoration: const InputDecoration(
                                hintText: 'وظیفه جدید را وارد کنید',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTask(taskIndex),
                          ),
                        ],
                      ),
                      ...task["subtasks"].asMap().entries.map((subEntry) {
                        int subtaskIndex = subEntry.key;
                        TextEditingController subtaskController =
                            subEntry.value;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: subtaskController,
                                  decoration: const InputDecoration(
                                    hintText: 'زیر وظیفه را وارد کنید',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _removeSubtask(taskIndex, subtaskIndex),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.purple),
                            onPressed: () => _addSubtask(taskIndex),
                          ),
                          const Text(
                            'افزودن زیر وظیفه',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'فایل‌ها',
                        style: TextStyle(fontSize: 14),
                      ),
                      ...task["files"].asMap().entries.map((fileEntry) {
                        int fileIndex = fileEntry.key;
                        String fileName = fileEntry.value;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(fileName),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _removeFile(taskIndex, fileIndex),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.upload_file,
                                color: Colors.purple),
                            onPressed: () => _addFile(taskIndex),
                          ),
                          const Text('افزودن فایل'),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addNewTask,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'اضافه کردن وظیفه',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_tasks.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => {
                      setState(() {
                        createTasks();
                      }),
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'ذخیره وظیفه و زیروظیفه های جدید',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: 1,
                                      itemBuilder: (context, index) {
                                        final team = teams[0];
                                        return Center(
                                          child: Text(
                                            'اعضای تیم ${team['teamname']}:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        );
                                      });
                                }),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: members.length,
                              itemBuilder: (context, index) {
                                final member = members[index];
                                return Container(
                                  margin: const EdgeInsets.only(
                                      top: 8.0, left: 38.0),
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.purple,
                                      width: 1, // Border width
                                    ),
                                  ),
                                  child: FutureBuilder(
                                      future: SupaBase.from('users')
                                          .select()
                                          .eq('userid', member['userid']),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        final users = snapshot.data!;
                                        return ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: users.length,
                                            itemBuilder: (context, index) {
                                              final userr = users[index];
                                              return Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .account_circle_outlined,
                                                    size: 28,
                                                  ),
                                                  const SizedBox(
                                                    width: 8.0,
                                                  ),
                                                  Text(userr["fullname"]),
                                                ],
                                              );
                                            });
                                      }),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: SizedBox(
                      // width: 400,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: finishProject,
                        icon: const Icon(Icons.task_alt),
                        label: const Text('اتمام پروژه'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: SizedBox(
                      // width: 400,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // عملکرد آپلود فایل
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();
                          if (result != null) {
                            // فایل انتخاب شده
                            print("فایل آپلود شده: ${result.files.single.name}");
                          } else {
                            print("آپلود فایل لغو شد.");
                          }
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('آپلود فایل پروژه'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
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
}
