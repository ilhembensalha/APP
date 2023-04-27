import 'package:flutter/material.dart';
import 'dart:async';  
import 'package:flutter/material.dart';  
import 'package:splashscreen/splashscreen.dart';  
import 'Screens/LoginForm.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUDGET APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreenPage(),
    );
  }
}
class SplashScreenPage extends StatelessWidget {  
  @override  
  Widget build(BuildContext context) {  
    return SplashScreen(  
      seconds: 5,  
      navigateAfterSeconds: new LoginForm(),  
      backgroundColor: Colors.white,  
      title: new Text('Budget Tracking App',textScaleFactor: 2,),  
      image:Image.asset(
            "assets/images/icon.png",
            height: 150.0,
            width: 150.0,
          ),
      loadingText: Text("Loading"),  
      photoSize: 150.0,  
      loaderColor: Color.fromARGB(255, 54, 143, 244),  
    );  
  }  
} 