class Categorie{

 int cat_id;
  String cat_name;
  String type;
  String description;
 Categorie(this.cat_id, this.cat_name, this.description, this.type);
  
    Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'cat-id': cat_id,
      'cat_name': cat_name,
      'type': type,
      'description': description
    };
    return map;
  }

  Categorie.fromMap(Map<String, dynamic> map) {
    cat_id = map['cat_id'];
    cat_name = map['cat_name'];
    type = map['type'];
    description= map['description'];
  }
}

  
  
  
  
  
  
  
  
  