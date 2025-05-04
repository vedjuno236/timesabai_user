import 'package:cloud_firestore/cloud_firestore.dart';

class EthnicityModel {
  final String id;
  final String name;

  EthnicityModel({required this.id, required this.name});

  factory EthnicityModel.fromFirestore(DocumentSnapshot doc) {
    return EthnicityModel(
      id: doc.id,
      name: doc.get('name'), // Ensure 'name' exists in the document
    );
  }

}