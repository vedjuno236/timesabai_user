import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> getEmployeeById(String id) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection("Employee")
          .where('id', isEqualTo: id)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs[0];
      } else {
        print('Employee not found for id: $id');
        return null;
      }
    } catch (e) {
      print('Error fetching employee: $e');
      return null;
    }
  }

  // Future<PositionModel?> getPositionById(String positionId) async {
  //   print('🥴Fetching position for positionId: $positionId'); // Debug print
  //   try {
  //     DocumentSnapshot positionSnap = await _firestore
  //         .collection("Position")
  //         .doc(positionId)
  //         .get();
  //
  //     if (positionSnap.exists) {
  //       print('Debug: Position data: ${positionSnap.data()}'); // Debug print
  //       return PositionModel.fromFirestore(positionSnap);
  //     } else {
  //       print('Position not found for positionId: $positionId');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error fetching position: $e');
  //     return null;
  //   }
  // }

  // Future<DepartmentModel?> getDepartmentById(String departmentId) async {
  //   print('🥴Fetching department for departmentId: $departmentId'); // Debug print
  //   try {
  //     DocumentSnapshot departmentSnap = await _firestore
  //         .collection("Department") // Ensure this matches your Firestore collection
  //         .doc(departmentId)
  //         .get();
  //
  //     if (departmentSnap.exists) {
  //       print('Debug: Department data: ${departmentSnap.data()}'); // Debug print
  //       return DepartmentModel.fromFirestore(departmentSnap);
  //     } else {
  //       print('Department not found for departmentId: $departmentId');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error fetching department: $e');
  //     return null;
  //   }
  // }
}
