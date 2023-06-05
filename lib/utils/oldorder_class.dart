import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OldOrderClass {
  String id;
  String menuID;
  num quantity;
  num state; //1: In cart, 2: Cooking, 3: Picked up, 4: Delivered, 5: Cancelled

  OldOrderClass(
      {this.id = '',
      required this.menuID,
      required this.quantity,
      required this.state});

  Map<String, dynamic> toJson() => {
        'id': id,
        'menuID': menuID,
        'quantity': quantity,
        'state': state
      };

  static Future createOrderToCart(
      {required String menuID,
      required String userID,
      required num quantity}) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(userID);

    final docOrder = docUser.collection('cart').doc();

    final orderObj = OldOrderClass(
        id: docOrder.id,
        menuID: menuID,
        quantity: quantity,
        state: 1);

    final json = orderObj.toJson();

    await docOrder.set(json);
  }

  static Stream<List<OldOrderClass>> readCartOrders(String userID) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('cart')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => OldOrderClass.fromJson(doc.data()))
              .toList());

  static Future<OldOrderClass?> readCartOrder(String userID, String orderID) async {
    final docOrder = FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('cart')
        .doc(orderID);
    final snapshot = await docOrder.get();

    if (snapshot.exists) {
      return OldOrderClass.fromJson(snapshot.data()!);
    }
    return null;
  }

  static Stream<List<OldOrderClass>> readOrders() => FirebaseFirestore.instance
      .collection('orders')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => OldOrderClass.fromJson(doc.data())).toList());

  static Future<OldOrderClass?> readOrder(String id) async {
    final docOrder = FirebaseFirestore.instance.collection('orders').doc(id);
    final snapshot = await docOrder.get();

    if (snapshot.exists) {
      return OldOrderClass.fromJson(snapshot.data()!);
    }
    return null;
  }

  static OldOrderClass fromJson(Map<String, dynamic> json) => OldOrderClass(
      id: json['id'],
      menuID: json['menuID'],
      quantity: json['quantity'],
      state: json['state']);

  static Future deleteCartOrder(
      {required String cartId, required String uid}) async {
    final docCartOrder = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(cartId);

    await docCartOrder.delete();
  }

  static void finishCart(String uid) async {
    QuerySnapshot orders = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("cart")
        .get();

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("orders");

    List<Map> products = [];

    for (int i = 0; i < orders.docs.length; i++) {
      products.add({
        'id': orders.docs[i]['id'],
        'menuID': orders.docs[i]['menuID'],
        'quantity': orders.docs[i]['quantity'],
        'state':orders.docs[i]['state'],
      });

      //deleteCartOrder(cartId: orders.docs[i]['id'], uid: uid);
    }


    var dateTime = DateTime.now();
    final path = 'orders/${dateTime.millisecondsSinceEpoch}';
    final ref = FirebaseFirestore.instance.doc(path);
    await ref.set({
      'id': '${dateTime.millisecondsSinceEpoch}',
      'time': dateTime,
      'userID': uid,
      'products':products
    });
  ///asdaadasd
    
  }
}
