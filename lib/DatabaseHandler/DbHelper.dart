import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:login_with_signup/Model/Objectif.dart';
import 'package:login_with_signup/Model/Transactions.dart';
import 'package:login_with_signup/Model/UserModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

import 'package:sqflite/sqflite.dart' as sql;

import '../Model/Categorie.dart';


class DbHelper {
  static Database _db;

  static const String DB_Name = 'test.db';
  static const String Table_User = 'user';
  static const int Version = 1;

  static const String C_UserID = 'user_id';
  static const String C_UserName = 'user_name';
  static const String C_Email = 'email';
  static const String C_Password = 'password';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_Name);
    var db = await openDatabase(path, version: Version, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int intVersion) async {
     await db.execute(" CREATE TABLE  categorie ("
          "id_cat INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "name TEXT,"
         " description TEXT,"
         " type TEXT "
        ")");
         await db.execute(" CREATE TABLE  transactions ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "name TEXT,"
         " description TEXT,"
         " prix REAL ,"
         "typeTrans Text ,"
         "date DATE DEFAULT CURRENT_DATE ,"
         "id_cat INTEGER ,"
         "FOREIGN KEY(id_cat) REFERENCES categorie(id_cat)"
        ")");
            await db.execute(" CREATE TABLE  objectif ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "name TEXT,"
         " somme REAL "
        ")");

    await db.execute("CREATE TABLE $Table_User ("
        " $C_UserID TEXT, "
        " $C_UserName TEXT, "
        " $C_Email TEXT,"
        " $C_Password TEXT, "
        " PRIMARY KEY ($C_UserID)"
        ")");
  
  }

  Future<int> saveData(UserModel user) async {
    var dbClient = await db;
    var res = await dbClient.insert(Table_User, user.toMap());
    return res;
  }

  Future<UserModel> getLoginUser(String userId, String password) async {
    var dbClient = await db;
    var res = await dbClient.rawQuery("SELECT * FROM $Table_User WHERE "
        "$C_UserID = '$userId' AND "
        "$C_Password = '$password'");

    if (res.length > 0) {
      return UserModel.fromMap(res.first);
    }

    return null;
  }

  Future<int> updateUser(UserModel user) async {
    var dbClient = await db;
    var res = await dbClient.update(Table_User, user.toMap(),
        where: '$C_UserID = ?', whereArgs: [user.user_id]);
    return res;
  }

  Future<int> deleteUser(String user_id) async {
    var dbClient = await db;
    var res = await dbClient
        .delete(Table_User, where: '$C_UserID = ?', whereArgs: [user_id]);
    return res;
  }


/***total */
Future getTotalMontant() async {
  final dbClient = await db;
  final Total = await dbClient.rawQuery('SELECT SUM(prix) as Total  FROM transactions');
   return Total[0]["Total"];
}

Future getTotal() async {
  var dbClient = await db;
  var result = await dbClient.rawQuery("SELECT SUM(prix) as total FROM transactions ");
  int value = result[0]["SUM(prix)"]; // value = 220
  return result.toString();
}

Future<double> sumField() async {
   double _sum = 0;
final dbClient = await db;
final sum = await dbClient.rawQuery('SELECT SUM(prix) FROM transactions WHERE  typeTrans = "revenu" ' );
  return  _sum = sum[0]['SUM(prix)'];
}
Future<double> moins() async {
   double _de = 0;
final dbClient = await db;
final de = await dbClient.rawQuery('SELECT SUM(prix) FROM transactions  WHERE typeTrans = "depense" ' );
  return  _de = de[0]['SUM(prix)'];
}
  /** */
