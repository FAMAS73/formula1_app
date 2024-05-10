import 'package:flutter/material.dart';
import 'package:formula1_app/models/team.dart';
import 'package:formula1_app/utils/constants.dart';
import 'package:formula1_app/views/team_detail_page.dart';
import 'package:favorite_button/favorite_button.dart'; // Import the package

class TeamCard extends StatelessWidget {
  final Team team;
  final bool isFollowed;
  final VoidCallback onFollowTap;

  const TeamCard({
    Key? key,
    required this.team,
    required this.isFollowed,
    required this.onFollowTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundColor,
      margin: EdgeInsets.all(8),
      elevation: 5,
      shadowColor: AppColors.primaryColor.withOpacity(0.5),
      child: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => TeamDetailPage(team: team)));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(team.imageUrl,
                width: 100, height: 100, fit: BoxFit.cover),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  team.name,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            FavoriteButton(
              isFavorite: isFollowed,
              valueChanged: (_isFavorite) {
                onFollowTap();
              },
              iconSize: 40.0,
              iconColor: Colors.yellow,
            ),
          ],
        ),
      ),
    );
  }
}
