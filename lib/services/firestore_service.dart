import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formula1_app/models/team.dart';
import 'package:formula1_app/models/driver.dart';
import 'package:formula1_app/models/news.dart';
import 'package:formula1_app/models/app_user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Teams
  Stream<List<Team>> getTeams() {
    return _db.collection('Teams').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Team.fromMap(doc.data(), doc.id)).toList());
  }

  Future<Map<String, Team>> fetchTeams() async {
    var snapshot = await _db.collection('Teams').get();
    return Map.fromIterable(
      snapshot.docs,
      key: (doc) => doc.id,
      value: (doc) => Team.fromMap(doc.data() as Map<String, dynamic>, doc.id),
    );
  }

  Future<void> addTeam(Team team) {
    return _db.collection('Teams').add(team.toMap());
  }

  Future<void> updateTeam(Team team) {
    return _db.collection('Teams').doc(team.id).update(team.toMap());
  }

  Future<void> deleteTeam(String id) {
    return _db.collection('Teams').doc(id).delete();
  }

  // Drivers
  Stream<List<Driver>> getDrivers() async* {
    Map<String, Team> teams = await fetchTeams(); // Fetch teams first
    yield* _db
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

  Future<void> addDriver(Driver driver) {
    return _db.collection('Drivers').add(driver.toMap());
  }

  Future<void> updateDriver(Driver driver) {
    return _db.collection('Drivers').doc(driver.id).update(driver.toMap());
  }

  Future<void> deleteDriver(String id) {
    return _db.collection('Drivers').doc(id).delete();
  }

  // News
  Stream<List<News>> getNews() {
    return _db
        .collection('News')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => News.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addNews(News news) {
    return _db.collection('News').add(news.toMap());
  }

  Future<void> updateNews(News news) {
    return _db.collection('News').doc(news.id).update(news.toMap());
  }

  Future<void> deleteNews(String id) {
    return _db.collection('News').doc(id).delete();
  }

  // Users
  Stream<AppUser?> getUser() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _db
          .collection('Users')
          .doc(currentUser.uid)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return AppUser.fromFirestore(snapshot.data()!, snapshot.id);
        } else {
          throw Exception('User not found');
        }
      });
    } else {
      return Stream.value(null); // Return null when no user is logged in
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteUser() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await _db.collection('Users').doc(userId).delete();
  }
}
