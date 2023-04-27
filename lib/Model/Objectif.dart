class Objectif{

 int id;
  String name;
  String somme;
 Objectif(this.id, this.name, this.somme);
  
    Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'somme': somme
    };
    return map;
  }

  Objectif.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    somme= map['somme'];
  }
}

  
  