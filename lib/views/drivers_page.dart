import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formula1_app/models/driver.dart';
import 'package:formula1_app/models/team.dart';

class DriversPage extends StatefulWidget {
  @override
  _DriversPageState createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  Set<String> followedDrivers = {};

  @override
  void initState() {
    super.initState();
    fetchFollowedDrivers();
  }

  void fetchFollowedDrivers() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('Users').doc(user!.uid).get();
    if (userDoc.exists &&
        (userDoc.data() as Map<String, dynamic>)
            .containsKey('followedDrivers')) {
      setState(() {
        followedDrivers = Set<String>.from(userDoc.get('followedDrivers'));
      });
    }
  }

  Stream<List<Driver>> getDrivers() async* {
    Map<dynamic, Team> teams = await fetchTeams(); // Fetch teams first
    yield* _firestore
        .collection('Drivers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              var driverId = doc.id;
              var team = teams[data[
                  'teamId']]; // Get the team based on teamId stored in driver data
              return Driver.fromMap(
                  data, driverId, team); // Pass the team object
            }).toList());
  }


  void toggleFollowDriver(String driverId) {
    setState(() {
      if (followedDrivers.contains(driverId)) {
        followedDrivers.remove(driverId);
        _firestore.collection('Users').doc(user!.uid).update({
          'followedDrivers': FieldValue.arrayRemove([driverId])
        });
      } else {
        followedDrivers.add(driverId);
        _firestore.collection('Users').doc(user!.uid).update({
          'followedDrivers': FieldValue.arrayUnion([driverId])
        });
      }
    });
  }

  Future<Map<dynamic, Team>> fetchTeams() async {
    var snapshot = await FirebaseFirestore.instance.collection('Teams').get();
    var teams = Map.fromIterable(
      snapshot.docs,
      key: (doc) => doc.id, // Use the document ID as the key
      value: (doc) => Team.fromMap(doc.data() as Map<String, dynamic>, doc.id),
    );
    return teams;
  }



  Stream<List<Driver>> getDriversWithTeams() async* {
    Map<dynamic, Team> teams = await fetchTeams();
    yield* FirebaseFirestore.instance
        .collection('Drivers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              var team = teams[data['teamId']];
              if (team == null) {
                print(
                    "Warning: No team found for teamId ${data['teamId']} for driver ${data['name']}");
              }
              return Driver.fromMap(data, doc.id, team);
            }).toList());
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('F1 Drivers'),
      ),
      body: StreamBuilder<List<Driver>>(
        stream: getDriversWithTeams(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Driver driver = snapshot.data![index];
              bool isFollowed = followedDrivers.contains(driver.id);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        driver.team?.imageUrl ?? 'path/to/default/image.jpg'),
                  ),
                  title: Text(driver.name),
                  subtitle: Text(
                      "${driver.bio}\nTeam: ${driver.team?.name ?? 'No Team'}"),
                  trailing: IconButton(
                    icon: Icon(isFollowed ? Icons.star : Icons.star_border),
                    onPressed: () => toggleFollowDriver(driver.id),
                  ),
                ),
              );
            },
          );




        },
      ),
    );
  }
}
