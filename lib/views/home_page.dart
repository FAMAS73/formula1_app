import 'package:flutter/material.dart';
import 'package:formula1_app/views/teams_page.dart';
import 'package:formula1_app/views/drivers_page.dart';
import 'package:formula1_app/views/news_page_v2.dart';
import 'package:formula1_app/views/users_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    TeamsPage(),
    NewsPage(),
    UsersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/teams_icon.png', width: 24),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/news_icon.png', width: 24),
            label: 'Following',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/user_icon.png', width: 24),
            label: 'User',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

