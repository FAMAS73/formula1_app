import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:formula1_app/widgets/driver_edit_dialog.dart'; // Ensure this path is correct

class ManageDriversPage extends StatefulWidget {
  @override
  _ManageDriversPageState createState() => _ManageDriversPageState();
}

class _ManageDriversPageState extends State<ManageDriversPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void openEditDialog({String? id, Map<String, dynamic>? driverData}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DriverEditDialog(
            id: id,
            initialValues: driverData,
          );
        });
  }

  void _confirmDeletion(String driverId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text(
                'Are you sure you want to delete this driver? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () {
                  _firestore.collection('Drivers').doc(driverId).delete();
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
        title: Text("Manage Drivers"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Drivers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var driver = snapshot.data!.docs[index];
              return ListTile(
                title: Text(driver['name']),
                subtitle: Text(driver['bio'],
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => openEditDialog(
                        id: driver.id,
                        driverData: driver.data() as Map<String, dynamic>,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmDeletion(driver.id),
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
        tooltip: 'Add Driver',
      ),
    );
  }
}
