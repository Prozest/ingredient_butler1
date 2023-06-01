import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ingredient_butler/admin/admin_page.dart';
import 'package:ingredient_butler/utils/menuItem_class.dart';
import 'package:ingredient_butler/utils/order_class.dart';
import 'package:ingredient_butler/user/user_utils.dart';
import 'package:ingredient_butler/user/view_menu_item.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAdmin = false;
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[];

  _HomePageState() {
    _widgetOptions = <Widget>[menuItemPage(), cartPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ingredient Butler'),
        actions: <Widget>[
          FutureBuilder<UserAccount?>(
            future: UserUtils.readUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final user = snapshot.data;

                if (user!.admin == true) {
                  return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminPage()));
                        },
                        child: const Icon(Icons.admin_panel_settings),
                      ));
                }
              }
              return const SizedBox(
                width: 0,
              );
            },
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.logout_outlined),
          onPressed: () => FirebaseAuth.instance.signOut(),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Cart',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget menuItemPage() => ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 15, right: 10),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              StreamBuilder<List<MenuItem>>(
                  stream: MenuItem.readMenuItems(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Data not found ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final menuItems = snapshot.data!;

                      return Column(
                          children: menuItems.map(buildMenuItem).toList());
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ]),
          ),
        ],
      );

  Widget buildMenuItem(MenuItem menuItem) => Padding(
        padding: const EdgeInsets.only(right: 8, left: 8, bottom: 7),
        child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewMenuState(menuItem.id, menuItem.name)));
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

  Widget cartPage() {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      body: ListView(
        children: [
          StreamBuilder<List<OrderClass>>(
              stream: OrderClass.readCartOrders(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Data not found ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final orders = snapshot.data!;

                  return Column(
                      children: orders.map(buildOrderWidget).toList());
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {OrderClass.finishCart(user.uid);}, 
        label: const Text("Order Cart"),
        icon: const Icon(Icons.shopping_cart),),
    );
  }

  Widget buildOrderWidget(OrderClass orderClass) => FutureBuilder<MenuItem?>(
      future: MenuItem.readMenuItem(orderClass.menuID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Data not found ${snapshot.error}');
        } else {
          if (snapshot.hasData) {
            final menuItem = snapshot.data;

            return orderWidget(menuItem!.name, orderClass.id, orderClass.userID,
                orderClass.quantity);
          } else {
            return Container();
          }
        }
      });

  Widget orderWidget(
          String menuName, String cartId, String uid, num quantity) =>
      Row(children: [
        SizedBox(width: 300, child: Text(menuName)),
        Text(quantity.toString()),
        ElevatedButton(
          onPressed: () {
            OrderClass.deleteCartOrder(cartId: cartId, uid: uid);
          },
          style: ElevatedButton.styleFrom(shape: const CircleBorder()),
          child: const Icon(
            Icons.close_sharp,
            color: Colors.white,
            size: 16,
          ),
        )
      ]);
}