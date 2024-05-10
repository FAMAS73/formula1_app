import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formula1_app/models/news.dart';
import 'package:rxdart/rxdart.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  List<String> followedTeams = [];
  List<String> followedDrivers = [];
  Set<String> likedNewsIds = Set<String>();

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
  }

  void fetchUserPreferences() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('Users').doc(user!.uid).get();
    if (userDoc.exists) {
      var userData = userDoc.data()
          as Map<String, dynamic>?; // Cast to Map<String, dynamic>
      if (userData != null) {
        setState(() {
          followedTeams = List<String>.from(userData['followedTeams'] ?? []);
          followedDrivers =
              List<String>.from(userData['followedDrivers'] ?? []);
        });
      }
    }

    // Fetch all news and determine which ones are liked by this user
    QuerySnapshot newsSnapshot = await _firestore.collection('News').get();
    Set<String> tempLikedNewsIds = {};
    for (var doc in newsSnapshot.docs) {
      var newsData =
          doc.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>
      if (newsData != null) {
        List<dynamic> likedBy = newsData['likedBy'] ?? [];
        if (likedBy.contains(user!.uid)) {
          tempLikedNewsIds.add(doc.id);
        }
      }
    }
    setState(() {
      likedNewsIds = tempLikedNewsIds;
    });
  }

  Stream<List<News>> getNews() {
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
        newsMap[news.id] = news; // Use news ID as the key to prevent duplicates
      }
      for (var news in driverResults) {
        newsMap[news.id] = news; // Duplicates are overwritten
      }
      return newsMap.values.toList(); // Convert the map back to a list
    });
  }

  void incrementNewsViewCount(String newsId) {
    _firestore
        .collection('News')
        .doc(newsId)
        .update({'viewsCount': FieldValue.increment(1)});
  }

  void incrementLikes(String newsId) {
    DocumentReference newsRef = _firestore.collection('News').doc(newsId);
    newsRef.get().then((DocumentSnapshot doc) {
      var data = doc.data() as Map<String, dynamic>?; // Safely cast the data
      if (data != null) {
        int currentLikes = data['likesCount'] ?? 0;
        newsRef.update({'likesCount': FieldValue.increment(1)});
      }
    });
  }

  void incrementShares(String newsId) {
    DocumentReference newsRef = _firestore.collection('News').doc(newsId);
    newsRef.get().then((DocumentSnapshot doc) {
      var data = doc.data() as Map<String, dynamic>?; // Safely cast the data
      if (data != null) {
        int currentShares = data['sharesCount'] ?? 0;
        newsRef.update({'sharesCount': FieldValue.increment(1)});
      }
    });
  }

  void toggleLike(String newsId) {
    DocumentReference newsRef = _firestore.collection('News').doc(newsId);

    _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(newsRef);
      if (!snapshot.exists) {
        throw Exception("Document does not exist!");
      }

      // Correctly cast the snapshot data
      var data = snapshot.data();
      if (data is Map<String, dynamic>) {
        // Ensure data is a Map before accessing it
        List<dynamic> likedBy = data['likedBy'] ?? [];
        int likesCount = data['likesCount'] ?? 0;

        if (likedBy.contains(user!.uid)) {
          // User already liked this news, so unlike it
          transaction.update(newsRef, {
            'likesCount': FieldValue.increment(
                -1), // Use Firestore's increment to handle decrement safely
            'likedBy': FieldValue.arrayRemove([user!.uid])
          });
        } else {
          // User hasn't liked this news, so like it
          transaction.update(newsRef, {
            'likesCount': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([user!.uid])
          });
        }
      } else {
        throw Exception("Data format is incorrect!");
      }
    });
  }

  void showNewsDetailDialog(News news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(news.title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(news.content),
              Image.network(news.imageUrl),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    incrementNewsViewCount(news.id);
  }

  Future<void> refreshNews() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('F1 News'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshNews, // This allows manual refresh as well
          ),
        ],
      ),
      body: StreamBuilder<List<News>>(
        stream: getNews(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return Center(
                child: Text(
                    "No news related to your followed teams and drivers."));
          }
          return RefreshIndicator(
            onRefresh:
                refreshNews, // Call the refresh function when the user pulls down
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                News news = snapshot.data![index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.all(8),
                  child: InkWell(
                    onTap: () => showNewsDetailDialog(news),
                    child: Column(
                      children: [
                        Image.network(news.imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(news.title,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(news.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 15)),
                            ],
                          ),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                "Views: ${news.viewsCount} Likes: ${news.likesCount} Shares: ${news.sharesCount}"),
                            IconButton(
                              icon: Icon(Icons.thumb_up),
                              onPressed: () => toggleLike(news.id),
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () => incrementShares(news.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
