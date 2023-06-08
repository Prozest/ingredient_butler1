import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ingredient_butler/admin/admin_update_item.dart';
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
                  : menuItemDetailsPage(menuItem: menuItem, id: id);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );
}

class menuItemDetailsPage extends StatelessWidget {
  menuItemDetailsPage({
    super.key,
    required this.menuItem,
    required this.id,
  });

  final MenuItem menuItem;
  final String id;

  final addStockController = TextEditingController();
  final removeStockController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 14, right: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                menuItem.name,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                menuItem.cost.toString(),
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Quantity in stock:",
                style: TextStyle(fontSize: 18),
              ),
              Row(
                children: [
                  Text(
                    '${menuItem.stock}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  addStockButton(context),
                  const SizedBox(
                    width: 6,
                  ),
                  removeQuantityButton(context),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              updateButton(context),
              const SizedBox(
                width: 20,
              ),
              deleteButton(context)
            ]),
          )
        ],
      ),
    );
  }

  Widget addStockButton(BuildContext context) {
    return CircleAvatar(
        backgroundColor: Colors.blue,
        radius: 20,
        child: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Add to stock"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Currently in stock: ${menuItem.stock}"),
                          TextField(
                            controller: addStockController,
                            decoration: const InputDecoration(
                                hintText: 'How much are you adding?'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              MenuItem.addRemoveStock(
                                  id, int.parse(addStockController.text));
                              Navigator.of(context).pop();
                            },
                            child: const Text("Add")),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel")),
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.add)));
  }

  Widget removeQuantityButton(BuildContext context) {
    return CircleAvatar(
        backgroundColor: Colors.blue,
        radius: 20,
        child: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Remove from stock"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Currently in stock: ${menuItem.stock}"),
                          TextField(
                            controller: removeStockController,
                            decoration: const InputDecoration(
                                hintText: 'How much are you removing?'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              MenuItem.addRemoveStock(
                                  id, -int.parse(removeStockController.text));
                              Navigator.of(context).pop();
                            },
                            child: const Text("Remove")),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel")),
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.remove)));
  }

  Widget updateButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminUpdateItemState(menuItem.id)));
        },
        child: const Text("Update"));
  }

  Widget deleteButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Delete?"),
                content: const Text(
                    "Are you sure you want to delete this menu item?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        MenuItem.deleteMenuItem(id: id);
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminPage()));
                      },
                      child: const Text("Yes")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("No")),
                ],
              );
            });
      },
      child: const Text("Delete"),
    );
  }
}
