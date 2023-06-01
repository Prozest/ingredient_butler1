import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  
  String commentText;
  String username;

  Comment({required this.commentText, required this.username});

  Map<String, dynamic> toJson()=>{
    'text': commentText,
    'username': username
  };

  static Comment fromJson(Map<String, dynamic> json) =>
      Comment(commentText: json['text'], username: json['username']);

  static Future createComment({required String text, required String username, required String menuID}) async {
    final docMenuItem =
        FirebaseFirestore.instance.collection('menuitems').doc(menuID);

    final docComment=docMenuItem.collection('comments');

    final commentObj = Comment(
      commentText: text,
      username: username
    );

    final json = commentObj.toJson();

    await docComment.add(json);
  }

  static Stream<List<Comment>> readComments(String menuID) => FirebaseFirestore.instance
      .collection('menuitems').doc(menuID).collection('comments')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Comment.fromJson(doc.data())).toList());
}
