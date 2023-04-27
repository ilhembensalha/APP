import 'package:flutter/material.dart';

class genLoginSignupHeader extends StatelessWidget {
  String headerName;

  genLoginSignupHeader(this.headerName);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 60.0),
          Text(
            headerName,
            style: TextStyle( 
             fontStyle: FontStyle.italic,
  fontFamily: 'emoji',
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
                fontSize: 40.0),
          ),
          SizedBox(height: 20.0),
          Image.asset(
            "assets/images/icon.png",
            height: 100.0,
            width: 100.0,
          ),
          SizedBox(height: 15.0),
          Text(
            'Budget Tracking App ',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black38,
                fontSize: 25.0),
          ),
          SizedBox(height: 15.0),
        ],
      ),
    );
  }
}
