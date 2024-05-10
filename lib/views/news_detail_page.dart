import 'package:flutter/material.dart';
import 'package:formula1_app/models/news.dart';

class NewsDetailPage extends StatelessWidget {
  final News news;

  NewsDetailPage({required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(news.title)),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(news.content),
            Text(news.timestamp.toString()),
            // Additional details and widgets can be added here.
          ],
        ),
      ),
    );
  }
}
