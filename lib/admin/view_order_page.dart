import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ingredient_butler/utils/oldorder_class.dart';

class ViewOrderState extends StatefulWidget {
  final String id;
  ViewOrderState(this.id);

  @override
  _ViewOrderState createState() => _ViewOrderState(id);
}

class _ViewOrderState extends State<ViewOrderState> {
  final String id;

  _ViewOrderState(this.id);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FutureBuilder<OldOrderClass?>(
          future: OldOrderClass.readOrder(id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Data not found ${snapshot.error}');

            } else if (snapshot.hasData) {
              return Text(id);

            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      );
}
