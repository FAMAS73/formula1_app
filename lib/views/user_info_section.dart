import 'package:flutter/material.dart';
import 'package:formula1_app/models/app_user.dart';

class UserInfoSection extends StatelessWidget {
  final AppUser user;

  UserInfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text("Email"),
        subtitle: Text(user.email),
        leading: Icon(Icons.email),
      ),
    );
  }
}
