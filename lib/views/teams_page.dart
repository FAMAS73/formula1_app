import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formula1_app/models/team.dart';
import 'package:formula1_app/views/team_detail_page.dart';
import 'package:formula1_app/utils/constants.dart';
import 'package:formula1_app/widgets/team_card.dart';

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  Set<String> followedTeams = {};

  @override
  void initState() {
    super.initState();
    fetchFollowedTeams();
  }

  void fetchFollowedTeams() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('Users').doc(user!.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        followedTeams = Set<String>.from(userDoc.get('followedTeams') ?? {});
      });
    }
  }

  Stream<List<Team>> getTeams() {
    return _firestore.collection('Teams').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => Team.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> refreshTeams() async {
    return Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }

  void toggleFollowTeam(String teamId) {
    print('Toggling follow state for team: $teamId'); // Debug print
    setState(() {
      if (followedTeams.contains(teamId)) {
        followedTeams.remove(teamId);
        print('Unfollowing team'); // Debug print
      } else {
        followedTeams.add(teamId);
        print('Following team'); // Debug print
      }
    });
    updateFollowStatusInFirestore(teamId);
  }

  void updateFollowStatusInFirestore(String teamId) {
    if (followedTeams.contains(teamId)) {
      _firestore
          .collection('Users')
          .doc(user!.uid)
          .update({
            'followedTeams': FieldValue.arrayUnion([teamId])
          })
          .then((value) => print("Team followed in Firestore"))
          .catchError((error) => print("Failed to follow team: $error"));
    } else {
      _firestore
          .collection('Users')
          .doc(user!.uid)
          .update({
            'followedTeams': FieldValue.arrayRemove([teamId])
          })
          .then((value) => print("Team unfollowed in Firestore"))
          .catchError((error) => print("Failed to unfollow team: $error"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('F1 Teams',
            style: TextStyle(
                color: Colors
                    .white)), // Ensure text color contrasts well with the AppBar color
        backgroundColor: AppColors.primaryColor,
      ),
      body: StreamBuilder<List<Team>>(
        stream: getTeams(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: refreshTeams,
            color: AppColors.primaryColor,
            child: ListView(
              children: snapshot.data!.map((team) {
                return TeamCard(
                  team: team,
                  isFollowed: followedTeams.contains(team.id),
                  onFollowTap: () => toggleFollowTeam(team.id),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
