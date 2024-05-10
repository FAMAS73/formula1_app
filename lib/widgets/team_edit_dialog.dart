import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamEditDialog extends StatefulWidget {
  final String? id;
  final Map<String, dynamic>? initialValues;

  TeamEditDialog({Key? key, this.id, this.initialValues}) : super(key: key);

  @override
  _TeamEditDialogState createState() => _TeamEditDialogState();
}

class _TeamEditDialogState extends State<TeamEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _storyController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialValues?['name']);
    _storyController =
        TextEditingController(text: widget.initialValues?['story']);
    _imageUrlController =
        TextEditingController(text: widget.initialValues?['image_url']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveTeam() {
    Map<String, dynamic> teamData = {
      'name': _nameController.text.trim(),
      'story': _storyController.text.trim(),
      'image_url': _imageUrlController.text.trim(),
    };

    if (widget.id == null) {
      FirebaseFirestore.instance.collection('Teams').add(teamData);
    } else {
      FirebaseFirestore.instance
          .collection('Teams')
          .doc(widget.id)
          .update(teamData);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.id == null ? 'Add New Team' : 'Edit Team'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Team Name'),
            ),
            TextField(
              controller: _storyController,
              decoration: InputDecoration(labelText: 'Story'),
              minLines: 1,
              maxLines: 5,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
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
          onPressed: _saveTeam,
        ),
      ],
    );
  }
}
