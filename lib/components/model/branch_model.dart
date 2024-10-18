import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesabai/components/model/departmant_model/departmant_model.dart';


class BranchModel {
  final String id;
  final String name;
  final  DepartmentModel? departmentModel;

  BranchModel( {
    required this.id,
    required this.name,
   required this.departmentModel,
  });

  factory BranchModel.fromFirestore(DocumentSnapshot doc) {

    return BranchModel(
      id: doc.id,
      name: doc.get('name'),
      departmentModel: null,

    );
  }
}
