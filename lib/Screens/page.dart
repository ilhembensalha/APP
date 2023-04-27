// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:login_with_signup/DatabaseHandler/DbHelper.dart';
import 'package:login_with_signup/Model/Transactions.dart';
import 'package:login_with_signup/Screens/CategoriePage.dart';
import 'package:login_with_signup/Screens/HomeForm.dart';
import 'package:login_with_signup/Screens/LoginForm.dart';
import 'package:login_with_signup/Screens/Objectif.dart';
import 'package:login_with_signup/Screens/homePage.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';


class page extends StatefulWidget {
page({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _pageState createState() => _pageState();
}

class _pageState extends State<page> {
   Future<SharedPreferences> _pref = SharedPreferences.getInstance();
   List<charts.Series<Transactions, String>> _seriesBarData = [];
  List<Transactions> mydata;

   DbHelper dbHelper;
  _generateData(mydata) {
   // _seriesBarData = List<charts.Series<Transactions, String>>() ;
    _seriesBarData.add(
      charts.Series(
        domainFn: (Transactions sales, _) => sales.typeTrans.toString(),
        measureFn: (Transactions sales, _) =>sales.prix,
        colorFn: (Transactions sales, _) =>
            charts.ColorUtil.fromDartColor(Colors.primaries[math.Random().nextInt(Colors.primaries.length)]),
        id: 'Transactions',
        data: mydata,
       labelAccessorFn: (Transactions row, _) => "${row.prix}",
      ),
    );
  }
  
  List<Map<String, dynamic>> _journals = [];
   
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await dbHelper.getTran();
 
    setState(() {
      _journals = data;
    });
  }
  @override
  void initState() {
    super.initState();
        dbHelper = DbHelper();
    _refreshJournals(); // Loading the diary when the app starts
  }

  @override
  Widget build(BuildContext context) {
   
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(

      body: _buildBody(context),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  Future<List<Map<String, dynamic>>> getAll() async {
  //final db = await openDatabase('test.db');
   var dbClient = await dbHelper.db;
  final result = await dbClient.query('transactions');
  return result.toList();
}
  Widget _buildBody(BuildContext context)  {

              return FutureBuilder<List<Map<String, dynamic>>>(
      future:  getAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          final data = snapshot.data;
          List<Transactions> taskList = data.map((tarMap) => Transactions.fromMap(tarMap)).toList();
          return _buildChart(context, taskList);
        }
      },
    );  
    //return _buildChart(context, _journals.cast<Transactions>().toList());  
  }


  Widget _buildChart(BuildContext context, List<Transactions> saledata) {
    mydata = saledata;
    _generateData(mydata);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                'transactions by catégories',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
             Expanded(
                child: charts.BarChart(_seriesBarData,
                    animate: true,
                    animationDuration: Duration(seconds:5),
                     behaviors: [
                      new charts.DatumLegend(
                        entryTextStyle: charts.TextStyleSpec(
                            color: charts.MaterialPalette.purple.shadeDefault,
                            fontFamily: 'Georgia',
                            fontSize: 18),
                      )
                    ],
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
