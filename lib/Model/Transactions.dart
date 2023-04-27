import 'dart:core';

class Transactions{

  int id;
  String name;
  double prix;
  String description;
  String typeTrans;
  String date;
  int id_cat;
 Transactions(this.id, this.name, this.description, this.prix, this.typeTrans,this.id_cat,this.date);
  
    Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
       'date': date,
      'name': name,
      'prix': prix,
      'description': description,
      'typeTrans':typeTrans,
      'id_cat': id_cat
    };
    return map;
  }

  Transactions.fromMap(Map<String, dynamic> map) {
          assert(map['id'] != null);
        assert(map['id_cat'] != null);
    id = map['id'];
    date = map['date'];
    name = map['name'];
    prix = map['prix'];
    description = map['description'];
    typeTrans = map['typeTrans'];
    id_cat  = map['id_cat'];

  }
}

  
  
  
  
  
  
  
  
  