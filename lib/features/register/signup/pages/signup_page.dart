import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../commons/widgets/loading_widget.dart';
import '../../../../main.dart';
import '../../login/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  PageController controller = PageController();
  double scrollPosition = 0.0;

  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _username = '';
  String _password = '';
  String _userType = 'مدیر';
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController roleController = TextEditingController();

  Future<void> register() async {
    if (_userType == 'مدیر') {
      final addToAdmin = await SupaBase.from('admins').insert({
      'userreference': (await SupaBase.from('users').insert({
        'fullname': nameController.text,
        'password': passController.text,
        'role': _userType == 'مدیر'? 'Admin': 'User',
        'email': emailController.text,
      }).select('userid')).first['userid'],
    });
    }else{
      final addToNormalUsers = await SupaBase.from('normalusers').insert({
        'userreference': (await SupaBase.from('users').insert({
          'fullname': nameController.text,
          'password': passController.text,
          'role': _userType == 'مدیر'? 'Admin': 'User',
          'email': emailController.text,
        }).select('userid')).first['userid'],
        'joineddate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });
    }
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext ctx) => LoginPage()));
    setState(() {
      nameController.clear();
      nameController.clear();
      passController.clear();
      emailController.clear();
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xff650573),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 40.0, 30, 80),
      child: Center(
          child: Expanded(
            child: Container(
              width: 380,
              // height: 550,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,// Background color
              border: Border.all(
                color: Colors.purple, // Border color
                width: 3, // Border width
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ثبت نام',
                        style:
                            TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(
                            'ایجاد حساب کاربری جدید یا ',
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                          GestureDetector(
                            onTap: () => {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext ctx) => LoginPage()))
            
                            },
                            child: Text('ورود به حساب کاربری',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.blue)),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'آدرس ایمیل',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفا ایمیل خود را وارد کنید';
                          } else if (!RegExp( r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                            return 'لطفا درستش کن';
                          }
                          return null;
                        },
                        onSaved: (value) => _email = value!,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'نام کاربری',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفا نام کاربری درست را وارد کنید';
                          }
                          return null;
                        },
                        onSaved: (value) => _username = value!,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        obscureText: true,
                        controller: passController,
                        decoration: InputDecoration(
                          labelText: 'رمز عبور',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.visibility),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفا رمز عبور را درست وارد کنید';
                          } else if (value.length < 6) {
                            return 'رمز عبور باید بیشتر از 6 کاراکتر باشد';
                          }
                          return null;
                        },
                        onSaved: (value) => _password = value!,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _userType,
                        decoration: InputDecoration(
                          labelText: 'نوع کاربر',
                          border: OutlineInputBorder(),
                        ),
                        items: ['کاربر عادی', 'مدیر'].map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _userType = value!;
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              register();
                              print("111");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: isLoading? SizedBox(height: 12, width: 60,
                              child: LoadingWidget()): Text(
                            'ثبت نام',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
                    ),
          )),
      ),
    );
  }

  bool isLoading = false;
}
