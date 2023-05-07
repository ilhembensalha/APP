import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login_with_signup/DatabaseHandler/DbHelper.dart';
import 'package:login_with_signup/Screens/CategoriePage.dart';
import 'package:login_with_signup/Screens/homePage.dart';
import 'package:login_with_signup/Screens/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Comm/comHelper.dart';
import 'HomeForm.dart';
import 'LoginForm.dart';
import 'homePage.dart';
import 'page.dart';


class ObjectifPage extends StatefulWidget {
  const ObjectifPage({Key key}) : super(key: key);

  @override
  _ObjectifPageState createState() => _ObjectifPageState();
}


class  _ObjectifPageState extends State<ObjectifPage>{
     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    DbHelper dbHelper;
  // All journals
  List<Map<String, dynamic>> _journals = [];
     Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  

  bool _isLoading = true;
  
 double _total ;
    double _depense ;
    double _totaal ;
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
        0, 'Title', 'Body', platform,
        payload: 'Custom_Sound');
  }
   
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await dbHelper.getObj();
       final sum = await dbHelper.sumField();
          final dep = await dbHelper.moins();
    setState(() {
      _journals = data;
      _isLoading = false;
        _total = sum ;
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
  }

  @override
  void initState() {
    super.initState();
        dbHelper = DbHelper() ;
          var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
   
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sommeController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int  id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
      _journals.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
      _sommeController.text = existingJournal['somme'].toString();
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
            // this will prevent the soft keyboard from covering the text fields
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
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _sommeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'somme'),
              ),
              
              
             
              const SizedBox(
                height: 10,
              ), const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                            style: ButtonStyle(
    fixedSize: MaterialStateProperty.all(Size(400, 50)),
  ),
                onPressed: () async {
                  // Save new journal
                  if (id == null) {
                    
    if (_sommeController.text.isEmpty) {
      alertDialog(context, "Please Enter name");
    } else if (_sommeController.text.isEmpty) {
      alertDialog(context, "Please Enter somme");
    } else {
                    await _addItem();
    }
                  }

                  if (id != null) {
         if (_nameController.text.isEmpty) {
      alertDialog(context, "Please Enter name");
    } else if (_sommeController.text.isEmpty) {
      alertDialog(context, "Please Enter somme");
    } else {
                    await _updateItem(id);
    }
                  }

                  // Clear the text fields
                  _nameController.text = '';
                  _sommeController.text = '';
                 

                  // Close the bottom sheet
                  
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await  dbHelper.createObj(
        _nameController.text, _sommeController.text );
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await dbHelper.updateObj(
        id,_nameController.text, _sommeController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
   await dbHelper.deleteObj(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (context, index) => Card(
           elevation:5,
               color: Colors.white,
          margin: const EdgeInsets.all(15),
          child: ListTile(
              title: Text(_journals[index]['name']),
               subtitle: Text(_journals[index]['somme'].toString()),
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
        
    );
  }
}