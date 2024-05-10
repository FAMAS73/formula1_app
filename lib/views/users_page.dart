import 'package:flutter/material.dart';
import 'package:formula1_app/models/app_user.dart';
import 'package:formula1_app/services/firestore_service.dart';
import 'package:formula1_app/utils/constants.dart';
import 'package:formula1_app/views/user_info_section.dart';
import 'package:formula1_app/views/followed_section.dart';
import 'package:formula1_app/views/profile_actions.dart';
import 'package:formula1_app/views/admin_actions.dart'; // Placeholder for admin actions

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile",
            style: TextStyle(color: AppColors.primaryTextColor)),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
              icon: Icon(Icons.refresh, color: AppColors.accentColor),
              onPressed: () => setState(() {})),
        ],
      ),
      body: StreamBuilder<AppUser?>(
        stream: _firestoreService.getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error}",
                    style: TextStyle(color: AppColors.errorColor)));
          }
          if (!snapshot.hasData) {
            return Center(
                child: Text("No user data available",
                    style: TextStyle(color: AppColors.secondaryTextColor)));
          }
          AppUser? user = snapshot.data;
          bool isAdmin = user!.role ==
              'admin'; // Dynamically check if the user is an admin

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                UserInfoSection(user: user),
                Divider(color: AppColors.dividerColor),
                FollowedSection(
                    title: "Followed Teams",
                    items: user.followedTeams,
                    collectionPath: "Teams"),
                FollowedSection(
                    title: "Followed Drivers",
                    items: user.followedDrivers,
                    collectionPath: "Drivers"),
                ProfileActions(firestoreService: _firestoreService),
                if (isAdmin)
                  AdminActions(), // Display admin actions if the user is an admin
              ],
            ),
          );
        },
      ),
    );
  }
}

