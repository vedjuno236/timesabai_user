import 'package:cloud_firestore/cloud_firestore.dart';

class AgenciesModel {

  final String id;
  final String name;
  AgenciesModel({
    required this.id,
    required this.name
  });
  factory AgenciesModel.fromFirestore(DocumentSnapshot doc) {
    return AgenciesModel(
      id: doc.id,
      name: doc.get('name'), // Ensure 'name' exists in the document
    );
  }


}




