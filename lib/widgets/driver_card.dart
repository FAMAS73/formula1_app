import 'package:flutter/material.dart';
import 'package:formula1_app/models/driver.dart';
import 'package:formula1_app/utils/constants.dart';

class DriverCard extends StatelessWidget {
  final Driver driver;
  final bool isFollowed;
  final VoidCallback onFollowTap;

  const DriverCard({
    Key? key,
    required this.driver,
    required this.isFollowed,
    required this.onFollowTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundColor,
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            leading: Image.network(driver.imageUrl, width: 50, height: 50),
            title: Text(driver.name, style: AppStyles.textStyle),
            subtitle: Text(driver.bio, style: AppStyles.textStyle),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(isFollowed ? Icons.star : Icons.star_border),
                color: isFollowed ? Colors.yellow : Colors.grey,
                onPressed: onFollowTap,
              ),
              SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
