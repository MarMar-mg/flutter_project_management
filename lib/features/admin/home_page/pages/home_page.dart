import 'package:flutter/material.dart';
import 'package:managment_flutter_project/applications/colors.dart';

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
  late Future<dynamic> getProjectsFuture;

  @override
  void initState() {
    super.initState();
    getProjectsFuture = SupaBase.from('projects').select().eq('creator', widget.userId);
  }

  void _addNewProject() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateProjectPage(userId: widget.userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getProjectsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('خطا در دریافت اطلاعات'));
        } else if (!snapshot.hasData || snapshot.data.isEmpty) {
          return Scaffold(
            appBar: _buildCustomAppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'هیچ پروژه‌ای ایجاد نشده است',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        final projects = snapshot.data!;
        final doneProjects = projects.where((project) => project['isdone'] == true).toList();
        final notDoneProjects = projects.where((project) => project['isdone'] != true).toList();

        return Scaffold(
          appBar: _buildCustomAppBar(),
          backgroundColor: Color(0x343F5F68),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                HoverButton(
                  onTap: _addNewProject,
                  child: Text(
                    'ایجاد پروژه جدید',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildProjectSection('پروژه‌های انجام‌شده', doneProjects),
                      const SizedBox(height: 20),
                      _buildProjectSection('پروژه‌های انجام‌نشده', notDoneProjects),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectSection(String title, List<dynamic> projects) {
    if (projects.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black12),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'هیچ پروژه‌ای در این دسته وجود ندارد',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black12),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (MediaQuery.of(context).size.width / 200).floor(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return HoverCard(
              project: project,
              userId: widget.userId,
            );
          },
        ),
      ],
    );
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
                    'صفحه HH',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'خوش آمدید به داشبورد مدیریت',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
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

class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const HoverButton({Key? key, required this.child, required this.onTap}) : super(key: key);

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
          height: 60,
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
            borderRadius: BorderRadius.circular(12),
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
          child: Center(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class HoverCard extends StatefulWidget {
  final dynamic project;
  final int userId;

  const HoverCard({Key? key, required this.project, required this.userId}) : super(key: key);

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectPage(
              projectName: widget.project['projectname'] ?? 'نام‌پروژه',
              projectId: widget.project['projectid'] ?? 0,
              teamId: widget.project['teamid'] ?? 0,
              description: widget.project['description'] ?? '',
              userId: widget.userId,
              isDone: widget.project['isdone']
            ),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _isHovered ? Color(0xFF0A3747).withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: _isHovered
                ? [
              BoxShadow(
                color: Color(0xFF0A3747).withOpacity(0.4),
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
          transform: _isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder, size: 50, color: Color(0xFF0A3747)),
                SizedBox(height: 10),
                Text(
                  widget.project['projectname'] ?? 'نام‌پروژه',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
