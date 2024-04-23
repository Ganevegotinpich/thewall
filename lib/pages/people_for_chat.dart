import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thewall/components/text_box.dart';
import 'package:thewall/pages/chat_page.dart';

class PeopleCh extends StatefulWidget {
  const PeopleCh({Key? key}) : super(key: key);

  @override
  _PeopleChState createState() => _PeopleChState();
}

class _PeopleChState extends State<PeopleCh> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController usernameController =
      TextEditingController(); // Контролер за потребителското име
  TextEditingController bioController =
      TextEditingController(); // Контролер за биото
  TextEditingController searchController =
      TextEditingController(); // Контролер за търсачката

  // Списък за проследяване на непрочетените съобщения за всяка отделна конверсация
  List<String> unreadMessages = [];

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Търсене на имейл',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    'Грешка: Не може да се заредят данни за потребителите.',
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  // Филтрирай потребителите според търсения имейл
                  List<DocumentSnapshot> filteredUsers =
                      snapshot.data!.docs.where((user) {
                    String email = user['email'] ?? '';
                    return email
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      return _buildUserListItem(filteredUsers[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    if (data != null && _auth.currentUser!.email != data['email']) {
      final bool hasUnreadMessages = unreadMessages.contains(data['uid']);

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                // Провери дали има данни и полетата не са null
                if (data != null &&
                    data['uid'] != null &&
                    data['username'] != null) {
                  return ChatPage(
                    recieverUserId: data['uid'],
                    recieverUserEmail: data['username'],
                  );
                } else {
                  // Ако данните са null или липсва някое поле, покажи съобщение за грешка
                  return Scaffold(
                    body: Center(
                      child: Text(
                        'Грешка: Данните за потребителя са непълни или липсват.',
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasUnreadMessages ? Colors.blue[50] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.grey),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  data['email'] ?? '',
                  style: TextStyle(
                    color: hasUnreadMessages ? Colors.blue : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
