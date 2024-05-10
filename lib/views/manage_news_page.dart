import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:formula1_app/widgets/news_edit_dialog.dart'; // Ensure this path is correct

class ManageNewsPage extends StatefulWidget {
  @override
  _ManageNewsPageState createState() => _ManageNewsPageState();
}

class _ManageNewsPageState extends State<ManageNewsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchDataForDropdowns() async {
    var teamsSnapshot =
        await FirebaseFirestore.instance.collection('Teams').get();
    var driversSnapshot =
        await FirebaseFirestore.instance.collection('Drivers').get();

    List<DropdownMenuItem<String>> teamsItems = teamsSnapshot.docs
        .map((doc) => DropdownMenuItem<String>(
            value: doc.id, child: Text(doc.data()['name'])))
        .toList();

    List<DropdownMenuItem<String>> driversItems = driversSnapshot.docs
        .map((doc) => DropdownMenuItem<String>(
            value: doc.id, child: Text(doc.data()['name'])))
        .toList();

    return {
      'teams': teamsItems,
      'drivers': driversItems,
    };
  }


  void openEditDialog({String? id, Map<String, dynamic>? newsData}) {
    fetchDataForDropdowns().then((dropdownData) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewsEditDialog(
              id: id,
              initialValues: newsData,
              teamsItems: dropdownData['teams'],
              driversItems: dropdownData['drivers'],
            );
          });
    });
  }
void _confirmDeletion(String newsId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text(
                'Are you sure you want to delete this news item? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () {
                  _firestore.collection('News').doc(newsId).delete();
                  Navigator.of(context).pop(); // Close the confirmation dialog
                },
              ),
            ],
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage News"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('News').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var news = snapshot.data!.docs[index];
              var data = news.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title']),
                subtitle: Text(data['content'],
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => openEditDialog(
                        id: news.id,
                        newsData: data,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () =>
                          _confirmDeletion(news.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openEditDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add News',
      ),
    );
  }
}
