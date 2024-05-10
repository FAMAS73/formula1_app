import 'package:formula1_app/models/team.dart';
class Driver {
  final String id;
  final String name;
  final String bio;
  final String imageUrl;
  final String teamId;
  Team? team; 
    Driver(
      {required this.id,
      required this.name,
      required this.bio,
      required this.imageUrl,
      required this.teamId,
      this.team
      }
      );


  factory Driver.fromMap(Map<String, dynamic> map, String id,Team? team) {
    return Driver(
      id: id,
      name: map['name'] as String? ?? 'Unknown Name',
      bio: map['bio'] as String? ?? 'No biography available',
      imageUrl: map['image_url'] as String? ??
          'No image',
      teamId: map['teamId'] as String? ?? 'No team',
       team: team,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'image_url': imageUrl,
      'teamId': teamId,

    };
  }
}
