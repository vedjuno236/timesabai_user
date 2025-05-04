import 'package:timesabai/components/model/branch_model.dart';
import 'package:timesabai/components/model/departmant_model/departmant_model.dart';
import 'package:timesabai/components/model/position_model/position_model.dart';

import '../agencies_model.dart';
import '../ethnicity_model.dart';
import '../provinces_model.dart';

class Employee {
  static String id = "";
  static String employeeId = "";
  static String gender="";
  static String career="";
  static String village="";
  static String reponsible="";
  static String graduated="";
  static String nationality="";
  static String status="";
  static double lat = 0;
  static double long = 0;
  static String firstName = "";
  static String qualification ="";
  static String email = "";
  static String phone = "";
  static String birthDate = "";
  static String profileimage="";
  static DepartmentModel? departmentModel;
  static PositionModel? positionModel;
  static BranchModel? branchModel;
  static EthnicityModel? ethnicityModel;
  static ProvincesModel? provincesModel;
  static AgenciesModel? agenciesModel;
  static bool canEdit = true;

  static String? getPosition(){
    return positionModel?.name;
  }
}
