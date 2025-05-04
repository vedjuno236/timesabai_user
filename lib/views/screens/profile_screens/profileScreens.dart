import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/model/departmant_model/departmant_model.dart';
import '../../../components/model/position_model/position_model.dart';
import '../../../components/model/user_model/user_model.dart';
import '../../widgets/profile_widget/forward_button.dart';
import '../../widgets/profile_widget/setting_item.dart';
import '../../widgets/profile_widget/setting_switch.dart';
import '../login_screens/login_screens.dart';
import '../news_screens/views/news_screens.dart';
import 'edit_screen.dart';

final isDarkProvider = StateProvider<bool>((ref) => false);

class ProfileScreens extends StatefulWidget {
  const ProfileScreens({super.key});

  @override
  _ProfileScreensState createState() => _ProfileScreensState();
}

class _ProfileScreensState extends State<ProfileScreens> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getId();
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
          print("😻😻Employee Name: ${Employee.firstName}");
          print("🤧Employee Email: ${Employee.email}");
          print("👻Employee Profile Image: ${Employee.profileimage}");

          String departmentId = employeeDoc['departmentId'];
          print("🙀departmentId${departmentId}");
          DocumentReference departmentRef = FirebaseFirestore.instance
              .collection("Department")
              .doc(departmentId);

          print("Fetching department for ID: $departmentId");
          departmentRef.get().then((departmentDoc) {
            if (departmentDoc.exists) {
              setState(() {
                Employee.departmentModel =
                    DepartmentModel.fromFirestore(departmentDoc);
              });
              print("Department Name: ${Employee.departmentModel?.name}");
            } else {
              print("No department found for this employee.");
            }
          }).catchError((error) {
            print("Error fetching department: $error");
          });

          String positionId = employeeDoc['positionId'];
          DocumentReference positionRef =
              FirebaseFirestore.instance.collection("Position").doc(positionId);

          print("Fetching position for ID: $positionId");
          positionRef.get().then((positionDoc) {
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
          }).catchError((error) {
            print("Error fetching position: $error");
          });
        });
      } else {
        print("No employee found with this employeeId: ${Employee.employeeId}");
      }
    } catch (e) {
      print("Error fetching employee: $e");
    }
  }

  @override
  String selectedLanguage = "ລາວ";

  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isDarkMode =
            ref.watch(isDarkProvider); // Accessing the dark mode state

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
              backgroundColor: Color(0xFF577DF4),
              iconTheme: IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Text(
                'ຂໍ້ມູນລະບົບ',
                style: GoogleFonts.notoSansLao(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )),
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40, // Adjust the size as needed
                        backgroundImage: Employee.profileimage.isNotEmpty
                            ? NetworkImage(Employee.profileimage)
                            : const NetworkImage(
                                'https://i.pinimg.com/736x/59/37/5f/59375f2046d3b594d59039e8ffbf485a.jpg'),
                        onBackgroundImageError: (exception, stackTrace) =>
                            const Icon(Icons.error),
                        child: Employee.profileimage.isEmpty
                            ? const Icon(Icons
                                .person) // Placeholder icon if no image is provided
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Employee.employeeId,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            Employee.firstName,
                            style: GoogleFonts.notoSansLao(
                              textStyle: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ForwardButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "ການຕັ້ງຄ່າ",
                    style: GoogleFonts.notoSansLao(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SettingItem(
                    title: "ພາສາ",
                    icon: Ionicons.earth,
                    bgColor: Colors.orange.shade100,
                    iconColor: Colors.orange,
                    value: "ລາວ",
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoActionSheet(
                            title: Text(
                              'ເລືອກພາສາ',
                              style: GoogleFonts.notoSansLao(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            actions: [
                              CupertinoActionSheetAction(
                                  onPressed: () {
                                    setState(() {
                                      selectedLanguage = "ລາວ";
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "ລາວ",
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  )),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  setState(() {
                                    selectedLanguage = "English";
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("English"),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(
                                    context); // Close the modal without changing anything
                              },
                              child: const Text("Cancel"),
                            ),
                          );
                        },
                      );
                    },
                    titleColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                  const SizedBox(height: 20),
                  SettingItem(
                    title: "ຂ່າວສານຕ່າງ ແລະ ແຈ້ງການ",
                    icon: Ionicons.newspaper,
                    bgColor: Colors.orangeAccent.shade100,
                    iconColor: Colors.orangeAccent,
                    titleColor: isDarkMode ? Colors.white : Colors.black,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewsScreens(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SettingItem(
                    title: "ການແຈ້ງເຕືອນ",
                    icon: Ionicons.notifications,
                    bgColor: Colors.blue.shade100,
                    iconColor: Colors.blue,
                    titleColor: isDarkMode ? Colors.white : Colors.black,
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  SettingSwitch(
                    title: "Dark Mode",
                    icon: Ionicons.moon,
                    bgColor: Colors.purple.shade100,
                    iconColor: Colors.purple,
                    value: isDarkMode,
                    titleColor: isDarkMode ? Colors.white : Colors.black,
                    onTap: (value) {
                      ref.read(isDarkProvider.notifier).state = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  SettingItem(
                    title: "ອອກຈາກລະບົບ",
                    icon: Ionicons.log_in_outline,
                    bgColor: Colors.red.shade100,
                    iconColor: isDarkMode ? Colors.white : Colors.white,
                    titleColor: isDarkMode ? Colors.white : Colors.black,
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      // 🔥 ลบ Token ออกจาก SharedPreferences
                      await prefs.remove('token');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreens()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
