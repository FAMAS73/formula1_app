import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverEditDialog extends StatefulWidget {
  final String? id;
  final Map<String, dynamic>? initialValues;

  DriverEditDialog({Key? key, this.id, this.initialValues}) : super(key: key);

  @override
  _DriverEditDialogState createState() => _DriverEditDialogState();
}

class _DriverEditDialogState extends State<DriverEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _imageUrlController;
  String? _selectedTeamId;
  List<DropdownMenuItem<String>> _teamItems = [];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialValues?['name']);
    _bioController = TextEditingController(text: widget.initialValues?['bio']);
    _imageUrlController =
        TextEditingController(text: widget.initialValues?['image_url']);
    _selectedTeamId =
        widget.initialValues?['team_id']; // Corrected to 'team_id'
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    var snapshot = await FirebaseFirestore.instance.collection('Teams').get();
    var items = snapshot.docs
        .map((doc) => DropdownMenuItem<String>(
              value: doc.id,
              child: Text(doc.data()['name'] as String),
            ))
        .toList();
    setState(() {
      _teamItems = items;
    });
  }

  void _saveDriver() {
    if (_nameController.text.isEmpty || _selectedTeamId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Name and Team are required.')));
      return;
    }

    Map<String, dynamic> driverData = {
      'name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'image_url': _imageUrlController.text.trim(),
      'team_id': _selectedTeamId, // Corrected to 'team_id'
    };

    if (widget.id == null) {
      FirebaseFirestore.instance.collection('Drivers').add(driverData);
    } else {
      FirebaseFirestore.instance
          .collection('Drivers')
          .doc(widget.id)
          .update(driverData);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.id == null ? 'Add New Driver' : 'Edit Driver'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Driver Name'),
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Biography'),
              minLines: 1,
              maxLines: 5,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedTeamId,
              items: _teamItems,
              onChanged: (value) {
                setState(() {
                  _selectedTeamId = value;
                });
              },
              decoration: InputDecoration(labelText: 'Select Team'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: _saveDriver,
        ),
      ],
    );
  }
}
