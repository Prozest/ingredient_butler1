import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  String id;
  final String name;
  final num cost;

  MenuItem({this.id = '', required this.name, required this.cost});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cost': cost,
      };

  static MenuItem fromJson(Map<String, dynamic> json) =>
      MenuItem(id: json['id'], name: json['name'], cost: json['cost']);

  static Future<MenuItem?> readMenuItem(String id) async {
    final docMenuItem =
        FirebaseFirestore.instance.collection('menuitems').doc(id);
    final snapshot = await docMenuItem.get();

    if (snapshot.exists) {
      return MenuItem.fromJson(snapshot.data()!);
    }
    return null;
  }
  

  static Future createMenuItem({required String name, required num cost}) async {
    final docMenuItem =
        FirebaseFirestore.instance.collection('menuitems').doc();

    final menuItem = MenuItem(
      id: docMenuItem.id,
      name: name,
      cost: cost,
    );

    final json = menuItem.toJson();

    await docMenuItem.set(json);
  }

  static Future updateMenuItem({required String name, required num cost, required String id}) async {
    final docMenuItem =
        FirebaseFirestore.instance.collection('menuitems').doc(id);

    final menuItem = MenuItem(
      id: docMenuItem.id,
      name: name,
      cost: cost,
    );

    final json = menuItem.toJson();

    await docMenuItem.update(json);
  }

  static Future deleteMenuItem({required String id}) async {
    final docMenuItem =
        FirebaseFirestore.instance.collection('menuitems').doc(id);

    await docMenuItem.delete();
  }

  static Stream<List<MenuItem>> readMenuItems() => FirebaseFirestore.instance
      .collection('menuitems')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList());
}
