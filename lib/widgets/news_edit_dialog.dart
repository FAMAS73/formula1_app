import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsEditDialog extends StatefulWidget {
  final String? id;
  final Map<String, dynamic>? initialValues;
  final List<DropdownMenuItem<String>> teamsItems;
  final List<DropdownMenuItem<String>> driversItems;

  NewsEditDialog({
    Key? key,
    this.id,
    this.initialValues,
    required this.teamsItems,
    required this.driversItems,
  }) : super(key: key);

  @override
  _NewsEditDialogState createState() => _NewsEditDialogState();
}

class _NewsEditDialogState extends State<NewsEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _imageUrlController;
  List<String> _selectedTeams = [];
  List<String> _selectedDrivers = [];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialValues?['title']);
    _contentController =
        TextEditingController(text: widget.initialValues?['content']);
    _imageUrlController =
        TextEditingController(text: widget.initialValues?['image_url']);
    _selectedTeams =
        List<String>.from(widget.initialValues?['relatedTeams'] ?? []);
    _selectedDrivers =
        List<String>.from(widget.initialValues?['relatedDrivers'] ?? []);
  }

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


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.id == null ? 'Add New News' : 'Edit News'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              minLines: 3,
              maxLines: 5,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            DropdownButtonFormField(
              value: _selectedTeams.isNotEmpty ? _selectedTeams.first : null,
              items: widget.teamsItems,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTeams = newValue != null ? [newValue] : [];
                });
              },
              decoration: InputDecoration(labelText: 'Related Teams'),
            ),
            DropdownButtonFormField(
              value:
                  _selectedDrivers.isNotEmpty ? _selectedDrivers.first : null,
              items: widget.driversItems,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDrivers = newValue != null ? [newValue] : [];
                });
              },
              decoration: InputDecoration(labelText: 'Related Drivers'),
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
          onPressed: () {
            Map<String, dynamic> newsData = {
              'title': _titleController.text.trim(),
              'content': _contentController.text.trim(),
              'image_url': _imageUrlController.text.trim(),
              'relatedTeams': _selectedTeams,
              'relatedDrivers': _selectedDrivers,
            };
            if (widget.id == null) {
              FirebaseFirestore.instance.collection('News').add(newsData);
            } else {
              FirebaseFirestore.instance
                  .collection('News')
                  .doc(widget.id)
                  .update(newsData);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
