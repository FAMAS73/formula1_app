import 'package:flutter/material.dart';
import 'package:formula1_app/models/news.dart';
import 'package:formula1_app/services/news_service.dart';
import 'package:formula1_app/widgets/news_card.dart';
import 'package:formula1_app/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:formula1_app/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marquee/marquee.dart';

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
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          var userData = userDoc.data() as Map<String, dynamic>;

          // Update followedTeams and followedDrivers based on the user's data
          setState(() {
            followedTeams = List<String>.from(userData['followedTeams'] ?? []);
            followedDrivers =
                List<String>.from(userData['followedDrivers'] ?? []);
          });
        }
      } catch (e) {
        print("Error fetching user preferences: $e");
        // Handle errors or show a message if necessary
      }
    } else {
      // Handle the case where there is no user logged in
      print("No user logged in");
    }
  }

  Future<void> refreshNews() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('F1 News', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshNews,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 30,
            color: Colors.black, // You can style this container as needed
            child: Marquee(
              text: 'Latest F1 News Updates - Scroll to view more!',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 20.0,
              velocity: 100.0,
              pauseAfterRound: Duration(seconds: 1),
              startPadding: 10.0,
              accelerationDuration: Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<News>>(
              stream: NewsService.fetchNews(followedTeams, followedDrivers),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: snapshot.data!
                      .map((news) => NewsCard(
                            news: news,
                            onTap: () => showNewsDetailDialog(news),
                            onLike: () => NewsService.toggleLike(
                                FirebaseAuth.instance.currentUser!.uid,
                                news.id), // Pass the user ID and news ID
                            // Adjust according to your service method signatures
                            onShare: () => NewsService.incrementShares(news.id),
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showNewsDetailDialog(News news) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(news.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(news.content),
                SizedBox(height: 10),
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
        );
      },
    );
    NewsService.incrementViewsCount(news.id);
  }
}
