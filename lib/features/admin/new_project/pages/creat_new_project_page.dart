import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../main.dart';
import '../../home_page/pages/home_page.dart';

class CreateProjectPage extends StatefulWidget {
  final int userId;

  const CreateProjectPage({super.key, required this.userId});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _tasks = [];
  Set<int> expandedTeams = {};

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

  Future<void> createProject() async {
    if (teamId == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً تیم خود را انتخاب کنید!")),
      );
      return;
    } else if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً توضیحات پروژه خود را وارد کنید!")),
      );
      return;
    } else if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً عنوان پروژه را وارد کنید!")),
      );
      return;
    } else {
      final insertedProject = await SupaBase.from('projects')
          .insert({
            'teamid': teamId,
            'creator': widget.userId,
            'projectname': _titleController.text,
            'description': _descriptionController.text,
          })
          .select('projectid')
          .single();
      final int addToProjects = insertedProject['projectid'];

      for (var task in _tasks) {
        String taskTitle = task["taskController"].text;
        final insertedTask = await SupaBase.from('tasks')
            .insert({
              'tasktitle': taskTitle,
              'projectid': addToProjects,
              'duedate': null,
              'assignedto': null,
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

      print(teamId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("پروژه و وظایف با موفقیت ذخیره شدند")),
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext ctx) => AdminHomePage(
                    userId: widget.userId,
                  )));

      return;
    }
  }

  Future<void> createTeam() async {
    print('00000000000');
    if (chosenUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً حداقل یک عضو انتخاب کنید!")),
      );
      return;
    }
    teamId = (await SupaBase.from('teams').insert({
      'teamname': _teamNameController.text,
      'createdby': widget.userId,
    }).select('teamid'))
        .first['teamid'];
    final users = await SupaBase.from('users').select('userid');
    print(users);
    chosenUsers.forEach((user) async {
      final addToTeams = await SupaBase.from('teammembers')
          .insert({'userid': user, 'roleinteam': 'user', 'teamid': teamId});
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تیم مورد نظر با موفقیت ثبت شد")),
    );
    return;
  }

  void addTeam() {
    chosenTeam = isChosenTeam;
    teamId = isChosenTeam;
    print(isChosenTeam);
    if (chosenTeam == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً یک تیم انتخاب کنید!")),
      );
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تیم مورد نظر با موفقیت ثبت شد!")),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    var getUsers = SupaBase.from('users').select().eq('role', 'User');
    var getTeams = SupaBase.from('teams').select();
    return Scaffold(
      appBar: AppBar(
        title: const Text('ایجاد پروژه و تشکیل تیم'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'عنوان پروژه:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'عنوان پروژه را وارد کنید',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'توضیحات پروژه:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'توضیحات پروژه را وارد کنید',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'وظایف:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
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
                          const Text('افزودن زیر وظیفه'),
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
                    label: const Text('اضافه کردن وظیفه',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isTeamSelected
                  ? Text(
                      'اthvhjbkl;dfghjklیفه',
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => {
                                    setState(() {
                                      isTeam = true;
                                    })
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: const Text(
                                    'انتخاب تیم',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 100,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => {
                                    setState(() {
                                      isTeam = false;
                                    })
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: const Text(
                                    'تشکیل تیم',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        !isTeam
                            ? FutureBuilder(
                                future: getUsers,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final users = snapshot.data!;
                                  return Column(
                                    children: [
                                      const Text(
                                        'انتخاب اعضای تیم',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8,),
                                      Row(
                                        children: [
                                          const Text(
                                            'عنوان تیم:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            width: 24,
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              // width: 300,
                                              child: TextField(
                                                controller: _teamNameController,
                                                decoration: const InputDecoration(
                                                  hintText:
                                                      'عنوان تیم را وارد کنید',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8,),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: users.length,
                                        itemBuilder: (context, index) {
                                          final user = users[index];
                                          return CheckboxListTile(
                                            title: Text(user["fullname"]),
                                            value: chosenUsers
                                                    .contains(user['userid'])
                                                ? true
                                                : false,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (chosenUsers
                                                    .contains(user['userid'])) {
                                                  chosenUsers
                                                      .remove(user['userid']);
                                                } else {
                                                  chosenUsers
                                                      .add(user['userid']);
                                                }
                                              });
                                            },
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => {
                                            setState(() {
                                              isTeamSelected = true;
                                            }),
                                            createTeam()
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                          ),
                                          child: const Text(
                                            'ذخیره تیم',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                })
                            : FutureBuilder(
                                future: getTeams,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final teams = snapshot.data!;
                                  return Column(
                                    children: [
                                      const Text(
                                        'انتخاب تیم',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: 1,
                                        itemBuilder: (context, index) {
                                          final team = teams[index];
                                          return Column(
                                            children: [
                                              FutureBuilder(
                                                future:
                                                    getTeams, // Fetch all teams
                                                builder:
                                                    (context, teamSnapshot) {
                                                  if (!teamSnapshot.hasData) {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  }

                                                  final teams =
                                                      teamSnapshot.data;
                                                  if (teams is! List) {
                                                    return const Center(
                                                        child: Text(
                                                            'Error: Teams data is not a list.'));
                                                  }

                                                  return ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount: teams.length,
                                                    itemBuilder:
                                                        (context, teamIndex) {
                                                      final team =
                                                          teams[teamIndex];
                                                      final teamId =
                                                          team['teamid'];
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CheckboxListTile(
                                                            title: Text(team[
                                                                "teamname"]),
                                                            value:
                                                                isChosenTeam ==
                                                                    teamId,
                                                            onChanged:
                                                                (bool? value) {
                                                              setState(() {
                                                                isChosenTeam =
                                                                    value ==
                                                                            true
                                                                        ? teamId
                                                                        : -1;
                                                              });
                                                            },
                                                          ),
                                                          // Show members if the team is selected
                                                          if (isChosenTeam ==
                                                              teamId)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          16.0),
                                                              child:
                                                                  TeamMembersList(
                                                                      teamId:
                                                                          teamId),
                                                            ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => {
                                            addTeam(),
                                            setState(() {
                                              isTeamSelected = true;
                                            }),
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                          ),
                                          child: const Text(
                                            'انتخاب تیم',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
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
                        onPressed: createProject,
                        icon: const Icon(Icons.save),
                        label: const Text('ثبت پروژه'),
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
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();
                          if (result != null) {
                            print(
                                "فایل آپلود شده: ${result.files.single.name}");
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

class TeamMembersList extends StatelessWidget {
  final int teamId;

  const TeamMembersList({Key? key, required this.teamId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var getUsers = SupaBase.from('users').select().eq('role', 'User');
    return FutureBuilder(
      future: SupaBase.from('teammembers').select().eq('teamid', teamId),
      builder: (context, memberSnapshot) {
        if (!memberSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final teamMembers = memberSnapshot.data;
        if (teamMembers is! List) {
          return const Center(
              child: Text('Error: Team members data is not a list.'));
        }

        // Map member IDs to user IDs
        final teamUserIds =
            teamMembers.map((member) => member['userid']).toList();

        return FutureBuilder(
          future: getUsers, // Fetch all users
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final users = userSnapshot.data;
            if (users is! List) {
              return const Center(
                  child: Text('Error: Users data is not a list.'));
            }

            // Filter users belonging to the current team
            final filteredUsers = users.where((user) {
              return teamUserIds.contains(user['userid']);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: filteredUsers.map((user) {
                return ListTile(
                  title: Text(user['fullname']),
                  subtitle: Text(user['email'] ?? 'No Email'),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
