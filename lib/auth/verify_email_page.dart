import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ingredient_butler/user/home_page.dart';
import 'package:ingredient_butler/utils/utils.dart';

class VerifyEmailPage extends StatefulWidget {

  @override
  _VerifyEmailPage createState() => _VerifyEmailPage();
}

class _VerifyEmailPage extends State<VerifyEmailPage>{

  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if(!isEmailVerified){
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {

    final User user = await FirebaseAuth.instance.currentUser!;
    user.reload();

    setState(() {
      isEmailVerified = user.emailVerified;
    });

    if(isEmailVerified) {
      saveAccount(user);
      timer?.cancel();
    };
  }

  Future sendVerificationEmail() async{
    try{
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      Utils.showSnackBar(e.toString());
    }
  }
  
  Future saveAccount(User user) async{

    final docAccount = FirebaseFirestore.instance.collection("users").doc(user.uid);

    final json = {
      'admin': false,
      'name': "Abdulla",
      'age': 23,
    };

    await docAccount.set(json);
  }

  Widget build(BuildContext context) => isEmailVerified
  ? HomePage()
  : Scaffold(
    appBar: AppBar(
      title:  const Text('Email Verification'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          const SizedBox(width : double.infinity),
          const Text(
            'A verification request has been sent\nplease check your inbox.',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            "Didn't recieve the email?",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          FractionallySizedBox(
            widthFactor: 0.7,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)
              ),
              icon: const Icon(Icons.email, size: 28),
              label: const Text(
                'Send Another Request',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: canResendEmail ? sendVerificationEmail : null,
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => FirebaseAuth.instance.signOut(), 
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 20),
            )
          )
        ],
      ),
    ),
  );
}