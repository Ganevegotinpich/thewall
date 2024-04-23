import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thewall/components/comment.dart';
import 'package:thewall/components/comment_button.dart';
import 'package:thewall/components/delete_button.dart';
import 'package:thewall/components/like_button.dart';
import 'package:thewall/helper/helper_methods.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  //потребител
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  late Future<int> commentCount;
  final _commentTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
    commentCount = getCommentCount(widget.postId);
  }
  //Добавяне на коментар

  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  Future<int> getCommentCount(String postId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("User Posts")
        .doc(postId)
        .collection("Comments")
        .get();

    return querySnapshot.size;
  }

  //Показване на диалогов прозорец за коментари
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Добавете коментар"),
        content: TextField(
          controller: _commentTextController,
          decoration: InputDecoration(hintText: "Добавете коментар.."),
        ),
        actions: [
          //бутон за запазване
          TextButton(
              onPressed: () {
                addComment(_commentTextController.text);
                //изчистване на текста
                _commentTextController.clear();
                //pop box
                Navigator.pop(context);
              },
              child: Text("Качване")),

          //бутон за отказ
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                //изчистване на текста
                _commentTextController.clear();
              },
              child: Text("Отказ")),
        ],
      ),
    );
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    //Достъпваме документ Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
    if (isLiked) {
      //Ако е харесан поста добавяме имейла в полето харесани
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      //Ако не го отхаресаме, го премахваме от полето харесани
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

//метод за изтриване
  void deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Изтриване на поста"),
        content:
            const Text("Сигурен ли сте, че искате да изтриете публикацията?"),
        actions: [
//CANCEL BUTTON
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отказ"),
          ),

//DELETE BUTTON
          TextButton(
            onPressed: () async {
              //Изтриване на коментарите от firestor-а първо
              final commentDocs = await FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();
              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }
              //Изтриване на публикациите
              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("Публикацията е изтрита"))
                  .catchError(
                      (error) => print("Изтриването е неуспешно:$error"));

              //Dismiss the dialog
              Navigator.pop(context);
            },
            child: const Text("Изтриване"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        //постове на стената
        children: [
          //постове
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //съобщения и имейли
              Column(
                children: [
                  Row(
                    children: [
                      Text(widget.user),
                      Text("."),
                      Text(widget.time),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              //бутон за изтриване
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletePost),
            ],
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: HighlightView(
              widget.message,
              language: 'dart',
              theme: githubTheme,
            ),
          ),

          const SizedBox(width: 20),
          //buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //за харесване
              Column(
                children: [
                  LikeButton(isLiked: isLiked, onTap: toggleLike),
                  const SizedBox(
                    height: 5,
                  ),
                  //брояч на харесвания
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              //За коментари
              Column(
                children: [
                  CommentButton(onTap: showCommentDialog),
                  const SizedBox(
                    height: 5,
                  ),
                  FutureBuilder<int>(
                    future: commentCount,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        int comments = snapshot.data ?? 0;
                        return Text(
                          ' $comments',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 15),

          //Визуализиране на коментарите
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                shrinkWrap: true, //for nested lists
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  //Взимаме коментарите от БД
                  final commentData = doc.data() as Map<String, dynamic>;

                  //И ги визуализираме като ги връщаме
                  return Comment(
                    text: commentData["CommentText"],
                    user: commentData["CommentedBy"],
                    time: formatData(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
