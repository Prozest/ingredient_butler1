import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ingredient_butler/user/home_page.dart';
import 'package:ingredient_butler/admin/admin_page.dart';
import 'package:ingredient_butler/utils/menuItem_class.dart';

class AdminUpdateItemState extends StatefulWidget {
  final String id;
  AdminUpdateItemState(this.id);

  @override
  _AdminUpdateItemState createState() => _AdminUpdateItemState(id);
}

class _AdminUpdateItemState extends State<AdminUpdateItemState> {
  final controllerName = TextEditingController();
  final controllerPrice = TextEditingController();
  final String id;
  _AdminUpdateItemState(this.id);

  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          automaticallyImplyLeading: false,
          title: Text('Update Menu Item'),
        ),
        body: FutureBuilder<MenuItem?>(
          future: MenuItem.readMenuItem(id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final menuItem = snapshot.data;
              controllerName.text = menuItem!.name;
              controllerPrice.text = menuItem.cost.toString();
              return menuItem == null
                  ? const Center(child: Text("Could not get data"))
                  : Scaffold(
                      body: ListView(
                          padding: EdgeInsets.all(16),
                          children: <Widget>[
                            TextField(
                              controller: controllerName,
                              decoration:
                                  const InputDecoration(hintText: 'Name'),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                              controller: controllerPrice,
                              decoration:
                                  const InputDecoration(hintText: 'Price'),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    )),
                                  ),
                                  onPressed: () {
                                    MenuItem.updateMenuItem(
                                        name: controllerName.text,
                                        cost: num.parse(controllerPrice.text),
                                        id: id);

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AdminPage()));
                                  },
                                  child: const Text(
                                    'Update Menu Item',
                                    style: TextStyle(fontSize: 20),
                                  )),
                            )
                          ]),
                    );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );
}
