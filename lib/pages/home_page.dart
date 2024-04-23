import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thewall/components/drawer.dart';
import 'package:thewall/components/my_textfield.dart';
import 'package:thewall/components/wall_post.dart';
import 'package:thewall/helper/helper_methods.dart';
import 'package:thewall/pages/profile_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final textController = TextEditingController();

  void singOut() {
    FirebaseAuth.instance.signOut();
  }

  void PostMessage() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
        'Comments': [],
      });
    }

    setState(() {
      textController.clear();
    });
  }

  //Изпращане в профилната страница
  void goToProfilePage() {
    //попва меню drawer-a
    Navigator.pop(context);
    //изпраща в профилната страница
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const Text(
            "Социална мрежа A&G",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: MyDrawer(
          onProfileTab: goToProfilePage,
          OnSignOut: singOut,
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .orderBy(
                        "TimeStamp",
                        descending: false,
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final post = snapshot.data!.docs[index];
                          return WallPost(
                            message: post['Message'],
                            user: post['UserEmail'],
                            postId: post.id,
                            likes: List<String>.from(post['Likes'] ?? []),
                            time: formatData(post["TimeStamp"]),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: + ${snapshot.error}'),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              //Стената за писане
              //Съобщения
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  children: [
                    Expanded(
                        child: MyTextField(
                      controller: textController,
                      hintText: "Напиши нещо тук",
                      obscureText: false,
                    )),
                    IconButton(
                        onPressed: PostMessage,
                        icon: const Icon(Icons.arrow_circle_up))
                  ],
                ),
              ),
              Text(
                "Регистриран като: " + currentUser.email!,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ));
  }
}
