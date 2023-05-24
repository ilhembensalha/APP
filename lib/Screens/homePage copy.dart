
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login_with_signup/DatabaseHandler/DbHelper.dart';
import 'package:login_with_signup/Screens/NotificationPage.dart';
import 'package:login_with_signup/Screens/Objectif.dart';
import 'package:login_with_signup/Screens/page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_with_signup/Screens/navigation.dart' as drawer;
import '../Comm/comHelper.dart';
import 'CategoriePage.dart';
import 'HomeForm.dart';
import 'package:table_calendar/table_calendar.dart';
import 'LoginForm.dart';



class HomePage extends StatefulWidget {

  const HomePage({key  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
    void _showNotification() {}
}

class  _HomePageState extends State<HomePage>{
   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
 DbHelper dbHelper;
  // All journals
  
  List<Map<String, dynamic>> _journals = [];
   List<Map<String, dynamic>> _id_caController  = [] ;
     Future<SharedPreferences> _pref = SharedPreferences.getInstance();
    String dropdownvalue = 'revenu ';
       bool _showMontantTextField = false ;

  var items = [
    'revenu',
    'depense',
    
  ];

  bool _isLoading = true;
   double _total ;
    double _depense ;
    double _totaal ;
   var selectedCategory ;
     Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Notification"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }
     Future _showNotification() async {
    var android = AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'Alerte', 'vos revenus et vos dépenses sont égaux', platform,
        payload: 'Custom_Sound');
  }
   
  // This function is used to fetch all data from the database
  void _refreshJournals() async {

    final data = await dbHelper.getTran();
    final sum = await dbHelper.sumField();
    final dep = await dbHelper.moins();
   final cat = await  dbHelper.getCat();
   print(_id_caController);
    setState(() {
      _journals = data;
      _isLoading = false;
      _total = sum ;
      _id_caController = cat;
      _depense = dep ;
      if(_total != null && _depense != null ){
      _totaal = _total  -  _depense;
      }else if(_depense != null ){
        _totaal = 0 -_depense;
        _total = 0;
      }else if(_total != null)  {
     _totaal = _total;
     _depense =0;
      }
      else if(_total == null &&_depense == null )  {
     _totaal = 0;
     _total = 0 ;
     _depense = 0 ;
      }
    });

    if(_depense == _total){
    _showNotification() ;
    }
  }
   /*Future total() async {
      var total = (await dbHelper.getTotal())[0]["sum(prix)"];
      return total.toString();
    
  }*/

 /*double _total ;
  void _calcTotal() async {
    var total =
        (await dbHelper.getTotal())[0]["sum(prix)"];
    print(total);
    setState(() {
      _total = total;
    });
  }*/
/*void printMyFutureString() async {
  String data = await dbHelper.getTotalMontant();
  print(data);
}*/

  @override
  void initState() {
    super.initState();
     _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
    _loadTransactions();
        dbHelper = DbHelper();
            var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
       bool _showMontantTextField = false;
    _refreshJournals(); // Loading the diary when the app starts
  }
  CalendarFormat _calendarFormat;
  DateTime _focusedDay;
  DateTime _selectedDay;
  Map<DateTime, List<dynamic>> _events;
 


  Future<void> _loadTransactions() async {
    DbHelper dbHelper = DbHelper();
    List<Map<String, dynamic>> transactions = await dbHelper.gettr();

    for (var transaction in transactions) {
      final date = DateTime.parse(transaction['date']);
      setState(() {
        if (_events.containsKey(date)) {
          _events[date].add(date);
        } else {
          _events[date] = [date];
        }
      });
    }

    setState(() {
      _isLoading = false;
    });

    print(_events);
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TextEditingController _prixController = TextEditingController();
  var _typeTransController ;
  var   _catController ;
   // ignore: non_constant_identifier_names

 void _showForm(int id) async {
  if (id != null) {
    final existingJournal =
        _journals.firstWhere((element) => element['id'] == id);
    _nameController.text = existingJournal['name'];
    _prixController.text = existingJournal['prix'].toString();
    _descriptionController.text = existingJournal['description'];
    _typeTransController = existingJournal['typeTrans'];
    _catController = existingJournal['id_cat'];
  }

  showModalBottomSheet(
    context: context,
    elevation: 5,
    isScrollControlled: true,
    builder: (_) => Container(
      padding: EdgeInsets.only(
        top: 15,
        left: 15,
        right: 15,
        bottom: MediaQuery.of(context).viewInsets.bottom + 120,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'name'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categorie'),
              DropdownButton(
                value: _catController,
                icon: Icon(Icons.keyboard_arrow_down),
                onChanged: (newValue) {
                  setState(() {
                    _catController = newValue;
                  });
                },
                items: _id_caController.map((category) {
                  return DropdownMenuItem(
                    value: category['id_cat'],
                    child: Text(category['name']),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(hintText: 'Description'),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              RadioListTile(
                title: Text("Dépense"),
                value: "depense",
                groupValue: _typeTransController,
                onChanged: (value) {
                  setState(() {
                    _typeTransController = value.toString();
                    _showMontantTextField = false;
                   _prixController.text = '';
                  });
                },
              ),
              RadioListTile(
                title: Text("Revenu"),
                value: "revenu",
                groupValue: _typeTransController,
                onChanged: (value) {
                  setState(() {
                    _typeTransController = value.toString();
                    _showMontantTextField = false;
                   _prixController.text = '';
                  });
                },
              ),
              if (_typeTransController == "depense")
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showMontantTextField = true;
                         // _prixController.text = '';
                        });
                      },
                      child: Text('Manuel'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Perform action for "Automatique" button
                      },
                      child: Text('Automatique'),
                    ),
                  ],
                ),
              if (_typeTransController == "revenu" || _showMontantTextField)
                TextField(
                  controller: _prixController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: 'Montant'),
                ),
            ],
          ),
        /*  const SizedBox(height: 20), TextField(
                  controller: _prixController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: 'Montant'),
                ),*/
          const SizedBox(height: 10),
          ElevatedButton(
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(Size(400, 50)),
            ),
            onPressed: () async {
              if (id == null) {
                if (_nameController.text.isEmpty) {
                  alertDialog(context, "Please enter name");
                } else if (_descriptionController.text.isEmpty) {
                  alertDialog(context, "Please enter description");
                } else if (_prixController.text.isEmpty) {
                  alertDialog(context, "Please enter montant");
                } else {
                  await _addItem();
                }
              }

              if (id != null) {
                if (_nameController.text.isEmpty) {
                  alertDialog(context, "Please enter name");
                } else if (_descriptionController.text.isEmpty) {
                  alertDialog(context, "Please enter description");
                } else if (_prixController.text.isEmpty) {
                  alertDialog(context, "Please enter montant");
                } else {
                  await _updateItem(id);
                }
              }

              _nameController.text = '';
              _descriptionController.text = '';
              _prixController.text = '';

              Navigator.of(context).pop();
            },
            child: Text(id == null ? 'Create New' : 'Update'),
          )
        ],
      ),
    ),
  );
}


