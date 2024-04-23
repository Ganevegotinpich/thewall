import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comment(
      {super.key, required this.text, required this.user, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 248, 242, 242),
          borderRadius: BorderRadius.circular(4),
        ),
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //comment
            Text(text),
            const SizedBox(height: 5),
            //user and time
            Row(
              children: [
                Text(user),
                Text("."),
                Text(time),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ));
  }
}
