import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:formula1_app/models/team.dart';
import 'package:formula1_app/models/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formula1_app/utils/constants.dart';
import 'package:favorite_button/favorite_button.dart';

class TeamDetailPage extends StatefulWidget {
  final Team team;

  TeamDetailPage({required this.team});

  @override
  _TeamDetailPageState createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  Set<String> followedDrivers = {};

  @override
  void initState() {
    super.initState();
    fetchFollowedDrivers();
  }

  void fetchFollowedDrivers() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          var data = doc.data();
          if (data != null && data.containsKey('followedDrivers')) {
            setState(() {
              followedDrivers = Set<String>.from(data['followedDrivers']);
            });
          }
        }
      });
    }
  }

  void toggleFollowDriver(String driverId) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        if (followedDrivers.contains(driverId)) {
          followedDrivers.remove(driverId);
          FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
            'followedDrivers': FieldValue.arrayRemove([driverId])
          });
        } else {
          followedDrivers.add(driverId);
          FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
            'followedDrivers': FieldValue.arrayUnion([driverId])
          });
        }
      });
    }
  }

  Stream<List<Driver>> getDrivers(String teamId) async* {
    DocumentSnapshot teamSnapshot =
        await FirebaseFirestore.instance.collection('Teams').doc(teamId).get();
    Team? team = teamSnapshot.exists
        ? Team.fromMap(
            teamSnapshot.data() as Map<String, dynamic>, teamSnapshot.id)
        : null;

    yield* FirebaseFirestore.instance
        .collection('Drivers')
        .where('team_id', isEqualTo: teamId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Driver.fromMap(doc.data() as Map<String, dynamic>,
                doc.id, team)) // Now passing the team object
            .toList());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.name, style: AppStyles.headingStyle),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Image.network(widget.team.imageUrl),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.team.story, style: AppStyles.textStyle),
          ),
          Expanded(
            child: StreamBuilder<List<Driver>>(
              stream: getDrivers(widget.team.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text("Error: ${snapshot.error}");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Driver driver = snapshot.data![index];
                    bool isFollowed = followedDrivers.contains(driver.id);
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Image.network(driver.imageUrl,
                                width: 50, height: 50),
                            title: Text(driver.name),
                            subtitle: Text(driver.bio),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FavoriteButton(
                                isFavorite: isFollowed,
                                valueChanged: (_isFavorite) {
                                  toggleFollowDriver(driver.id);
                                },
                                iconSize: 40.0,
                                iconColor: Colors.yellow,
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
