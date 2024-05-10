import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
class News {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final List<String> relatedTeams;
  final List<String> relatedDrivers;
  final String imageUrl;
  final int viewsCount;
  final int likesCount;
  final int sharesCount;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.relatedTeams,
    required this.relatedDrivers,
    required this.imageUrl,
    required this.viewsCount,
    required this.likesCount,
    required this.sharesCount,
  });

  factory News.fromMap(Map<String, dynamic> map, String id) {
    return News(
      id: id,
      title: map['title'] as String? ?? 'No Title',
      content: map['content'] as String? ?? 'No Content Available',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Safely handle null timestamps
      relatedTeams: (map['relatedTeams'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      relatedDrivers: (map['relatedDrivers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: map['image_url'] as String? ?? 'default_news_image.png',
      viewsCount: map['viewsCount'] as int? ?? 0,
      likesCount: map['likesCount'] as int? ?? 0,
      sharesCount: map['sharesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'relatedTeams': relatedTeams,
      'relatedDrivers': relatedDrivers,
      'image_url': imageUrl,
    };
  }
}
