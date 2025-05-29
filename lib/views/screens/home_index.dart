import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesabai/views/screens/history_leave.dart';
import 'package:timesabai/views/screens/profile_screens/profileScreens.dart';
import 'package:timesabai/views/screens/today_screens.dart';

import '../../components/model/agencies_model.dart';
import '../../components/model/departmant_model/departmant_model.dart';
import '../../components/model/ethnicity_model.dart';
import '../../components/model/position_model/position_model.dart';
import '../../components/model/provinces_model.dart';
import '../../components/model/user_model/user_model.dart';
import 'history_com_on.dart';
import 'leave.dart';
import 'location.dart';

class HomeIndex extends StatefulWidget {
  const HomeIndex({super.key});

  @override
  State<HomeIndex> createState() => _HomeIndexState();
}

class _HomeIndexState extends State<HomeIndex> {
  double screenHeight = 0;
  double screenWidth = 0;

  List<ImageData> navigation = [
    ImageData("assets/images/home.png", "ໜ້າຫຼັກ"),
    ImageData("assets/images/news.png", "ຂໍລາພັກ"),
    ImageData("assets/images/analytic.png", "ມາການ"),
    ImageData("assets/images/calendar.png", "ລາພັກ"),
    ImageData("assets/images/user.png", "ຂໍ້ມູນສ່ວນຕົວ"),
  ];

  int currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getId();
    _loadEmployeeId();
  }

  Future<void> _loadEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      Employee.employeeId = prefs.getString('token') ?? '';
    });
  }

  void getId() async {
    try {
      // Fetch Employee Data
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: Employee.employeeId)
          .get();

      if (snap.docs.isNotEmpty) {
        DocumentSnapshot employeeDoc = snap.docs[0];

        // Collecting basic employee data
        Employee.id = employeeDoc.id;
        Employee.firstName = employeeDoc['name'] ?? '';
        Employee.email = employeeDoc['email'] ?? '';
        Employee.profileimage = employeeDoc['profileImage'] ?? '';
        Employee.qualification = employeeDoc['qualification'] ?? '';
        Employee.phone = employeeDoc['phone'] ?? '';
        Employee.birthDate = employeeDoc['dateOfBirth'] ?? '';

        print("😻😻Employee Name: ${Employee.firstName}");
        print("🤧Employee Email: ${Employee.email}");
        print("👻Employee Profile Image: ${Employee.profileimage}");

        // Fetching Department data
        String departmentId = employeeDoc['departmentId'];
        if (departmentId != null && departmentId.isNotEmpty) {
          try {
            DocumentSnapshot departmentDoc = await FirebaseFirestore.instance
                .collection("Department")
                .doc(departmentId)
                .get();

            if (departmentDoc.exists) {
              Employee.departmentModel =
                  DepartmentModel.fromFirestore(departmentDoc);
              print("Department Name: ${Employee.departmentModel?.name}");
            } else {
              print("No department found for this employee.");
            }
          } catch (error) {
            print("Error fetching department: $error");
          }
        }

        // Fetching Position data
        String positionId = employeeDoc['positionId'];
        if (positionId != null && positionId.isNotEmpty) {
          try {
            DocumentSnapshot positionDoc = await FirebaseFirestore.instance
                .collection("Position")
                .doc(positionId)
                .get();

            if (positionDoc.exists) {
              Employee.positionModel = PositionModel(
                id: positionDoc.id,
                name: positionDoc['name'],
              );
              print("Position Name: ${Employee.positionModel?.name}");
            } else {
              print("No position found for this employee.");
            }
          } catch (error) {
            print("Error fetching position: $error");
          }
        }

        // Fetching Agencies data
        String agenciesId = employeeDoc['agenciesId'];
        if (agenciesId != null && agenciesId.isNotEmpty) {
          try {
            DocumentSnapshot agenciesDoc = await FirebaseFirestore.instance
                .collection("Agencies")
                .doc(agenciesId)
                .get();

            if (agenciesDoc.exists) {
              Employee.agenciesModel = AgenciesModel(
                id: agenciesDoc.id,
                name: agenciesDoc['name'],
              );
              print("Agencies Name: ${Employee.agenciesModel?.name}");
            } else {
              print("No agencies found for this employee.");
            }
          } catch (e) {
            print("Error fetching agencies document: $e");
          }
        } else {
          print("No agencies ID found for this employee.");
        }

        // Fetching Ethnicity data
        String ethnicityId = employeeDoc['ethnicityId'];
        if (ethnicityId != null && ethnicityId.isNotEmpty) {
          try {
            DocumentSnapshot ethnicityDoc = await FirebaseFirestore.instance
                .collection("Ethnicity")
                .doc(ethnicityId)
                .get();

            if (ethnicityDoc.exists) {
              Employee.ethnicityModel = EthnicityModel(
                id: ethnicityDoc.id,
                name: ethnicityDoc['name'],
              );
              print("Ethnicity Name: ${Employee.ethnicityModel?.name}");
            } else {
              print("No ethnicity found for this employee.");
            }
          } catch (e) {
            print("Error fetching ethnicity document: $e");
          }
        } else {
          print("No ethnicity ID found for this employee.");
        }

        // Fetching Provinces data
        String provincesId = employeeDoc['provincesId'];
        if (provincesId != null && provincesId.isNotEmpty) {
          try {
            DocumentSnapshot branchDoc = await FirebaseFirestore.instance
                .collection("Provinces")
                .doc(provincesId)
                .get();

            if (branchDoc.exists) {
              Employee.provincesModel = ProvincesModel(
                id: branchDoc.id,
                name: branchDoc['name'],
              );
              print("Provinces Name: ${Employee.provincesModel?.name}");
            } else {
              print("No province found for this employee.");
            }
          } catch (e) {
            print("Error fetching provinces document: $e");
          }
        } else {
          print("No province ID found for this employee.");
        }
        setState(() {});
      } else {
        print("No employee found with this employeeId: ${Employee.employeeId}");
      }
    } catch (e) {
      print("Error fetching employee: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          currentIndex == 0 ? TodayScreens() : Container(),
          currentIndex == 1 ? Laphak() : Container(),
          new History(),
          new HistoryLeave(),
          new ProfileScreens(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 75,
        margin: const EdgeInsets.only(
          left: 0,
          right: 0,
          bottom: 0,
        ),
        decoration: const BoxDecoration(
          // color: Color(0xFFF3684E9),
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int i = 0; i < navigation.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = i;
                    });
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          navigation[i].imagePath,
                          height: i == currentIndex ? 28 : 25,
                          color: i == currentIndex
                              ? Color(0xFF577DF4)
                              : Colors.black,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          navigation[i].text,
                          style: GoogleFonts.notoSansLao(
                            color: i == currentIndex
                                ? Color(0xFF577DF4)
                                : Colors.black,
                            fontSize: i == currentIndex ? 10 : 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ImageData {
  final String imagePath;
  final String text;

  ImageData(this.imagePath, this.text);
}
