import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Example data
  String username = "Ali";
  String email = "ali@example.com";
  String joinDate = "January 1, 2023";
  int projectCount = 12;
  bool isActive = true; // User activity status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Details
            Text(
              "Username: $username",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Email: $email",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Join Date: $joinDate",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Projects: $projectCount",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Stateful Widget: Activity Status Toggle
            Row(
              children: [
                Text(
                  "Active Status: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
                ),
              ],
            ),

            // Add more widgets or styling as needed
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Example action for future functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile Updated!'),
                    ),
                  );
                },
                child: Text('Update Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SizedBox(height: 24),
// Row(
// children: [
// Text(
// 'ورود به حساب کاربری یا ',
// style: TextStyle(fontSize: 10, color: Colors.black),
// ),
// GestureDetector(
// onTap: () => {
// Navigator.pushReplacement(
// context,
// MaterialPageRoute(
// builder: (BuildContext ctx) => RegisterPage()))
//
// },
// child: Text('ایجاد حساب کاربری جدید',
// style: TextStyle(
// fontSize: 10, color: Colors.blue)),
// )
// ],
// ),
// SizedBox(height: 20),