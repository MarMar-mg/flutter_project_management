import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../main.dart';
import '../../login/pages/login_page.dart';
import 'dart:ui';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String _userType = 'مدیر';

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();

  Future<void> register() async {
    try {
      // Insert user data into 'users' table and get the user ID
      final userId = (await SupaBase.from('users').insert({
        'fullname': nameController.text,
        'password': passController.text,
        'role': _userType == 'مدیر' ? 'Admin' : 'User',
        'email': emailController.text,
      }).select('userid')).first['userid'];

      // Insert user into respective table based on role
      if (_userType == 'مدیر') {
        await SupaBase.from('admins').insert({'userreference': userId});
      } else {
        await SupaBase.from('normalusers').insert({
          'userreference': userId,
          'joineddate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        });
      }

      // Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext ctx) => LoginPage()),
      );

      // Clear form fields
      setState(() {
        emailController.clear();
        nameController.clear();
        passController.clear();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error during registration: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF174251), // Dark background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Container(
            width: 380,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFF0A3747),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ثبت نام',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ایجاد حساب کاربری جدید یا ',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => LoginPage(),
                            ),
                          ),
                          child: Text(
                            'ورود به حساب کاربری',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
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
                            controller: nameController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'نام کاربری',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 15,
                              ),
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            obscureText: false, // Ensure the text is not obscured for email input
                            controller: emailController,
                            textAlign: TextAlign.left, // Align text to the left
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'آدرس ایمیل',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 15,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'لطفاً ایمیل خود را وارد کنید';
                              } else if (!RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value)) {
                                return 'ایمیل معتبر وارد کنید';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(Icons.email, color: Color(0xFF0A3747)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
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
                          child: Icon(Icons.group, color: Color(0xFF0A3747)),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _userType,
                            decoration: InputDecoration(
                              hintText: 'نوع کاربر',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 15,
                              ),
                            ),
                            items: ['کاربر عادی', 'مدیر'].map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type, style: TextStyle(color: Colors.black)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _userType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
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
                            textAlign: TextAlign.left, // Align text to the left
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'رمز عبور',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 15,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'لطفاً رمز عبور خود را وارد کنید';
                              } else if (value.length < 6) {
                                return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                              }
                              return null;
                            },
                          ),
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

                  // Register button
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          register();
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
                        'ثبت نام',
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
        ),
      ),
    );
  }
}
