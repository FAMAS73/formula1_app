import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowedItemCard extends StatelessWidget {
  final String itemId;
  final String collectionPath;

  FollowedItemCard({required this.itemId, required this.collectionPath});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(itemId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            return ListTile(
              leading: Image.network(data['image_url'], width: 50, height: 50),
              title: Text(data['name']),
            );
          }
          return ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Loading...'),
          );
        },
      ),
    );
  }
}
