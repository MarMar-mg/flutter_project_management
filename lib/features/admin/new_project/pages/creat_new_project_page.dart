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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A3747), Color(0xFF0C4B5E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'ایجاد پروژه و تشکیل تیم',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F5F5), Color(0xFFEDEDED)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
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
                  decoration: InputDecoration(
                    hintText: 'عنوان پروژه را وارد کنید',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF0A3747)),
                    ),
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
                  decoration: InputDecoration(
                    hintText: 'توضیحات پروژه را وارد کنید',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF0A3747)),
                    ),
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
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFF0A3747), width: 1),
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
                                  controller: _tasks[taskIndex]
                                      ["taskController"],
                                  decoration: InputDecoration(
                                    hintText: 'وظیفه جدید را وارد کنید',
                                    filled: true,
                                    fillColor: Color(0xFFF5F5F5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xFF0A3747)),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () => _removeTask(taskIndex),
                              ),
                            ],
                          ),
                          ...task["subtasks"].asMap().entries.map((subEntry) {
                            int subtaskIndex = subEntry.key;
                            TextEditingController subtaskController =
                                subEntry.value;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: subtaskController,
                                      decoration: InputDecoration(
                                        hintText: 'زیر وظیفه را وارد کنید',
                                        filled: true,
                                        fillColor: Color(0xFFF5F5F5),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Color(0xFF0A3747)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
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
                                    color: Color(0xFF0A3747)),
                                onPressed: () => _addSubtask(taskIndex),
                              ),
                              const Text('افزودن زیر وظیفه'),
                            ],
                          ),
                          const Divider(
                            color: Color(0xFF0A3747),
                            thickness: 1,
                            height: 20,
                          ),
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
                            'اضافه کردن وظیفه',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                isTeamSelected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'تیم مورد نظر انتخاب شده',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A3747),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                chosenUsers = [];
                                isChosenTeam = -1;
                                chosenTeam = -1;
                                teamId = -1;
                                isTeam = false;
                                isTeamSelected = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0A3747),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(Icons.edit, color: Colors.white),
                            label: Text(
                              'تغییر انتخاب تیم',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: HoverButton(
                                    onTap: () {
                                      setState(() {
                                        isTeam = false;
                                      });
                                    },
                                    child: Text(
                                      'تشکیل تیم',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: HoverButton(
                                    onTap: () {
                                      setState(() {
                                        isTeam = true;
                                      });
                                    },
                                    child: Text(
                                      'انتخاب تیم',
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
                                        const SizedBox(
                                          height: 8,
                                        ),
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
                                                  controller:
                                                      _teamNameController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'عنوان تیم را وارد کنید',
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFF0A3747)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: users.length,
                                          itemBuilder: (context, index) {
                                            final user = users[index];
                                            return Container(
                                              margin: const EdgeInsets
                                                  .symmetric(
                                                  vertical:
                                                      8), // Spacing between items
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Color(0xFF0A3747),
                                                    width: 1.5),
                                                // Add border
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: CheckboxListTile(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                title: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .person, // Add an icon
                                                      color: chosenUsers
                                                              .contains(user[
                                                                  'userid'])
                                                          ? Color(0xFF0A3747)
                                                          : Colors.grey,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      user["fullname"],
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: chosenUsers
                                                                .contains(user[
                                                                    'userid'])
                                                            ? Color(0xFF0A3747)
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                value: chosenUsers
                                                    .contains(user['userid']),
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    if (chosenUsers.contains(
                                                        user['userid'])) {
                                                      chosenUsers.remove(
                                                          user['userid']);
                                                    } else {
                                                      chosenUsers
                                                          .add(user['userid']);
                                                    }
                                                  });
                                                },
                                                activeColor: Color(0xFF0A3747),
                                                checkColor: Colors.white,
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .trailing, // Move checkbox to the right
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          width: double.infinity,
                                          child: HoverButton(
                                            onTap: () => {
                                              setState(() {
                                                isTeamSelected = true;
                                              }),
                                              createTeam()
                                            },
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
                                                        return Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xFF0A3747),
                                                                width: 1.5),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.3),
                                                                spreadRadius: 2,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    0, 3),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              CheckboxListTile(
                                                                title: Text(
                                                                  team[
                                                                      "teamname"],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: isChosenTeam ==
                                                                            teamId
                                                                        ? Color(
                                                                            0xFF0A3747)
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                                value:
                                                                    isChosenTeam ==
                                                                        teamId,
                                                                onChanged:
                                                                    (bool?
                                                                        value) {
                                                                  setState(() {
                                                                    isChosenTeam = value ==
                                                                            true
                                                                        ? teamId
                                                                        : -1;
                                                                  });
                                                                },
                                                                activeColor: Color(
                                                                    0xFF0A3747),
                                                                checkColor:
                                                                    Colors
                                                                        .white,
                                                                controlAffinity:
                                                                    ListTileControlAffinity
                                                                        .leading,
                                                              ),
                                                              if (isChosenTeam ==
                                                                  teamId)
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16.0,
                                                                      vertical:
                                                                          8),
                                                                  child: TeamMembersList(
                                                                      teamId:
                                                                          teamId),
                                                                ),
                                                            ],
                                                          ),
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
                                              backgroundColor:
                                                  Color(0xFF0A3747),
                                              shadowColor: Color(0xFF0A3747)
                                                  .withOpacity(0.5),
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                  height: 40,
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
                        child: HoverButton(
                          onTap: createProject,
                          child: Text(
                            'ثبت پروژه',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                        child: HoverButton(
                          onTap: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                            if (result != null) {
                              print(
                                  "فایل آپلود شده: ${result.files.single.name}");
                            } else {
                              print("آپلود فایل لغو شد.");
                            }
                          },
                          child: const Text(
                            'آپلود فایل پروژه',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                  ],
                ),
                SizedBox(
                  height: 14,
                ),
              ],
            ),
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
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF0A3747), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
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
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const HoverButton({Key? key, required this.child, required this.onTap})
      : super(key: key);

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? LinearGradient(
                    colors: [Color(0xFF0C4B5E), Color(0xFF0A3747)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Color(0xFF0A3747), Color(0xFF0C4B5E)],
                  ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Color(0xFF0A3747).withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    )
                  ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
