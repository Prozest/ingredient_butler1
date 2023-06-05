// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ingredient_butler/utils/order_class.dart';
class OrderCore{

  static Map<String, dynamic> toJson_OrderDetails(OrderDetails orderDetails) => {
        'id': orderDetails.id,
        'menuID': orderDetails.menuID,
        'quantity': orderDetails.quantity,
  };

  static OrderDetails fromJson_OrderDetails(Map<String, dynamic> json) => OrderDetails(
      id: json['id'],
      menuID: json['menuID'],
      quantity: json['quantity']
  );

  static Future createOrderToCart({required String menuID,required String userID,required num quantity}) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(userID);
    final docOrder = docUser.collection('cart').doc();

    final orderObj = OrderDetails(
        id: docOrder.id,
        menuID: menuID,
        quantity: quantity,
        );

    final json = OrderCore.toJson_OrderDetails(orderObj);

    await docOrder.set(json);
  }

  static Stream<List<OrderDetails>> readCart(String userID) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('cart')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => OrderCore.fromJson_OrderDetails(doc.data()))
              .toList()
  );

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

    List<Map> products = [];

    for (int i = 0; i < orders.docs.length; i++) {
      products.add({
        'id': orders.docs[i]['id'],
        'menuID': orders.docs[i]['menuID'],
        'quantity': orders.docs[i]['quantity'],
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
  }

  static Future<List<OrderClass>> readAllCartOrders() async{
    
    QuerySnapshot allCartsQuery = await FirebaseFirestore.instance
      .collection('orders')
      .get();

    List<OrderClass> allCarts = [];

    for(int i = 0; i < allCartsQuery.docs.length; i++){

      List<OrderDetails> orderDetails = [];

      for(int j = 0; j < allCartsQuery.docs[i]['products'].length; j++){

        orderDetails.add(OrderDetails(menuID: allCartsQuery.docs[i]['products'][j]['menuID'], quantity: allCartsQuery.docs[i]['products'][j]['quantity']));
      }

      allCarts.add(OrderClass(state: "In Preparation", uid: allCartsQuery.docs[i]['userID'], cart: orderDetails));
    }

    return allCarts;
  }

  
}