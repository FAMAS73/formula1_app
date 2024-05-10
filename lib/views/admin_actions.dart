import 'package:flutter/material.dart';
import 'package:formula1_app/views/manage_teams_page.dart';
import 'package:formula1_app/views/manage_drivers_page.dart';
import 'package:formula1_app/views/manage_news_page.dart';

class AdminActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text("Manage Teams"),
          leading: Icon(Icons.group),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ManageTeamsPage(),
            ));
          },
        ),
        ListTile(
          title: Text("Manage Drivers"),
          leading: Icon(Icons.person),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ManageDriversPage(),
            ));
          },
        ),
        ListTile(
          title: Text('Manage News'),
          leading: Icon(Icons.image),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ManageNewsPage(),
            ));
          },
        ),
      ],
    );
  }
}
