
class OrderClass {
  String id;
  String state;
  String uid;
  List<OrderDetails> cart = [];

  OrderClass({
    this.id = '',
    required this.state,
    required this.uid,
    required this.cart
  });
}

class OrderDetails {
  String id;
  String menuID;
  num quantity;

  OrderDetails(
      {this.id = '',
      required this.menuID,
      required this.quantity,});
}
