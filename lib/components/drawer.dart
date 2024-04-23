import 'package:flutter/material.dart';
import 'package:thewall/components/my_list_tile.dart';
import 'package:thewall/pages/people_for_chat.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTab;
  final void Function()? OnSignOut;
  final void Function()? onChatTab;
  const MyDrawer({
    super.key,
    this.onProfileTab,
    this.OnSignOut,
    this.onChatTab,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //заглавие
          Column(
            children: [
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              //home list tile
              MyListTile(
                icon: Icons.home,
                text: 'Н А Ч А Л О',
                onTap: () => Navigator.pop(context),
              ),
              MyListTile(
                icon: Icons.chat,
                text: 'Ч А Т',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PeopleCh()),
                ),
              ),

              //profile list tile
              MyListTile(
                icon: Icons.person,
                text: 'П Р О Ф И Л',
                onTap: onProfileTab,
              ),
            ],
          ),

          //logout list tile
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout,
              text: "И З Л И З А Н Е ",
              onTap: OnSignOut,
            ),
          ),
        ],
      ),
    );
  }
}
