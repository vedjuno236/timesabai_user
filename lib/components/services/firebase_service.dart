import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesabai/components/model/position_model/position_model.dart';
import '../model/branch_model.dart';
import '../model/departmant_model/departmant_model.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DepartmentModel>> fetchDepartments() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Department').get();
      return snapshot.docs.map((doc) {
        return DepartmentModel(
          id: doc.id,
          name: doc['name'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }

  Future<List<PositionModel>> fetchPositions() async { // Ensure this method is defined
    try {
      QuerySnapshot snapshot = await _firestore.collection('Position').get();
      return snapshot.docs.map((doc) {
        return PositionModel(
          id: doc.id,
          name: doc['name'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching positions: $e');
      return [];
    }
  }

  Future<List<BranchModel>> fetchBranch() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Branch').get();
      return snapshot.docs.map((doc) {
        return BranchModel(
          id: doc.id,
          name: doc['name'], departmentModel: null,
        );
      }).toList();
    } catch (e) {
      print('Error fetching branch: $e');
      return [];
    }
  }
}