// Insert a new journal to the database
  Future<void> _addItem() async {
    await  dbHelper.createTran(
        _nameController.text, _descriptionController.text,_prixController.text,_typeTransController,_catController );
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await dbHelper.updateTran(
        id,_nameController.text, _descriptionController.text,_prixController.text,_typeTransController,_catController );
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
   await dbHelper.deleteTran(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }



  @override
  Widget build(BuildContext context) {
      Future<SharedPreferences> _pref = SharedPreferences.getInstance();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: 
             TabBar(
              indicatorColor: Color.fromARGB(255, 98, 135, 208),
              tabs: [
                Tab(
                text: 'Calandar',
                ),
                Tab(text: 'Liste',),
              ],
                labelColor: Colors.blue,
            ),
          
          body: TabBarView(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  child: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : TableCalendar(
              calendarFormat: _calendarFormat,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2010, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(fontSize: 20),
              ),
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _showTransactionsDialog(context, selectedDay);
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, focusedDay) {
                  if (_events.containsKey(date)) {
                    for (DateTime d in _events[date]) {
                      if (isSameDay(date, d)) {
                        return Container(
                          decoration: BoxDecoration(
                            color: _getEventColor('revenu'), // Replace with your logic for getting the event type
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    }
                  }
                  return null;
                },
              ),
            ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  child: _isLoading
               ? const Center(
             child: CircularProgressIndicator(),
           )
               :  Column(
        children: [
          
          Card(    
             
          elevation:5,
       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1),
                      ),  
     margin: const EdgeInsets.all(15),
      child: Container(
    height: 70
    , // hauteur de la carte
  
    child: Column(  
      
      mainAxisSize: MainAxisSize.min,  
      children: <Widget>[ 
          SizedBox(height: 20),
           
        Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(' Revenus'),
    Text('Depenses'),
    Text('SoldesS '),
  ],
) ,
        Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
 
  children: [
    Text(' $_total', style: TextStyle(color: Colors.green)),
    Text('$_depense', style: TextStyle(color: Colors.red)),
    Text('$_totaal ', style: TextStyle(color: Colors.black),),
  ],
) ,
    
      ],  
    ),
      ),  
  ),
 Text(
   
  'Transactions Historique  :  ',
  textAlign: TextAlign.start,
  style: TextStyle(
      color: Colors.grey[800],
      fontWeight: FontWeight.bold,
      fontSize: 20 ), 
     ),
            Expanded(
            child: ListView.builder(
             itemCount: _journals.length,
             itemBuilder: (context, index) => Card(
               elevation:5,
               color: Colors.white,
               margin: const EdgeInsets.all(15),
               child: ListTile(
                   title: Text(_journals[index]['name']),
                    subtitle:_journals[index]['typeTrans'] == "revenu"? Text('+'+_journals[index]['prix'].toString()  +' '+_journals[index]['date'] ,  style: TextStyle(color: Colors.green
                    )):Text('-'+_journals[index]['prix'].toString()+ ' '+_journals[index]['date'] ,   style: TextStyle(color: Colors.red)),
               
leading: _id_caController.map((category) => category['id_cat'] == _journals[index]['id_cat'] ?
 Text(category['name']) : null).toList().firstWhere((element) => element != null, orElse: () => Text('err')),



                   trailing: SizedBox(
                     width: 100,
                     child: Row(
                       children: [
                         IconButton(
                           icon: const Icon(Icons.edit),
                           onPressed: () => _showForm(_journals[index]['id']),
                         ),
                         IconButton(
                           icon: const Icon(Icons.delete),
                           onPressed: () =>
                               _deleteItem(_journals[index]['id']),
                         ),
                       ],
                     ),
                   )),
             ),
          ),

           ),
        ],
      ),
                                   
      
                ),
              ),
             
            ],
            
          ),
          floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
        ),
      ),
    );
  }


 bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Color _getEventColor(String typeTrans) {
    if (typeTrans == 'revenu') {
      return Colors.lightGreen;
    } else if (typeTrans == 'depense') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  void _showTransactionsDialog(BuildContext context, DateTime selectedDay) async {
    DbHelper dbHelper = DbHelper();
    List<Map<String, dynamic>> transactions = await dbHelper.getTranByDate(selectedDay);

    List<dynamic> transactionDescriptions =
        transactions.map((transaction) => transaction['name']).toList();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Transactions - $selectedDay'),
          content: SingleChildScrollView(
            child: Column(
              children: transactionDescriptions.map((transaction) {
                return ListTile(
                  title: Text(transaction),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
 
}

