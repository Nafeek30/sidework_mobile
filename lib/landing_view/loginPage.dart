import 'package:sidework_mobile/app_view/homePage.dart';
import 'package:flutter/material.dart';
import 'package:sidework_mobile/controller/firebaseController.dart';
import 'package:sidework_mobile/landing_view/signupPage.dart';

import '../utilities/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  TextEditingController loginEmail = TextEditingController();
  TextEditingController loginPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 32,
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),

              /// LOGIN TEXT
              const Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 8,
              ),

              /// EMAIL TEXT FIELD
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Constants.sideworkBlue,
                    ),
                  ),
                  hintText: 'Email',
                  labelText: 'Email',
                  prefixIcon: Icon(
                    Icons.email,
                    color: Constants.sideworkBlue,
                  ),
                  suffixStyle: TextStyle(
                    color: Constants.darkTextColor,
                  ),
                ),
                controller: loginEmail,
              ),
              const SizedBox(
                height: 8,
              ),

              /// PASSWORD TEXT FIELD
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Constants.sideworkBlue,
                    ),
                  ),
                  hintText: 'Password',
                  helperText: 'Password must be six characters long.',
                  labelText: 'Password',
                  prefixIcon: Icon(
                    Icons.password,
                    color: Constants.sideworkBlue,
                  ),
                  suffixStyle: TextStyle(
                    color: Constants.darkTextColor,
                  ),
                ),
                controller: loginPassword,
              ),
              const SizedBox(
                height: 8,
              ),

              /// LOGIN BUTTON
              ElevatedButton(
                onPressed: () async {
                  await login();
                },
                child: const Text('Login'),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ),
                  );
                },
                child: const Text(
                  'Don\'t have an account? Sign Up!',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Constants.sideworkButtonBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future login() async {
    await FirebaseController().loginUser(loginEmail, loginPassword, context);
  }
}
