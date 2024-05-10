import 'package:flutter/material.dart';
import 'package:formula1_app/models/driver.dart';

class DriverDetailPage extends StatelessWidget {
  final Driver driver;

  DriverDetailPage({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(driver.name)),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.network(driver.imageUrl),
            Text(driver.bio),
            // Additional details and widgets can be added here.
          ],
        ),
      ),
    );
  }
}