/*  static Future<sql.Database> bd () async {

      return sql.openDatabase(DB_Name, 
      version: 1,onCreate: (sql.Database database , int version) async
      {
        await createTable(database);
      },
      )  ;
  */



   Future<int> createCat(String name, String type, String descrption) async {
    //final db = await DbHelper.bd();
  var dbClient = await db;
    final data = {'name': name, 'description': descrption, 'type': type};
    final id = await dbClient.insert('categorie', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }
    Future<List<Map<String, dynamic>>> getCat() async {
     var dbClient = await db;
    return dbClient.query('categorie', orderBy: "id_cat");
  }
   Future<int> saveCat(Categorie categorie) async {
    var dbClient = await db;
    var res = await dbClient.insert('categorie', categorie.toMap());
    return res;
  } 
    Future<int> updateCat(
      int id, String name, String descrption,String type) async {
    var dbClient = await db;

    final data = {
      'name': name,
      'description': descrption,
      'type': type,
      
    };

    final result =
    await dbClient.update('categorie', data, where: "id_cat = ?", whereArgs: [id]);
    return result;
  }
     Future<void> deleteCat(int id) async {
     var dbClient = await db;
    try {
 
      await dbClient.delete ('categorie', where: 'id_cat = ?', whereArgs: [id]);
  }
    catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
    Future<List<Map<String, dynamic>>> getCatId() async {
     var dbClient = await db;
   var res = await dbClient.rawQuery("SELECT name FROM categorie");
  }

  
/*** */



   Future<int> createTran(String name, String descrption, String prix,String typeTrans, int id_cat) async {
    //final db = await DbHelper.bd();
  var dbClient = await db;
    final data = {'name': name, 'description': descrption, 'prix': prix,'typeTrans':typeTrans,'id_cat':id_cat};
    final id = await dbClient.insert('transactions', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }
    Future<List<Map<String, dynamic>>> getTran() async {
     var dbClient = await db;
    return dbClient.query('transactions', orderBy: "id");
  }
   Future<int> saveTran(Transactions transactions) async {
    var dbClient = await db;
    var res = await dbClient.insert('transactions', transactions.toMap());
    return res;
  } 
    Future<int> updateTran(
      int id, String name, String descrption,String prix,String typeTrans, int id_cat) async {
    //final db = await DbHelper.bd();) async {
    var dbClient = await db;

    final data = {
      'name': name,
      'description': descrption,
      'prix': prix,
      'typeTrans':typeTrans,
      'id_cat':id_cat,
    };

    final result =
    await dbClient.update('transactions', data, where: "id = ?", whereArgs: [id]);
    return result;
  }
     Future<void> deleteTran(int id) async {
     var dbClient = await db;
    try {
 
      await dbClient.delete ('transactions', where: 'id = ?', whereArgs: [id]);
  }
    catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
  /*** */



   Future<int> createObj(String name, String somme) async {
    //final db = await DbHelper.bd();
  var dbClient = await db;
    final data = {'name': name,'somme': somme};
    final id = await dbClient.insert('objectif', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }
    Future<List<Map<String, dynamic>>> getObj() async {
     var dbClient = await db;
    return dbClient.query('objectif', orderBy: "id");
  }
   Future<int> saveObj(Objectif objectif) async {
    var dbClient = await db;
    var res = await dbClient.insert('objectif', objectif.toMap());
    return res;
  } 
    Future<int> updateObj(
      int id, String name,  String somme) async {
    var dbClient = await db;

    final data = {
      'name': name,
      'somme': somme,
    
      
    };

    final result =
    await dbClient.update('objectif', data, where: "id = ?", whereArgs: [id]);
    return result;
  }
     Future<void> deleteObj(int id) async {
     var dbClient = await db;
    try {
 
      await dbClient.delete ('objectif', where: 'id = ?', whereArgs: [id]);
  }
    catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
  /*****delete  */
    Future<void> deleteTrantt() async {
     var dbClient = await db;
    try {
 
      await dbClient.delete ('transactions');
  }
    catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
}

    Future<void> deleteobjtt() async {
     var dbClient = await db;
    try {
 
      await dbClient.delete ('objectif');
  }
    catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
}
    Future<void> deletecattt() async {
     var dbClient = await db;
    try {
 
      await dbClient.delete ('categorie');
  }
    catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
}

}