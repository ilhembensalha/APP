
import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:login_with_signup/DatabaseHandler/DbHelper.dart';
import 'package:login_with_signup/Model/Transactions.dart';
import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';

class TaskHomePage extends StatefulWidget {
  @override
  _TaskHomePageState createState() {
    return _TaskHomePageState();
  }
}

class _TaskHomePageState extends State<TaskHomePage> {
  List<charts.Series<Transactions, String>> _seriesPieData = [];
  List<Transactions> mydata;
  
  List<Map<String, dynamic>> _journals = [];
  
   DbHelper dbHelper;
   
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
  _generateData(mydata) {   
   // List<charts.Series<Transactions, String>> _seriesPieData = [];
       _seriesPieData = List<charts.Series<Transactions, String>>();
    _seriesPieData.add(
      charts.Series(
        domainFn: (Transactions task, _) => task.name,
        measureFn: (Transactions task, _) => task.id_cat,
        colorFn: (Transactions task, _) =>
            charts.ColorUtil.fromDartColor(Colors.primaries[math.Random().nextInt(Colors.primaries.length)]),
        id: 'transactions',
        data: mydata,
        labelAccessorFn: (Transactions row, _) => "${row.id_cat}",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      body: _buildBody(context),
    );
  }


Future<List<Map<String, dynamic>>> getAll() async {
  //final db = await openDatabase('test.db');
   var dbClient = await dbHelper.db;
  final result = await dbClient.query('transactions');
  return result.toList();
}
  Widget _buildBody(BuildContext context) {
    
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
     // return _buildChart(context, _journals.cast<Transactions>().toList());  
        }
      
   
  Widget _buildChart(BuildContext context, List<Transactions> taskdata) {
    mydata = taskdata;
    _generateData(mydata);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                'Time spent on daily tasks',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.PieChart(_seriesPieData,
                    animate: true,
                    animationDuration: Duration(seconds: 5),
                    behaviors: [
                      new charts.DatumLegend(
                        outsideJustification:
                            charts.OutsideJustification.endDrawArea,
                        horizontalFirst: false,
                        desiredMaxRows: 2,
                        cellPadding:
                            new EdgeInsets.only(right: 4.0, bottom: 4.0,top:4.0),
                        entryTextStyle: charts.TextStyleSpec(
                            color: charts.MaterialPalette.purple.shadeDefault,
                            fontFamily: 'Georgia',
                            fontSize: 18),
                      )
                    ],
                    defaultRenderer: new charts.ArcRendererConfig(
                        arcWidth: 100,
                        arcRendererDecorators: [
                          new charts.ArcLabelDecorator(
                              labelPosition: charts.ArcLabelPosition.inside)
                        ])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
