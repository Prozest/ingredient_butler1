import 'package:flutter/material.dart';
import 'package:ingredient_butler/utils/order_class.dart';
import 'package:ingredient_butler/utils/menuItem_class.dart';
import 'package:ingredient_butler/user/user_utils.dart';

import '../utils/order_core.dart';

class ViewOrderState extends StatefulWidget {
  final OrderClass orderClass;
  ViewOrderState(this.orderClass);

  @override
  _ViewOrderState createState() => _ViewOrderState(orderClass);
}

class _ViewOrderState extends State<ViewOrderState> {
  OrderClass orderClass;
  _ViewOrderState(this.orderClass);

  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          automaticallyImplyLeading: false,
          title: Text("Order ${orderClass.id}"),
        ),
        body: FutureBuilder<UserAccount?>(
            future: UserUtils.getUser(orderClass.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Failed to get user ${snapshot.error}');
              } else {
                if (snapshot.hasData) {
                  final userAccount = snapshot.data;

                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Order id: ${orderClass.id}",
                                style: const TextStyle(fontSize: 16)),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text("Username: ${userAccount?.name}",
                                  style: const TextStyle(fontSize: 16)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: orderClass.cart.length,
                                itemBuilder: (context, index) {
                                  return FutureBuilder(
                                      future: MenuItem.readMenuItem(
                                          orderClass.cart[index].menuID),
                                      builder: (context, menuItemSnap) {
                                        if (menuItemSnap.hasError) {
                                          return Text(
                                              'MenuItem not found ${menuItemSnap.error}');
                                        } else {
                                          if (menuItemSnap.hasData) {
                                            final menuItem = menuItemSnap.data;

                                            return orderWidget(
                                                menuItem!.name,
                                                orderClass.cart[index].quantity,
                                                orderClass.id);
                                          } else {
                                            return Container();
                                          }
                                        }
                                      });
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    onPressed: () {},
                                    child: const Text("Finish Order")),
                                ElevatedButton(
                                    onPressed: () {},
                                    child: Text("Cancel Order")),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }
            }),
      );

  Widget orderWidget(String menuName, num quantity, String orderID) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  menuName,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
                Text("qty. $quantity",
                    style: const TextStyle(fontSize: 18, color: Colors.black87))
              ],
            ),
          ],
        ),
      );
}
