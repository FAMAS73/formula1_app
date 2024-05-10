import 'package:flutter/material.dart';
import 'package:formula1_app/views/followed_item_card.dart';

class FollowedSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final String collectionPath;

  FollowedSection(
      {required this.title, required this.items, required this.collectionPath});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      children: items
          .map((id) =>
              FollowedItemCard(itemId: id, collectionPath: collectionPath))
          .toList(),
    );
  }
}
