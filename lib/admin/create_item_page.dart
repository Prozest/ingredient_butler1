import 'dart:ffi';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ingredient_butler/user/home_page.dart';
import 'package:ingredient_butler/admin/admin_page.dart';
import 'package:ingredient_butler/utils/menuItem_class.dart';

class CreateItemPage extends StatefulWidget {
  @override
  _CreateItemPage createState() => _CreateItemPage();
}

class _CreateItemPage extends State<CreateItemPage> {
  final controllerName = TextEditingController();
  final controllerPrice = TextEditingController();

  Widget build(BuildContext context) => Scaffold(
        body: ListView(padding: EdgeInsets.all(16), children: <Widget>[
          TextField(
            controller: controllerName,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: controllerPrice,
            decoration: const InputDecoration(hintText: 'Price'),
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 45,
            child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  )),
                ),
                onPressed: () {
                  MenuItem.createMenuItem(
                      name: controllerName.text,
                      cost: num.parse(controllerPrice.text));

                  Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminPage()));
                },
                child: const Text(
                  'Create Menu Item',
                  style: TextStyle(fontSize: 20),
                )),
          )
        ]),
      );

  
}
