import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:formula1_app/models/news.dart';
import 'package:rxdart/rxdart.dart';

class NewsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<List<News>> fetchNews(
      List<String> followedTeams, List<String> followedDrivers) {
    Stream<List<News>> teamNews = _firestore
        .collection('News')
        .where('relatedTeams',
            arrayContainsAny: followedTeams.isEmpty ? ['dummy'] : followedTeams)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                News.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());

    Stream<List<News>> driverNews = _firestore
        .collection('News')
        .where('relatedDrivers',
            arrayContainsAny:
                followedDrivers.isEmpty ? ['dummy'] : followedDrivers)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                News.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());

    return Rx.combineLatest2<List<News>, List<News>, List<News>>(
        teamNews, driverNews, (teamResults, driverResults) {
      Map<String, News> newsMap = {};
      for (var news in teamResults) {
        newsMap[news.id] = news; // Prevent duplicates
      }
      for (var news in driverResults) {
        newsMap[news.id] = news; // Duplicates are overwritten
      }
      return newsMap.values.toList(); // Convert the map back to a list
    });
  }

  static void incrementViewsCount(String newsId) {
    _firestore
        .collection('News')
        .doc(newsId)
        .update({'viewsCount': FieldValue.increment(1)});
  }

  static void toggleLike(String userId, String newsId) {
    DocumentReference newsRef = _firestore.collection('News').doc(newsId);

    _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(newsRef);
      var data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        List<dynamic> likedBy = data['likedBy'] ?? [];
        int likesCount = data['likesCount'] ?? 0;

        if (likedBy.contains(userId)) {
          transaction.update(newsRef, {
            'likesCount': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([userId])
          });
        } else {
          transaction.update(newsRef, {
            'likesCount': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([userId])
          });
        }
      }
    });
  }

  static void incrementShares(String newsId) {
    _firestore
        .collection('News')
        .doc(newsId)
        .update({'sharesCount': FieldValue.increment(1)});
  }
}
