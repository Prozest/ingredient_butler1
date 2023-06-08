import 'package:flutter/material.dart';
import 'package:ingredient_butler/admin/admin_view_menu_item.dart';
import 'package:ingredient_butler/admin/create_item_page.dart';
import 'package:ingredient_butler/admin/admin_order_details.dart';
import 'package:ingredient_butler/user/home_page.dart';
import 'package:ingredient_butler/user/user_utils.dart';
import 'package:ingredient_butler/utils/menuItem_class.dart';
import 'package:ingredient_butler/utils/order_class.dart';
import 'package:ingredient_butler/utils/order_core.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[];

  _AdminPageState() {
    const TextStyle optionStyle =
        TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    _widgetOptions = <Widget>[
      menuItemPage(), //Page 1
      orderPage(), //Page 2
      CreateItemPage() //Page 4
    ];
  }

  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Ingredient Butler'),
          backgroundColor: const Color.fromARGB(255, 38, 45, 146),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                  child: const Icon(Icons.account_box_outlined),
                ))
          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Menu Items',
              backgroundColor: Colors.red,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Orders',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              label: 'New Item',
              backgroundColor: Colors.pink,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget menuItemPage() => ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 15, right: 10),
            child: StreamBuilder<List<MenuItem>>(
                stream: MenuItem.readMenuItems(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Data not found ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final menuItems = snapshot.data!;

                    return Column(
                        children: menuItems.map(buildAdminMenuItem).toList());
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
        ],
      );

  Widget buildAdminMenuItem(MenuItem menuItem) => Padding(
        padding: const EdgeInsets.only(right: 8, left: 8, bottom: 7),
        child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AdminViewMenuState(menuItem.id, menuItem.name)));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.blue,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                )),
            child: ListTile(
              title: Text(menuItem.name),
              subtitle: Text(menuItem.cost.toString()),
            )),
      );

  Widget orderPage() => ListView(
    shrinkWrap: true,
    children: [
      FutureBuilder<List<OrderClass>>(
          future: OrderCore.readAllCartOrders(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Data not found ${snapshot.error}');
            } else if (snapshot.hasData) {
              final orders = snapshot.data!;

              return Padding(
                padding:
                    const EdgeInsets.only(top: 0, left: 0, right: 0),
                child: Column(
                    children: orders.map(buildOrderWidget).toList()),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    ],
  );

  Widget buildOrderWidget(OrderClass orderClass) {
    return FutureBuilder<UserAccount?>(
        future: UserUtils.getUser(orderClass.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Failed to get user ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            final userAccount = snapshot.data;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewOrderState(orderClass)));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white60,
                    foregroundColor: const Color.fromARGB(255, 109, 109, 109)),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderClass.id,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text('By ${userAccount!.name}')
                              ],
                            ),
                            orderState(orderClass.state),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
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
                                          'Data not found ${menuItemSnap.error}');
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
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }

  Widget orderWidget(String menuName, num quantity, String orderID) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    menuName,
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                  Text("qty. $quantity",
                      style:
                          const TextStyle(fontSize: 20, color: Colors.black87))
                ],
              ),
            ],
          ),
        ),
      );

  Widget orderState(String state) {
    return Container(
      height: 30,
      width: 100,
      color: Colors.transparent,
      child: Container(
          decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: const Center(
            child: Text(
              "Processing",
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          )),
    );
  }
}
