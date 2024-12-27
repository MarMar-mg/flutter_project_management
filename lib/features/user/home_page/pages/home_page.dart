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
            title: Center(child: Text('صفحه اصلی')),
            backgroundColor: Colors.purple,
          ),
          backgroundColor: Color(0xfff0f0f0),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(50, 20.0, 50, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                teamMembers.isEmpty
                    ? Center(
                  child: Text(
                    'هنوز عضو هیچ تیمی نیستید!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : Flexible(
                  child: listTeams(teamMembers),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget listTeams(List teamMembers) {
  return ListView.builder(
    shrinkWrap: true,  // Ensures the ListView takes only necessary space
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
          final team = snapshot.data![0];  // Assuming each user is in one team
          return Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
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
                listProjects(team, user['userid']), // Show the projects for this team
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
        shrinkWrap: true, // Ensures it takes only the required space
        physics: BouncingScrollPhysics(), // Allows scrolling within the grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // Number of items per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: projectsList.length,
        itemBuilder: (context, index) {
          final project = projectsList[index];
          return GestureDetector(
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
            child: Card(
              elevation: 3,
              color: Colors.white,
              child: Center(
                child: Text(
                  project['projectname'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
