import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  String id;
  final String name;
  final num cost;
  final num stock;

  MenuItem(
      {this.id = '',
      required this.name,
      required this.cost,
      required this.stock});

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'cost': cost, 'stock': stock};

  static MenuItem fromJson(Map<String, dynamic> json) => MenuItem(
      id: json['id'],
      name: json['name'],
      cost: json['cost'],
      stock: json['stock']);

  static Future createMenuItem(
      {required String name, required num cost}) async {
    final docMenuItem =
        FirebaseFirestore.instance.collection('menuitems').doc();

    final menuItem =
        MenuItem(id: docMenuItem.id, name: name, cost: cost, stock: 0);

    final json = menuItem.toJson();

    await docMenuItem.set(json);
  }

  static Stream<List<MenuItem>> readMenuItems() => FirebaseFirestore.instance
      .collection('menuitems')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList());

  static Future<bool> checkStock(String menuID, num checkAmount) async {
    final docMenuItem =
        FirebaseFirestore.instance.collection('menuitems').doc(menuID);

    final snapshot = await docMenuItem.get();

    if (snapshot.exists) {
      MenuItem temp = MenuItem.fromJson(snapshot.data()!);
      num tempNum = temp.stock + checkAmount;

      if (tempNum >= 0) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static Future addRemoveStock(String id, num changeAmount) async {
    if (await checkStock(id, changeAmount)) {
      final docMenuItem =
          FirebaseFirestore.instance.collection('menuitems').doc(id);

      final snapshot = await docMenuItem.get();

      if (snapshot.exists) {
        MenuItem temp = MenuItem.fromJson(snapshot.data()!);

        final menuItem = MenuItem(
            id: temp.id,
            name: temp.name,
            cost: temp.cost,
            stock: temp.stock + changeAmount);

        final json = menuItem.toJson();

        await docMenuItem.update(json);
      }
    }
  }

  static Future<MenuItem?> readMenuItem(String id) async {
    final docMenuItem =
        FirebaseFirestore.instance.collection('menuitems').doc(id);
    final snapshot = await docMenuItem.get();

    if (snapshot.exists) {
      return MenuItem.fromJson(snapshot.data()!);
    }
    return null;
  }

  static Future updateMenuItem(
      {required String name, required num cost, required String id}) async {
    final docMenuItem =
        FirebaseFirestore.instance.collection('menuitems').doc(id);

    final menuItem =
        MenuItem(id: docMenuItem.id, name: name, cost: cost, stock: 0);

    final json = menuItem.toJson();

    await docMenuItem.update(json);
  }

  static Future deleteMenuItem({required String id}) async {
    final docMenuItem =
        FirebaseFirestore.instance.collection('menuitems').doc(id);

    await docMenuItem.delete();
  }
}
