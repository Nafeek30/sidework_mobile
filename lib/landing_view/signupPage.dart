import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sidework_mobile/app_view/homePage.dart';
import 'package:sidework_mobile/controller/firebaseController.dart';
import 'package:sidework_mobile/landing_view/loginPage.dart';
import 'package:sidework_mobile/utilities/constants.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SignUpPageState();
  }
}

class SignUpPageState extends State<SignUpPage> {
  TextEditingController signUpEmail = TextEditingController();
  TextEditingController signUpPassword = TextEditingController();

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

              /// SIGN UP TEXT
              const Text(
                'Sign Up',
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
                controller: signUpEmail,
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
                controller: signUpPassword,
              ),
              const SizedBox(
                height: 8,
              ),

              /// SIGN UP BUTTON
              ElevatedButton(
                onPressed: () async {
                  await signUp();
                },
                child: const Text('Sign up'),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text(
                  'Already have an account? Log In',
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

  Future signUp() async {
    await FirebaseController().signUpUser(signUpEmail, signUpPassword, context);
  }
}
