import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ingredient_butler/utils/menuItem_class.dart';
import 'package:ingredient_butler/utils/comment_class.dart';
import 'package:ingredient_butler/utils/order_class.dart';
import 'package:ingredient_butler/user/user_utils.dart';

class ViewMenuState extends StatefulWidget {
  final String id;
  final String name;
  ViewMenuState(this.id, this.name);

  @override
  _ViewMenuState createState() => _ViewMenuState(id, name);
}

class _ViewMenuState extends State<ViewMenuState> {
  final String id;
  final String name;

  final quantityController = TextEditingController();
  final commentController = TextEditingController();

  _ViewMenuState(this.id, this.name);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        automaticallyImplyLeading: false,
        title: Text(name),
      ),
      body: FutureBuilder<UserAccount?>(
        future: UserUtils.readUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data;

            if (user!.admin == true) {
              return FutureBuilder<MenuItem?>(
                future: MenuItem.readMenuItem(id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final menuItem = snapshot.data;

                    return menuItem == null
                        ? const Center(child: Text("Could not get data"))
                        : ListView(
                            children: [
                              Text(menuItem.name),
                              Text(menuItem.cost.toString()),
                              FractionallySizedBox(
                                  widthFactor: 0.3,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        openDialog();
                                      },
                                      child: const Text(
                                        "ORDER",
                                        style: TextStyle(
                                            fontSize: 16, letterSpacing: 1),
                                      ))),
                              showComments(),
                              TextField(
                                maxLines: 5,
                                minLines: 1,
                                controller: commentController,
                                decoration: const InputDecoration(
                                  labelText: 'Write a comment!',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: 110,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Comment.createComment(
                                          text: commentController.text,
                                          menuID: id,
                                          username: user.name,
                                        );
                                      },
                                      child: const Text("COMMENT")),
                                ),
                              ),
                            ],
                          );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              );
            }
          }
          return const SizedBox(
            width: 0,
          );
        },
      ));

  Widget buildComment(Comment comment) => Padding(
        padding: const EdgeInsets.only(right: 1, left: 1),
        child: ListTile(
          title: Text(comment.username),
          subtitle: Text(comment.commentText),
        ),
      );

  Widget showComments() => StreamBuilder<List<Comment>>(
      stream: Comment.readComments(id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Data not found ${snapshot.error}');
        } else if (snapshot.hasData) {
          final comments = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 18),
                ),
                Column(children: comments.map(buildComment).toList()),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      });

  Future openDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Select Quantity"),
            content: TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                  hintText: 'How many servings are you ordering?'),
            ),
            actions: [
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel")),
                  TextButton(onPressed: () {
                    OrderClass.createOrderToCart(
                      menuID: id,
                      userID: FirebaseAuth.instance.currentUser!.uid,
                      quantity: int.parse(quantityController.text)
                    );
                    Navigator.pop(context);
                  }, child: const Text("Finish Order")),
                ],
              ),
            ],
          ));
}
