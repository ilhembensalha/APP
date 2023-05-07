import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_with_signup/Model/Objectif.dart';
import 'package:login_with_signup/Screens/CategoriePage.dart';
import 'package:login_with_signup/Screens/Chart.dart';
import 'package:login_with_signup/Screens/HomeForm.dart';
import 'package:login_with_signup/Screens/LoginForm.dart';
import 'package:login_with_signup/Screens/Objectif.dart';
import 'package:login_with_signup/Screens/homePage.dart';

import 'package:login_with_signup/Screens/navigation.dart' as drawer;
import 'package:login_with_signup/Screens/page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
   Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
   
      HomePage(),  
      TaskHomePage(), 
      HomeForm(),
      ObjectifPage(),
       CategoriePage(),
       page()
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
     /* drawer: const drawer.NavigationDrawer(),*/
      appBar: AppBar(
        title: Text('Budget Tracking App'),
         actions: <Widget>[
           IconButton(
     
      icon: Icon(
        Icons.notification_add_sharp,
        color: Colors.white,
      ),
      onPressed:  ()  {
              
        // do something
      },
    ),
          IconButton(
     
      icon: Icon(
        Icons.settings,
        color: Colors.white,
      ),
      onPressed:  ()  {
              
        // do something
      },
    ),
    IconButton(
     
      icon: Icon(
        Icons.exit_to_app,
        color: Colors.white,
      ),
      onPressed:  () async {
                   final SharedPreferences sp = await _pref;
                 sp.remove('user_id');
      sp.remove('user_name');
      sp.remove('email');
      sp.remove('password');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginForm()),
              (Route<dynamic> route) => false);
        // do something
      },
    )
  ],
      ),
      

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.attach_money_outlined ,
               color:Colors.black,
            ),
            label: 'trans',
          ),
        
           BottomNavigationBarItem(
            icon: Icon(
              Icons.pie_chart,
              color:Colors.black,
            ),
            label: 'stat',
          ),
          
           BottomNavigationBarItem(
            icon: Icon(
              Icons.person_2_rounded,
              color:Colors.black,
            ),
            label: 
              'profile',
             
          ),
          
           BottomNavigationBarItem(
            icon: Icon(
              Icons.emoji_objects,
              color:Colors.black,
            ),
            label: 
              'objectif',
             
          ),
           BottomNavigationBarItem(
            icon: Icon(
              Icons.category,
              color:Colors.black,
            ),
            label: 
              'Categorie',
             
          ),
           BottomNavigationBarItem(
            icon: Icon(
              Icons.bar_chart,
              color:Colors.black,
            ),
            label: 
              'stat',
             
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
        selectedFontSize: 13.0,
        unselectedFontSize: 13.0,
   selectedLabelStyle: TextStyle(fontSize: 16),
  selectedItemColor: Colors.black,
      ),
    );
  }
}