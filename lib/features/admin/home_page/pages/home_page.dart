import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../applications/colors.dart';
import '../../../../main.dart';
import '../../new_project/pages/creat_new_project_page.dart';
import '../../projects/pages/project_page.dart';

class AdminHomePage extends StatefulWidget {
  final int userId;
  const AdminHomePage({super.key, required this.userId});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final List<String> projects = [];

  void _addNewProject() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateProjectPage(userId: widget.userId,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    var getProjects = SupaBase.from('projects').select().eq('creator', widget.userId);
    return FutureBuilder(
        future: getProjects,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Center(child: Text('صفحه HH')),
              backgroundColor: Colors.purple,
            ),
            backgroundColor: Color(0xfff0f0f0),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(50, 40.0, 50, 20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _addNewProject,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'ایجاد پروژه جدید',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Expanded(
                      child: projects.isEmpty
                          ? Center(
                              child: Text(
                                'هیچ پروژه‌ای ایجاد نشده است',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5, // Number of items per row
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                final project = projects[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProjectPage(
                                                projectName:
                                                    project['projectname'],
                                                projectId:
                                                    project['projectid'],
                                                teamId: project['teamid'],
                                                description:
                                                    project['description'], userId: widget.userId,
                                              )),
                                    );
                                  },
                                  child: Card(
                                    elevation: 3,
                                    color: Colors.white,
                                    child: Center(
                                      child: Text(
                                        project['projectname'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
