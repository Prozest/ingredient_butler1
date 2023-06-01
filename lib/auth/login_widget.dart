import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ingredient_butler/utils/constants.dart';
import 'package:ingredient_butler/main.dart';
import 'package:ingredient_butler/utils/utils.dart';
import 'package:ingredient_butler/auth/forgot_password_page.dart';

class LoginWidget extends StatefulWidget {

  final VoidCallback onClickedSignUp;

  const LoginWidget({super.key, required this.onClickedSignUp});

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(height: 40),
          TextField(
            controller: emailController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 4),
          TextField(
              controller: passwordController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 30),
          ElevatedButton.icon(
              onPressed: signIn,
              icon: const Icon(Icons.lock_open),
              label: const Text(
                'Login',
                style: TextStyle(fontSize: 24),
              )),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ForgotPasswordPage(),
            )),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blue,
                fontSize: 20
              ),
            )
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black54, fontSize: 16),
              text: 'Want in?  ',
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()
                  ..onTap = widget.onClickedSignUp,
                  text: 'Sign Up',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue
                  )
                )
              ]
            )
          )
        ]),
      );

  Future signIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator())
    );

    try {
      final User? user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim())).user;

      
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst,);
  }
}
