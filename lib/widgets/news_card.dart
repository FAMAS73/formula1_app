import 'package:flutter/material.dart';
import 'package:formula1_app/models/news.dart';
import 'package:formula1_app/utils/constants.dart';
import 'package:like_button/like_button.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onShare;

  const NewsCard({
    Key? key,
    required this.news,
    required this.onTap,
    required this.onLike,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Image.network(news.imageUrl,
                width: double.infinity, height: 200, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(news.title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(news.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15)),
                ],
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                Text(
                    "Views: ${news.viewsCount} Likes: ${news.likesCount} Shares: ${news.sharesCount}"),
                LikeButton(
                  likeCount: news.likesCount,
                  onTap: (bool isLiked) {
                    onLike();
                    return Future.value(!isLiked);
                  },
                ),
                IconButton(icon: Icon(Icons.share), onPressed: onShare),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
