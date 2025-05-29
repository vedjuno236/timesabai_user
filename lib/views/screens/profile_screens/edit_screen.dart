import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesabai/components/model/agencies_model.dart';
import 'package:timesabai/components/model/provinces_model.dart';
import 'package:timesabai/views/screens/home_index.dart';
import 'package:timesabai/views/screens/profile_screens/profileScreens.dart';
import 'package:timesabai/views/widgets/loading_platform/loading_platform.dart';
import '../../../components/model/departmant_model/departmant_model.dart';
import '../../../components/model/ethnicity_model.dart';
import '../../../components/model/position_model/position_model.dart';
import '../../../components/model/user_model/user_model.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});
  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> Itemsix = ['ຍີງ', 'ຊາຍ'];
  String? selectedGender;
  String? selectedItem;

  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _cities = [];
  String? _selectedProvince;
  String? _selectedCity;

  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _branches = [];
  String? _selectedDepartment;
  String? _selectedBranch;

  List<Map<String, dynamic>> _possitions = [];
  String? selectedPositionId;

  List<Map<String, dynamic>> _ethnicity = [];
  String? selectedEthnicityId;

  List<Map<String, dynamic>> _agencies = [];
  String? selectedAgenciesId;

  bool isLoading = false;
  File? _profileImage;

  List<String> Item = ['ປະລີນຍາເອກ', 'ປະລີນຍາໂທ', 'ປະລີນຍາຕີ', 'ຊັ້ນສູງ'];

  Future<void> _fetchAgencies() async {
    try {
      final querySnapshot = await _firestore.collection('Agencies').get();
      final agencies = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();

      setState(() {
        _agencies = agencies;
      });
    } catch (error) {
      print("Failed to fetch agencies: $error");
    }
  }

  Future<void> _fetchEthnicity() async {
    try {
      final querySnapshot = await _firestore.collection('Ethnicity').get();
      final ethnicity = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();

      setState(() {
        _ethnicity = ethnicity;
      });
    } catch (error) {
      print("Failed to fetch ethnicities: $error");
    }
  }

  Future<void> _fetchPositions() async {
    try {
      final querySnapshot = await _firestore.collection('Position').get();
      final possitions = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();

      setState(() {
        _possitions = possitions;
      });
    } catch (error) {
      print("Failed to fetch departments: $error");
    }
  }

  Future<void> _fetchDepartments() async {
    try {
      final querySnapshot = await _firestore.collection('Department').get();
      final departments = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();

      setState(() {
        _departments = departments;
      });
    } catch (error) {
      print("Failed to fetch departments: $error");
    }
  }

  // Fetch branches based on selected department
  Future<void> _fetchBranch(String departmentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('Branch')
          .where('departmentId', isEqualTo: departmentId)
          .get();

      final branches = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();

      setState(() {
        _branches = branches;
      });
    } catch (error) {
      print("Failed to fetch branches: $error");
    }
  }

  void _onDepartmentSelected(String? departmentId) {
    setState(() {
      _selectedDepartment = departmentId;
      _selectedBranch = null;
      _branches = [];
    });

    if (departmentId != null) {
      _fetchBranch(departmentId);
    }
  }

  // Fetch provinces from Firestore
  Future<void> _fetchProvinces() async {
    try {
      final querySnapshot = await _firestore.collection('Provinces').get();
      final provinces = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();

      setState(() {
        _provinces = provinces;
      });
    } catch (error) {
      print("Failed to fetch provinces: $error");
    }
  }

  // Fetch cities based on selected province
  Future<void> _fetchCities(String provinceId) async {
    try {
      final querySnapshot = await _firestore
          .collection('Districts')
          .where('provincesId', isEqualTo: provinceId)
          .get();

      final cities = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();

      setState(() {
        _cities = cities;
      });
    } catch (error) {
      print("Failed to fetch cities: $error");
    }
  }

  void _onProvinceSelected(String? provinceId) {
    setState(() {
      _selectedProvince = provinceId;
      _selectedCity = null;
      _cities = [];
    });
    Navigator.pop(context);

    if (provinceId != null) {
      _fetchCities(provinceId);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
    _fetchDepartments();
    _fetchPositions();
    _fetchEthnicity();
    _fetchAgencies();
    selectedGender = Itemsix[0];
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _txtNameController = TextEditingController();
  final TextEditingController _txtEmailController = TextEditingController();
  final TextEditingController _txtStyController = TextEditingController();
  final TextEditingController _txtPhoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _reponsibleController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _graduatedController = TextEditingController();
  final TextEditingController _careerController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    _txtNameController.dispose();
    _txtEmailController.dispose();
    _txtStyController.dispose();
    _txtPhoneController.dispose();
    _dateController.dispose();
    _villageController.dispose();
    _reponsibleController.dispose();
    _nationalityController.dispose();
    _graduatedController.dispose();
    _careerController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEmployeeId();
    getId();
  }

  Future<void> _loadEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      Employee.employeeId = prefs.getString('token') ?? '';
    });
  }

  Future<void> getId() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: Employee.employeeId)
          .get();

      if (snap.docs.isNotEmpty) {
        DocumentSnapshot employeeDoc = snap.docs[0];
        setState(() {
          Employee.id = employeeDoc.id;
          Employee.firstName = employeeDoc['name'] ?? '';
          Employee.email = employeeDoc['email'] ?? '';
          Employee.profileimage = employeeDoc['profileImage'] ?? '';
          Employee.qualification = employeeDoc['qualification'] ?? '';
          Employee.phone = employeeDoc['phone'] ?? '';
          Employee.birthDate = employeeDoc['dateOfBirth'] ?? '';
          Employee.gender = employeeDoc['gender'] ?? '';
          Employee.career = employeeDoc['career'] ?? '';
          Employee.village = employeeDoc['village'] ?? '';
          Employee.graduated = employeeDoc['graduated'] ?? '';
          Employee.reponsible = employeeDoc['reponsible'] ?? '';
          Employee.nationality = employeeDoc['nationality'] ?? '';
          Employee.status = employeeDoc['status'] ?? '';
          _txtNameController.text = Employee.firstName;
          _txtEmailController.text = Employee.email;
          selectedItem = Employee.qualification;
          _txtPhoneController.text = Employee.phone;
          _dateController.text = Employee.birthDate;
          _villageController.text = Employee.village;
          _graduatedController.text = Employee.graduated;
          _careerController.text = Employee.career;
          _reponsibleController.text = Employee.reponsible;
          _nationalityController.text = Employee.nationality;
          _statusController.text = Employee.status;
          selectedGender = Employee.gender;
          selectedPositionId = Employee.positionModel?.id ?? '';

          _selectedDepartment = Employee.departmentModel?.id ?? '';
          selectedAgenciesId = Employee.agenciesModel?.id ?? '';
          selectedEthnicityId = Employee.ethnicityModel?.id ?? '';
          _selectedProvince = Employee.provincesModel?.id ?? '';
        });

        String agenciesId = employeeDoc['agenciesId'];
        print("agencies ID: $agenciesId");

        if (agenciesId != null && agenciesId.isNotEmpty) {
          try {
            DocumentSnapshot DepartmentDoc = await FirebaseFirestore.instance
                .collection("Agencies")
                .doc(agenciesId)
                .get();

            if (DepartmentDoc.exists) {
              setState(() {
                Employee.agenciesModel = AgenciesModel(
                  id: DepartmentDoc.id,
                  name: DepartmentDoc['name'],
                );
              });
              print("Agencies Name: ${Employee.agenciesModel?.name}");
            } else {
              print(
                  "No ethnicity found for this employee with ID: $agenciesId");
              print("Ethnicity document does not exist in Firestore.");
            }
          } catch (e) {
            print("Error fetching ethnicity document: $e");
          }
        } else {
          print("No ethnicity ID found for this employee.");
        }

        // Fetch Ethnicity
        String ethnicityId = employeeDoc['ethnicityId'];
        print("ethnicity ID: $ethnicityId");

        if (ethnicityId != null && ethnicityId.isNotEmpty) {
          try {
            DocumentSnapshot DepartmentDoc = await FirebaseFirestore.instance
                .collection("Ethnicity")
                .doc(ethnicityId)
                .get();

            if (DepartmentDoc.exists) {
              setState(() {
                Employee.ethnicityModel = EthnicityModel(
                  id: DepartmentDoc.id,
                  name: DepartmentDoc['name'],
                );
              });
              print("Agencies Name: ${Employee.ethnicityModel?.name}");
            } else {
              print(
                  "No ethnicity found for this employee with ID: $ethnicityId");
              print("Ethnicity document does not exist in Firestore.");
            }
          } catch (e) {
            print("Error fetching ethnicity document: $e");
          }
        } else {
          print("No ethnicity ID found for this employee.");
        }

        // Fetch Position
        String positionId = employeeDoc['positionId'];
        print("Position ID: $positionId");

        if (positionId != null && positionId.isNotEmpty) {
          try {
            DocumentSnapshot positionDoc = await FirebaseFirestore.instance
                .collection("Position")
                .doc(positionId)
                .get();

            if (positionDoc.exists) {
              setState(() {
                Employee.positionModel = PositionModel(
                  id: positionDoc.id,
                  name: positionDoc['name'],
                );
              });
              print("Position Name: ${Employee.positionModel?.name}");
            } else {
              print("No position found for this employee.");
            }
          } catch (e) {
            print("Error fetching position document: $e");
          }

          String departmentId = employeeDoc['departmentId'];
          print("department ID: $departmentId");

          if (departmentId != null && departmentId.isNotEmpty) {
            try {
              DocumentSnapshot DepartmentDoc = await FirebaseFirestore.instance
                  .collection("Department")
                  .doc(departmentId)
                  .get();

              if (DepartmentDoc.exists) {
                setState(() {
                  Employee.departmentModel = DepartmentModel(
                    id: DepartmentDoc.id,
                    name: DepartmentDoc['name'],
                  );
                });
                print("Department Name: ${Employee.departmentModel?.name}");
              } else {
                print(
                    "No ethnicity found for this employee with ID: $departmentId");
                print("Ethnicity document does not exist in Firestore.");
              }
            } catch (e) {
              print("Error fetching ethnicity document: $e");
            }
          } else {
            print("No ethnicity ID found for this employee.");
          }

          String provincesId = employeeDoc['provincesId'];
          print("provinces ID: $provincesId");

          if (provincesId != null && provincesId.isNotEmpty) {
            try {
              DocumentSnapshot branchDoc = await FirebaseFirestore.instance
                  .collection("Provinces")
                  .doc(provincesId)
                  .get();

              if (branchDoc.exists) {
                setState(() {
                  Employee.provincesModel = ProvincesModel(
                    id: branchDoc.id,
                    name: branchDoc['name'],
                  );
                });
                print("provinces Name: ${Employee.provincesModel?.name}");
              } else {
                print(
                    "No ethnicity found for this employee with ID: $departmentId");
                print("Ethnicity document does not exist in Firestore.");
              }
            } catch (e) {
              print("Error fetching ethnicity document: $e");
            }
          } else {
            print("No ethnicity ID found for this employee.");
          }
        } else {
          print("No position ID found for this employee.");
        }
      } else {
        print("No employee found with this employeeId: ${Employee.employeeId}");
      }
    } catch (e) {
      print("Error fetching employee: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? date = DateTime.tryParse(Employee.birthDate);
    String formattedDate =
        date != null ? DateFormat('dd/MM/yyyy').format(date) : "";

    Future<void> _pickImageFromGallery() async {
      final returnImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (returnImage != null && returnImage.path.isNotEmpty) {
        setState(() {
          _profileImage = File(returnImage.path);
        });
      }
      Navigator.pop(context);
    }

    Future<void> _pickImageFromCamera() async {
      final returnImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (returnImage != null && returnImage.path.isNotEmpty) {
        setState(() {
          _profileImage = File(returnImage.path);
        });
      }
      Navigator.pop(context);
    }

    void showProfileImage(BuildContext context) {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 6.5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromGallery(); // Pick image from gallery
                      },
                      child: SizedBox(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.image,
                              size: 30,
                              color: Color(0xFF577DF4),
                            ),
                            Text(
                              "ເລືອກຈາກອະລາບໍ້າ",
                              style: GoogleFonts.notoSansLao(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromCamera(); // Pick image from camera
                      },
                      child: SizedBox(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF577DF4),
                              // color: Colors.blue,
                              size: 30,
                            ),
                            Text(
                              "ກ້ອງຖ່າຍຮູບ",
                              style: GoogleFonts.notoSansLao(fontSize: 17),
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
        },
      );
    }

    Future<void> updateEmployee() async {
      String employeeId = Employee.id;
      String? imageUrl;

      if (_profileImage != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images/$employeeId.jpg');
          await storageRef.putFile(_profileImage!);
          imageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          print("Error uploading image: $e");
          return;
        }
      }

      try {
        final updateData = {
          'name': _txtNameController.text,
          'email': _txtEmailController.text,
          'phone': _txtPhoneController.text,
          'dateOfBirth': _dateController.text,
          'departmentId': _selectedDepartment ?? '',
          'positionId': selectedPositionId ?? '',
          'branchId': _selectedBranch ?? '',
          'provincesId': _selectedProvince ?? '',
          'ethnicityId': selectedEthnicityId ?? '',
          'city': _selectedCity ?? '',
          'gender': selectedGender ?? '',
          'village': _villageController.text,
          'reponsible': _reponsibleController.text,
          'nationality': _nationalityController.text,
          'graduated': _graduatedController.text,
          'career': _careerController.text,
          'status': _statusController.text,
          'agenciesId': selectedAgenciesId ?? '',
          'qualification': selectedItem ?? ''
        };
        if (imageUrl != null) {
          updateData['profileImage'] = imageUrl;
        }

        await FirebaseFirestore.instance
            .collection('Employee')
            .doc(employeeId)
            .update(updateData);
        print("Employee updated successfully");
        Fluttertoast.showToast(
          msg: 'ບັນທືກສໍາເລັດ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        await getId();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeIndex()),
        );
      } catch (e) {
        print("Error updating employee: $e");
      }
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF577DF4),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            'ແກ້ໄຂຂໍ້ມູນສ່ວນຕົວ',
            style: GoogleFonts.notoSansLao(
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: [
                Container(
                  height: 145,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 55,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: _profileImage != null
                                      ? Image.file(
                                          _profileImage!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: Employee
                                                  .profileimage.isNotEmpty
                                              ? Employee.profileimage
                                              : 'https://i.pinimg.com/736x/59/37/5f/59375f2046d3b594d59039e8ffbf485a.jpg',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              const LoadingPlatformV1(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                ),
                              ),
                            ),
                          ).animate().scaleXY(
                              begin: 0,
                              end: 1,
                              delay: 300.ms,
                              duration: 300.ms,
                              curve: Curves.easeInOutCubic),
                          Positioned(
                            bottom: 3,
                            left: 200,
                            child: GestureDetector(
                              onTap: () {
                                showProfileImage(context);
                              },
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.blue,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Text(
                          "ID:${Employee.employeeId}",
                          style: GoogleFonts.notoSansLao(
                            textStyle: TextStyle(
                                fontSize: 15, color: Colors.grey.shade600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 850,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2), // Color of shadow
                        spreadRadius: 1, // Spread radius
                        blurRadius: 7, // Blur radius
                        offset: Offset(0, 1), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      cursorColor: Colors.purple,
                                      controller: _txtNameController,
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: TextStyle(fontSize: 16),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: Employee.firstName.isNotEmpty
                                            ? Employee.firstName
                                            : "ປ້ອນຊື່",
                                        hintStyle: GoogleFonts.notoSansLao(
                                          textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.black12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.black12),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.perm_identity,
                                          color: Colors.black38,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          10), // Space between the TextFormField and DropdownButton
                                  Container(
                                    height: 58,
                                    width: 120, // Fixed width for consistency
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.black12,
                                        width: 2,
                                      ),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Show Cupertino modal popup when tapped
                                        showCupertinoModalPopup(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CupertinoActionSheet(
                                              title: Text('ເລືອກເພດ',
                                                  style: GoogleFonts
                                                      .notoSansLao()),
                                              actions:
                                                  Itemsix.map((String gender) {
                                                return CupertinoActionSheetAction(
                                                  onPressed: () {
                                                    setState(() {
                                                      selectedGender = gender;
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    gender,
                                                    style:
                                                        GoogleFonts.notoSansLao(
                                                      textStyle:
                                                          const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              cancelButton:
                                                  CupertinoActionSheetAction(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'ຍົກເລີກ',
                                                  style:
                                                      GoogleFonts.notoSansLao(
                                                    textStyle: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            selectedGender ?? 'ເລືອກເພດ',
                                            style: GoogleFonts.notoSansLao(
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.arrow_drop_down),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      cursorColor: Colors.purple,
                                      controller: _txtEmailController,
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: Employee.email.isNotEmpty
                                            ? Employee.email
                                            : "ປ້ອນ ອິເມວ",
                                        hintStyle: GoogleFonts.notoSansLao(
                                          textStyle: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey.shade600),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.black12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.black12),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: Colors.black38,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 58,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black12,
                                width: 2,
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                // Show Cupertino modal popup when tapped
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoActionSheet(
                                      title: Text('ວຸດທິການສືກສາ',
                                          style: GoogleFonts.notoSansLao()),
                                      actions: Item.map((String item) {
                                        return CupertinoActionSheetAction(
                                          onPressed: () {
                                            setState(() {
                                              selectedItem = item;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            item,
                                            style: GoogleFonts.notoSansLao(
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      cancelButton: CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'ຍົກເລີກ',
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedItem ?? 'ເລືອກລະດັບການສືກສາ',
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  cursorColor: Colors.purple,
                                  controller: _txtPhoneController,
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: Employee.phone.isNotEmpty
                                        ? Employee.phone
                                        : "ປ້ອນ ເບີ",
                                    hintStyle: GoogleFonts.notoSansLao(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.phone,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          color: Colors.white,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Icon(Icons.close),
                                              ),
                                              Expanded(
                                                child: CupertinoDatePicker(
                                                  initialDateTime: selectedDate,
                                                  mode: CupertinoDatePickerMode
                                                      .date,
                                                  onDateTimeChanged: (date) {
                                                    setState(() {
                                                      selectedDate = date;
                                                      _dateController.text =
                                                          "${selectedDate.toLocal()}"
                                                                  .split(' ')[
                                                              0]; // Update the controller with the new date
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      controller: _dateController,
                                      cursorColor: Colors.white,
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: formattedDate.isNotEmpty
                                            ? formattedDate
                                            : "ວັນເດືອນປີເກີດ",
                                        hintStyle: GoogleFonts.notoSansLao(
                                          textStyle: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black54),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.date_range_sharp,
                                          color: Colors.black38,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.black12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.black12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: 400,
                            height: 55,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoActionSheet(
                                      title: Text('ເລືອກຕໍາແໜ່ງ',
                                          style: GoogleFonts.notoSansLao()),
                                      actions: _possitions.map((position) {
                                        return CupertinoActionSheetAction(
                                          onPressed: () {
                                            setState(() {
                                              selectedPositionId =
                                                  position['id'];
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            position['name'] ?? '',
                                            style: GoogleFonts.notoSansLao(),
                                          ),
                                        );
                                      }).toList(),
                                      cancelButton: CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'ຍົກເລີກ',
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 400,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_drop_down),
                                    Text(
                                      selectedPositionId == null
                                          ? 'ເລືອກຕໍາແໜ່ງ' // Default hint text
                                          : _possitions.firstWhere((position) =>
                                                  position['id'] ==
                                                  selectedPositionId)['name'] ??
                                              '',
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 170,
                                height: 55,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    // Open Cupertino modal popup when tapped
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CupertinoActionSheet(
                                          title: Text('ເລືອກພະແນກ',
                                              style: GoogleFonts.notoSansLao()),
                                          actions: _agencies.map((agencies) {
                                            return CupertinoActionSheetAction(
                                              onPressed: () {
                                                setState(() {
                                                  selectedAgenciesId = agencies[
                                                      'id']; // Update selected position ID
                                                });
                                                Navigator.pop(
                                                    context); // Close modal after selection
                                              },
                                              child: Text(
                                                agencies['name'] ?? '',
                                                style:
                                                    GoogleFonts.notoSansLao(),
                                              ),
                                            );
                                          }).toList(),
                                          cancelButton:
                                              CupertinoActionSheetAction(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'ຍົກເລີກ',
                                              style: GoogleFonts.notoSansLao(
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 400,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_drop_down),
                                        Text(
                                          selectedAgenciesId == null
                                              ? 'ເລືອກພະແນກ' // Default hint text
                                              : _agencies.firstWhere((agencies) =>
                                                          agencies['id'] ==
                                                          selectedAgenciesId)[
                                                      'name'] ??
                                                  '',
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                width: 170,
                                height: 55,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.6,
                                          child: CupertinoActionSheet(
                                            title: Text(
                                                Employee.ethnicityModel?.name ??
                                                    'ເລືອກຊົນເຜົ່າ',
                                                style:
                                                    GoogleFonts.notoSansLao()),
                                            actions:
                                                _ethnicity.map((ethnicity) {
                                              return CupertinoActionSheetAction(
                                                onPressed: () {
                                                  setState(() {
                                                    selectedEthnicityId = ethnicity[
                                                        'id']; // Update selected ethnicity
                                                  });
                                                  Navigator.pop(
                                                      context); // Close the modal after selection
                                                },
                                                child: Text(
                                                  ethnicity['name'] ?? '',
                                                  style:
                                                      GoogleFonts.notoSansLao(),
                                                ),
                                              );
                                            }).toList(),
                                            cancelButton:
                                                CupertinoActionSheetAction(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'ຍົກເລີກ',
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 400,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_drop_down),
                                        Text(
                                          selectedEthnicityId == null
                                              ? 'ເລືອກຊົນເຜົ່າ'
                                              : _ethnicity.firstWhere(
                                                      (ethnicity) =>
                                                          ethnicity['id'] ==
                                                          selectedEthnicityId)[
                                                  'name'],
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.6,
                                          child: CupertinoActionSheet(
                                            title: Text(
                                              Employee.provincesModel?.name ??
                                                  'ເລືອກແຂວງ',
                                              style: GoogleFonts.notoSansLao(
                                                textStyle:
                                                    TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            actions: _provinces.map((province) {
                                              return CupertinoActionSheetAction(
                                                onPressed: () {
                                                  _onProvinceSelected(
                                                      province['id']!);
                                                },
                                                child: Text(
                                                  province['name'] ?? '',
                                                  style:
                                                      GoogleFonts.notoSansLao(
                                                    textStyle:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            cancelButton:
                                                CupertinoActionSheetAction(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'ຍົກເລີກ',
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 55,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedProvince == null
                                              ? 'ເລືອກແຂວງ' // Hint text when no province is selected
                                              : _provinces.firstWhere(
                                                  (province) =>
                                                      province['id'] ==
                                                      _selectedProvince,
                                                  orElse: () =>
                                                      {'name': ''})['name']!,
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54),
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.6,
                                          child: CupertinoActionSheet(
                                            title: Text(
                                              'ເລືອກເມືອງ',
                                              style: GoogleFonts.notoSansLao(
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                            actions: _selectedProvince !=
                                                        null &&
                                                    _cities.isNotEmpty
                                                ? _cities.map((city) {
                                                    return CupertinoActionSheetAction(
                                                      onPressed: () {
                                                        setState(() {
                                                          _selectedCity =
                                                              city['id'];
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        city['name'],
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                          textStyle:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList()
                                                : [
                                                    CupertinoActionSheetAction(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        'ເລຶອກແຂວງກ່ອນ',
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                          textStyle:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                            cancelButton:
                                                CupertinoActionSheetAction(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'ຍົກເລີກ',
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 55,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedCity == null
                                              ? 'ເລືອກເມືອງ' // Hint text
                                              : _cities.firstWhere(
                                                  (city) =>
                                                      city['id'] ==
                                                      _selectedCity,
                                                  orElse: () => {'name': ''},
                                                )['name']!,
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              color:
                                                  Colors.black54, // Text color
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  cursorColor: Colors.purple,
                                  controller: _villageController,
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "ບ້ານ",
                                    hintStyle: GoogleFonts.notoSansLao(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.villa_outlined,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFormField(
                                  cursorColor: Colors.purple,
                                  controller: _statusController,
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "ສະຖານະພາບ",
                                    hintStyle: GoogleFonts.notoSansLao(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.baby_changing_station_sharp,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Department Dropdown
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // Show Cupertino Modal for Department
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CupertinoActionSheet(
                                          title: Text(
                                            'ເລືອກພາກວິຊາ',
                                            style: GoogleFonts.notoSansLao(
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                          actions:
                                              _departments.map((department) {
                                            return CupertinoActionSheetAction(
                                              onPressed: () {
                                                _onDepartmentSelected(
                                                    department['id']);
                                                Navigator.pop(
                                                    context); // Close the popup after selection
                                              },
                                              child: Text(
                                                department['name'],
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          cancelButton:
                                              CupertinoActionSheetAction(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'ຍົກເລີກ',
                                              style: GoogleFonts.notoSansLao(
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 55,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedDepartment == null
                                              ? 'ເລືອກພາກວິຊາ'
                                              : _departments.firstWhere(
                                                  (department) =>
                                                      department['id'] ==
                                                      _selectedDepartment,
                                                  orElse: () => {'name': ''},
                                                )['name']!,
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Branch Dropdown
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_selectedDepartment != null &&
                                        _branches.isNotEmpty) {
                                      // Show Cupertino Modal for Branch
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CupertinoActionSheet(
                                            title: Text(
                                              'ເລືອກສາຂາ',
                                              style: GoogleFonts.notoSansLao(
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                            actions: _branches.map((branch) {
                                              return CupertinoActionSheetAction(
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedBranch =
                                                        branch['id'];
                                                  });
                                                  Navigator.pop(
                                                      context); // Close the popup after selection
                                                },
                                                child: Text(
                                                  branch['name'],
                                                  style:
                                                      GoogleFonts.notoSansLao(
                                                    textStyle: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            cancelButton:
                                                CupertinoActionSheetAction(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'ຍົກເລີກ',
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 55,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedBranch == null
                                              ? 'ເລືອກສາຂາ'
                                              : _branches.firstWhere(
                                                  (branch) =>
                                                      branch['id'] ==
                                                      _selectedBranch,
                                                  orElse: () => {'name': ''},
                                                )['name']!,
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  cursorColor: Colors.purple,
                                  controller: _reponsibleController,
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "ໜ້າທີຮັບຜິດຊອບ",
                                    hintStyle: GoogleFonts.notoSansLao(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.work,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      10), // Add spacing between the two fields
                              Expanded(
                                child: TextFormField(
                                  cursorColor: Colors.purple,
                                  controller: _nationalityController,
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "ຊັນຊາດ",
                                    hintStyle: GoogleFonts.notoSansLao(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.face_retouching_natural_outlined,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your qualification';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  cursorColor: Colors.purple,
                                  controller: _graduatedController,
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "ສະຖານທີຈົບການສຶກສາ",
                                    hintStyle: GoogleFonts.notoSansLao(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.cast_for_education,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      10), // Add spacing between the two fields
                              Expanded(
                                child: TextFormField(
                                  cursorColor: Colors.purple,
                                  controller: _careerController,
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "ວິຊາສະເພາະ",
                                    hintStyle: GoogleFonts.notoSansLao(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.subject,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your qualification';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      updateEmployee();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ProfileScreens()));
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? Text(
                                      'ກໍາລັງບັນທືກ....',
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'ບັນທືກ',
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
