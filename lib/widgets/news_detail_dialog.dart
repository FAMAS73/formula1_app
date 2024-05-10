import 'package:flutter/material.dart';
import 'package:formula1_app/models/news.dart';

void showNewsDetailDialog(BuildContext context, News news) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(news.title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(news.content),
              if (news.imageUrl.isNotEmpty)
                Image.network(
                  news.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
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
}
