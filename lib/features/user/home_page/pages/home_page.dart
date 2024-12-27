import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../admin/new_project/pages/creat_new_project_page.dart';
import '../../../admin/projects/pages/project_page.dart';
import '../../projects/pages/project_page.dart';

class UserHomePage extends StatefulWidget {
  final int userId;

  const UserHomePage({super.key, required this.userId});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  Widget build(BuildContext context) {
    var getTeamMembers =
    SupaBase.from('teammembers').select().eq('userid', widget.userId);

    return FutureBuilder(
      future: getTeamMembers,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطا در بارگذاری تیم‌ها',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }
        final teamMembers = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text(
                'HH صفحه',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: Colors.teal[700],
          ),
          backgroundColor: Color(0xffe7ebf0),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.teal[500],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'خوش آمدید به داشبورد مدیریت',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: teamMembers.isEmpty
                      ? Center(
                    child: Text(
                      'هنوز عضو هیچ تیمی نیستید!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                      : listTeams(teamMembers),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget listTeams(List teamMembers) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: teamMembers.length,
      itemBuilder: (context, index) {
        final user = teamMembers[index];
        return FutureBuilder(
          future: SupaBase.from('teams').select().eq('teamid', user['teamid']),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'خطا در بارگذاری تیم‌ها',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }
            final team = snapshot.data![0];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
                    child: Text(
                      '${team['teamname']}:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  listProjects(team, user['userid']),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget listProjects(Map team, int userId) {
    return FutureBuilder(
      future: SupaBase.from('projects').select().eq('teamid', team['teamid']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطا در بارگذاری پروژه‌ها',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }
        final projectsList = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1,
          ),
          itemCount: projectsList.length,
          itemBuilder: (context, index) {
            final project = projectsList[index];
            return MouseRegion(
              onEnter: (_) => setState(() {
                project['hover'] = true;
              }),
              onExit: (_) => setState(() {
                project['hover'] = false;
              }),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProjectPage(
                        projectName: project['projectname'],
                        projectId: project['projectid'],
                        teamId: project['teamid'],
                        description: project['description'],
                        userId: userId,
                      ),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: project['hover'] == true ? Colors.teal[300] : Colors.teal[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: project['hover'] == true
                        ? [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      )
                    ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder,
                        size: 40,
                        color: Colors.teal[700],
                      ),
                      SizedBox(height: 10),
                      Text(
                        project['projectname'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

}
