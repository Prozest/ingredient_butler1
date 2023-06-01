import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ingredient_butler/admin/admin_update_item.dart';
import 'package:ingredient_butler/user/home_page.dart';
import 'package:ingredient_butler/admin/admin_page.dart';
import 'package:ingredient_butler/utils/menuItem_class.dart';

class AdminViewMenuState extends StatefulWidget {
  final String id;
  final String name;
  AdminViewMenuState(this.id, this.name);

  @override
  _AdminViewMenuState createState() => _AdminViewMenuState(id, name);
}

class _AdminViewMenuState extends State<AdminViewMenuState> {
  final String id;
  final String name;
  _AdminViewMenuState(this.id, this.name);

  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          automaticallyImplyLeading: false,
          title: Text(name),
        ),
        body: FutureBuilder<MenuItem?>(
          future: MenuItem.readMenuItem(id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final menuItem = snapshot.data;

              return menuItem == null
                  ? const Center(child: Text("Could not get data"))
                  : Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 14, right: 14),
                      child: Column(
                        children: [
                          SizedBox(width: double.infinity, child: Text(menuItem.name, textAlign: TextAlign.left,)),
                          SizedBox(width: double.infinity, child: Text(menuItem.cost.toString(), textAlign: TextAlign.left,)),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              SizedBox(
                                width: 180,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final docMenuItem = FirebaseFirestore.instance.collection('menuitems').doc(id);

                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminUpdateItemState(menuItem.id)));
                                  }, 
                                  child: const Text("Update")),
                              ),
                              const SizedBox(width: 20,),
                              SizedBox(
                                width: 180,
                                child: ElevatedButton(
                                  onPressed: (){
                                    showDialog(
                                      context: context, 
                                      builder: (BuildContext context){
                                        return AlertDialog(
                                          title: const Text("Delete?"),
                                          content: const Text("Are you sure you want to delete this menu item?"),
                                          actions: [
                                            TextButton(onPressed: (){
                                              MenuItem.deleteMenuItem(id: id);
                                              Navigator.of(context).pop();
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminPage()));
                                            }, child: const Text("Yes")),
                                            TextButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("No")),
                                          ],
                                        );
                                      }
                                    );
                                  },
                                  child: const Text("Delete"),
                                ),
                              )
                            ]),
                          )
                        ],
                      ),
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
