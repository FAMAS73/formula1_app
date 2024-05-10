import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String name;
  final String story;
  final String imageUrl;
  

    Team(
      {required this.id,
      required this.name,
      required this.story,
      required this.imageUrl});


  factory Team.fromMap(Map<String, dynamic> map, String id) {
    return Team(
      id: id,
      name: map['name'] ?? 'No name provided',
      story: map['story'] ?? 'No story available',
      imageUrl: map['image_url'] ?? 'https://via.placeholder.com/150',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'story': story,
      'image_url': imageUrl,
    };
  }

  Future<void> toggleFollow(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    final doc = await userRef.get();
    if (doc.exists) {
      List<dynamic> followedTeams = doc.data()?['followedTeams'] ?? [];
      if (followedTeams.contains(id)) {
        followedTeams.remove(id);
      } else {
        followedTeams.add(id);
      }
      return userRef.update({'followedTeams': followedTeams});
    }
  }
}
