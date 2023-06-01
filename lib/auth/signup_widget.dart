import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ingredient_butler/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ingredient_butler/utils/utils.dart';


class SignUpWidget extends StatefulWidget {
  
  final VoidCallback onClickedSignIn;

  const SignUpWidget({super.key, required this.onClickedSignIn});

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
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
        child: Form(
          key: formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 40),
            TextFormField(
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Email'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) =>
                email != null && !EmailValidator.validate(email)
                  ? 'Email not valid. Try Again'
                  : null,
            ),
            const SizedBox(height: 4),
            TextFormField(
                controller: passwordController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Password'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
                  ? 'Password should be min. 6 characters long'
                  : null
                ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
                onPressed: signUp,
                icon: const Icon(Icons.lock_open),
                label: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 24),
                )),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black54, fontSize: 16),
                text: 'Already Signed Up?  ',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                    ..onTap = widget.onClickedSignIn,
                    text: 'Log in',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue
                    )
                  )
                ]
              )
            )
          ]),
        ),
      );

  Future signUp() async {

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context, 
      builder: (context) => Center(child: CircularProgressIndicator(),)
    );
    
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(), 
        password: passwordController.text.trim()
      );
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst,);
  }
}