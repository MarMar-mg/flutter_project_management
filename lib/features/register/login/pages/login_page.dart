import 'package:flutter/material.dart';
import 'package:managment_flutter_project/features/admin/home_page/pages/home_page.dart';
import 'package:managment_flutter_project/features/user/home_page/pages/home_page.dart';
import '../../../../commons/widgets/loading_widget.dart';
import '../../../../main.dart';
import '../../signup/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    final pass = (await SupaBase.from('users')
        .select('password')
        .eq('email', emailController.text))
        .first['password'];
    final role = (await SupaBase.from('users')
        .select('role')
        .eq('email', emailController.text))
        .first['role'];
    final userId = (await SupaBase.from('users')
        .select('userid')
        .eq('email', emailController.text))
        .first['userid'];
    print(pass);
    if (pass == passController.text) {
      print('66666666666666');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext ctx) =>
              role == 'Admin' ? AdminHomePage(userId: userId,) : UserHomePage(userId: userId,)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A3747), // Dark background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ورود',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 50),

              // Email field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(Icons.person, color: Color(0xFF0A3747)),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: emailController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'نام کاربری',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفاً نام کاربری خود را وارد کنید';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Password field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        obscureText: true,
                        controller: passController,
                        textDirection: TextDirection.ltr, // Ensures left-to-right direction
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'رمز عبور',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفاً رمز عبور خود را وارد کنید';
                          } else if (value.length < 6) {
                            return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                          }
                          return null;
                        },
                      )
                      ,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(Icons.lock, color: Color(0xFF0A3747)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),

              // Login button
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      loginUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Color(0xFF0A3747))
                      : Text(
                    'ورود',
                    style: TextStyle(
                      color: Color(0xFF0A3747),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
