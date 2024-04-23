import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thewall/components/text_box.dart'; // Импорт на компонента за текстови полета
import 'package:thewall/pages/chat_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  final userPostsCollection =
      FirebaseFirestore.instance.collection("User Posts");
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Функция за редактиране на полето
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Смяна на $field", // Показване на името на полето, което се редактира
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText:
                "Моля добавете ново $field", // Подсказка за въвеждане на нова стойност
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: Text(
              'Отказ',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Запазване',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              if (newValue.trim().length > 0) {
                await usersCollection
                    .doc(currentUser.uid)
                    .update({field: newValue});
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Функция за изтриване на пост
  Future<void> deletePost(String postId) async {
    await userPostsCollection.doc(postId).delete();
    setState(() {}); // Презарежда UI след изтриване на поста
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          "Профилна страница",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.data == null || !snapshot.data!.exists) {
            return const Center(
              child:
                  Text('Грешка: Не са намерени данни за текущия потребител.'),
            );
          } else {
            final userData = snapshot.data!.data()! as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(height: 50),
                Icon(
                  Icons.person,
                  size: 72,
                ),
                const SizedBox(height: 10),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    "Моите Детайли",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                MyTextBox(
                  text: userData['username'] ??
                      '', // Показване на потребителското име
                  sectionName: 'username',
                  onPressed: () => editField(
                      'username'), // Позволява редактиране на потребителското име
                ),
                MyTextBox(
                  text: userData['bio'] ??
                      '', // Показване на биографията на потребителя
                  sectionName: 'bio',
                  onPressed: () =>
                      editField('bio'), // Позволява редактиране на биографията
                ),
                const SizedBox(height: 20),
                FutureBuilder<QuerySnapshot>(
                  future: userPostsCollection
                      .where('UserEmail', isEqualTo: currentUser.email)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      final List<DocumentSnapshot> userPosts =
                          snapshot.data!.docs;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Text(
                              'Постове на потребителя:', // Показване на заглавие за постовете на потребителя
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: userPosts.length,
                            itemBuilder: (context, index) {
                              final post = userPosts[index].data()
                                  as Map<String, dynamic>;
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                child: ListTile(
                                  title: Text(
                                    'Съдържание: ${post['Message']}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Потвърждение'),
                                          content: Text(
                                              'Сигурни ли сте, че искате да изтриете този пост?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Отказ'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deletePost(userPosts[index].id);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Изтрий'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  subtitle: FutureBuilder<QuerySnapshot>(
                                    future: userPostsCollection
                                        .doc(userPosts[index].id)
                                        .collection('Comments')
                                        .get(),
                                    builder: (context, commentSnapshot) {
                                      if (commentSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (commentSnapshot.hasError) {
                                        return Text(
                                            'Error: ${commentSnapshot.error}');
                                      } else {
                                        final List<DocumentSnapshot> comments =
                                            commentSnapshot.data!.docs;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Коментари:', // Показване на заглавие за коментарите към поста
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: comments.map((comment) {
                                                return Text(
                                                  '${comment['CommentedBy']}: ${comment['CommentText']}',
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
