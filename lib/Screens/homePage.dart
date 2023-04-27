
import 'package:flutter/material.dart';
import 'package:login_with_signup/DatabaseHandler/DbHelper.dart';
import 'package:login_with_signup/Screens/Objectif.dart';
import 'package:login_with_signup/Screens/page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_with_signup/Screens/navigation.dart' as drawer;
import '../Comm/comHelper.dart';
import 'CategoriePage.dart';
import 'HomeForm.dart';
import 'LoginForm.dart';



class HomePage extends StatefulWidget {

  const HomePage({key  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class  _HomePageState extends State<HomePage>{
 DbHelper dbHelper;
  // All journals
  
  List<Map<String, dynamic>> _journals = [];
   List<Map<String, dynamic>> _id_caController  = [] ;
     Future<SharedPreferences> _pref = SharedPreferences.getInstance();
    String dropdownvalue = 'revenu ';

  var items = [
    'revenu',
    'depense',
    
  ];

  bool _isLoading = true;
   double _total ;
    double _depense ;
    double _totaal ;
   var selectedCategory ;
   
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
        dbHelper = DbHelper();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  var _typeTransController ;
  var   _catController ;
   // ignore: non_constant_identifier_names

   
  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int  id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
      _journals.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
      _prixController.text = existingJournal['prix'].toString();
      _descriptionController.text = existingJournal['description'];
      _typeTransController=existingJournal['typeTrans']; 
      _catController=existingJournal['id_cat'];

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
              ),           const SizedBox(
                height: 20,
              ),
                 Row(   
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categorie'),DropdownButton(
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
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,

                decoration: const InputDecoration(hintText: 'Description'),
              ),
              
   

                     const SizedBox(
                height: 20,
              ),
              Row(   
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Type'),
                   DropdownButton(
                value: _typeTransController  ,
                icon: Icon(Icons.keyboard_arrow_down),
                items: items.map((items) {
                  return DropdownMenuItem(value: items, child: Text(items));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _typeTransController = newValue;
                  });
                },
              ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),TextField(
                controller: _prixController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'montant'),

              ), 
           
               const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                style: ButtonStyle(
    fixedSize: MaterialStateProperty.all(Size(400, 50)),
  ),
                onPressed: () async {
                  // Save new journal
                  if (id == null) {
        if (_nameController.text.isEmpty) {
      alertDialog(context, "Please Enter name");
    } else if (_descriptionController.text.isEmpty) {
      alertDialog(context, "Please Enter description");
      
    }  else if (_prixController.text.isEmpty) {
      alertDialog(context, "Please Enter montant");
      
    }  else if (_typeTransController.text.isEmpty) {
      alertDialog(context, "Please Enter type");
      
    }
      else if (_catController.text.isEmpty) {
      alertDialog(context, "Please Enter categorie");
      
    }else {
                    await _addItem();
       }
          }

                  if (id != null) {
                     if (_nameController.text.isEmpty) {
      alertDialog(context, "Please Enter name");
    } else if (_descriptionController.text.isEmpty) {
      alertDialog(context, "Please Enter description");
      
    }  else if (_prixController.text.isEmpty) {
      alertDialog(context, "Please Enter montant");
      
    } /* else if (_typeTransController.toString().isEmpty) {
      alertDialog(context, "Please Enter type");
      
    }
      else if (_catController.toString().isEmpty) {
      alertDialog(context, "Please Enter categorie");
      
    }*/else {
                    await _updateItem(id);
     }
      }

                  // Clear the text fields
                  _nameController.text = '';
                  _descriptionController.text = '';
                  _prixController.text = '';
              

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
    return Scaffold(
  
            body:_isLoading
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
    Text('Total '),
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
                      
           
     
                
                       
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
         
          );

  }
 
}

