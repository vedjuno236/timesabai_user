import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {

  final String id;
  final String name;
  DepartmentModel({
    required this.id,
    required this.name
});
  factory DepartmentModel.fromFirestore(DocumentSnapshot doc) {
    return DepartmentModel(
      id: doc.id,
      name: doc.get('name'), // Ensure 'name' exists in the document
    );
  }


}




