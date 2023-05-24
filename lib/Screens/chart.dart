import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:login_with_signup/DatabaseHandler/DbHelper.dart';
import 'package:login_with_signup/Model/Transactions.dart';

class TaskHomePage extends StatefulWidget {
  @override
  _TaskHomePageState createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  List<charts.Series<Transactions, String>> _seriesPieData = [];
  List<Map<String, dynamic>> _journals = [];
  List<Map<String, dynamic>> _id_caController = [];

  DbHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    _refreshJournals();
  }

  void _refreshJournals() async {
    final data = await dbHelper.getTran();
    final cat = await dbHelper.getCat();

    setState(() {
      _journals = data;
      _id_caController = cat;
    });

    _generateData();
  }

void _generateData() {
  final categoryCountMap = Map<int, int>();
  final uniqueCategoryIds = Set<int>(); // Utiliser un Set pour stocker les ID de catégorie uniques

  for (final journal in _journals) {
    final transaction = Transactions.fromMap(journal);
    final categoryId = transaction.id_cat;
    final count = categoryCountMap[categoryId] ?? 0;
    categoryCountMap[categoryId] = count + 1;
    uniqueCategoryIds.add(categoryId); // Ajouter l'ID de catégorie au Set
  }

  final totalTransactions = _journals.length;
  final mydata = _journals
      .map((journal) => Transactions.fromMap(journal))
      .map((transaction) {
    final categoryId = transaction.id_cat;
    final count = categoryCountMap[categoryId];
    final percentage = count != null ? (count / totalTransactions) * 100 : 0.0;
    transaction.prix = percentage;
    return transaction;
  }).toList();

  _seriesPieData = [
    charts.Series<Transactions, String>(
      id: 'transactions',
      domainFn: (Transactions transaction, _) =>
          _id_caController.firstWhere((category) => category['id_cat'] == transaction.id_cat)['name'],
      measureFn: (Transactions transaction, _) => transaction.prix,
      data: mydata,
      labelAccessorFn: (Transactions row, _) => '${row.prix.toStringAsFixed(2)}%',
  
    ),
  ];
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    var dbClient = await dbHelper.db;
    final result = await dbClient.query('transactions');
    return result.toList();
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          final data = snapshot.data;
          _journals = data;
          _generateData();
          return _buildChart(context);
        }
      },
    );
  }

  Widget _buildChart(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                'Transactions',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.PieChart(
                  _seriesPieData,
                  animate: true,
                  animationDuration: Duration(seconds: 5),
                  behaviors: [
                    charts.DatumLegend(
                      outsideJustification: charts.OutsideJustification.endDrawArea,
                      horizontalFirst: false,
                      desiredMaxRows: 2,
                      cellPadding: EdgeInsets.only(right: 4.0, bottom: 4.0, top: 4.0),
                      entryTextStyle: charts.TextStyleSpec(
                        color: charts.MaterialPalette.purple.shadeDefault,
                        fontFamily: 'Georgia',
                        fontSize: 18,
                      ),
                    )
                  ],
                  defaultRenderer: charts.ArcRendererConfig(
                    arcRendererDecorators: [
                      charts.ArcLabelDecorator(labelPosition: charts.ArcLabelPosition.inside),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
