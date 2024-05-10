import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:formula1_app/widgets/team_edit_dialog.dart'; // Ensure this path is correct

class ManageTeamsPage extends StatefulWidget {
  @override
  _ManageTeamsPageState createState() => _ManageTeamsPageState();
}

class _ManageTeamsPageState extends State<ManageTeamsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void openEditDialog({String? id, Map<String, dynamic>? teamData}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return TeamEditDialog(
            id: id,
            initialValues: teamData,
          );
        });
  }

  void _confirmDeletion(String teamId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text(
                'Are you sure you want to delete this team? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('Teams')
                      .doc(teamId)
                      .delete();
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  Navigator.of(context).pop(); // Close the open dialog if any
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
        title: Text("Manage Teams"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Teams').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var team = snapshot.data!.docs[index];
              return ListTile(
                title: Text(team['name']),
                subtitle: Text(team['story'],
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => openEditDialog(
                        id: team.id,
                        teamData: team.data() as Map<String, dynamic>,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmDeletion(team.id),
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
        tooltip: 'Add Team',
      ),
    );
  }
}
