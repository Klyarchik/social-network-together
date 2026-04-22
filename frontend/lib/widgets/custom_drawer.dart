import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        // margin: EdgeInsets.only(left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            InkWell(
              onTap: index != 0
                  ? () {
                      Navigator.pushNamed(context, '/profile');
                    }
                  : null,
              child: Row(
                children: [
                  SizedBox(width: 20,),
                  Icon(
                    Icons.person,
                    color: index == 0
                        ? Color.fromRGBO(240, 210, 71, 1)
                        : Colors.black26,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Профиль',
                    style: TextStyle(
                      color: index == 0
                          ? Color.fromRGBO(240, 210, 71, 1)
                          : Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: index == 1
                  ? null
                  : () {
                      Navigator.pushNamed(context, '/chats');
                    },
              child: Row(
                children: [
                  SizedBox(width: 20,),
                  Icon(
                    Icons.chat_bubble,
                    color: index == 1
                        ? Color.fromRGBO(240, 210, 71, 1)
                        : Colors.black26,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Чаты',
                    style: TextStyle(
                      color: index == 1
                          ? Color.fromRGBO(240, 210, 71, 1)
                          : Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
