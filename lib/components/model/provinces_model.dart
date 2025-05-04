import 'package:cloud_firestore/cloud_firestore.dart';

class ProvincesModel {

  final String id;
  final String name;
  ProvincesModel({
    required this.id,
    required this.name
  });
  factory ProvincesModel.fromFirestore(DocumentSnapshot doc) {
    return ProvincesModel(
      id: doc.id,
      name: doc.get('name'), // Ensure 'name' exists in the document
    );
  }


}




