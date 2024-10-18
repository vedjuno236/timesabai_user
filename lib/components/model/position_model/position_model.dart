import 'package:cloud_firestore/cloud_firestore.dart';

class PositionModel {
  final String id;
  final String name;

  PositionModel({required this.id, required this.name});

  factory PositionModel.fromFirestore(DocumentSnapshot doc) {
    return PositionModel(
      id: doc.id,
      name: doc.get('name'), // Ensure 'name' exists in the document
    );
  }

}