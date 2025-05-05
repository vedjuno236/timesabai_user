import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/components/checkbox/gf_checkbox.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_alert/status_alert.dart';
import 'package:timesabai/components/constants/strings.dart';
import 'package:timesabai/views/screens/home_index.dart';
import 'package:timesabai/views/widgets/loading_platform/loading_platform.dart';

import '../../../components/model/user_model/user_model.dart';

class LoginScreens extends StatefulWidget {
  const LoginScreens({Key? key}) : super(key: key);

  @override
  _LoginScreensState createState() => _LoginScreensState();
}

class _LoginScreensState extends State<LoginScreens> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _txtIDcontroller = TextEditingController();
  final TextEditingController _txtPasswordcontroller = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = true;
  bool isChecked = false;

  // Future<void> login() async {
  //   if (_formKey.currentState?.validate() ?? false) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //
  //     try {
  //       String id = _txtIDcontroller.text.trim();
  //       String password = _txtPasswordcontroller.text.trim();
  //
  //       if (id.isEmpty) {
  //         _showSnackbar("Employee ID is still empty");
  //       } else if (password.isEmpty) {
  //         _showSnackbar("Password is still empty");
  //       } else {
  //         QuerySnapshot snap = await FirebaseFirestore.instance
  //             .collection("Employee")
  //             .where('id', isEqualTo: id)
  //             .get();
  //
  //         if (snap.docs.isNotEmpty) {
  //           print(snap.docs[0]['id']);
  //
  //           // Set the employee ID here
  //           Employee.employeeId = id;  // Update Employee's ID
  //
  //           sharedPreferences = await SharedPreferences.getInstance();
  //           await sharedPreferences.setString('token', id);
  //
  //           Navigator.pushReplacement(
  //               context,
  //               MaterialPageRoute(builder: (context) => const HomeIndex())
  //           );
  //         } else {
  //           _showSnackbar("No employee found with this ID");
  //         }
  //       }
  //     } catch (e) {
  //       _showSnackbar("An error occurred: $e");
  //     } finally {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }

  Future<void> login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      try {
        String id = _txtIDcontroller.text.trim();
        String password = _txtPasswordcontroller.text.trim();

        if (id.isEmpty) {
          StatusAlert.show(
            context,
            duration: Duration(seconds: 2),
            title: 'Sign In Failed',
            subtitle: 'Employee ID is still empty',
            configuration: IconConfiguration(icon: Icons.error_outline_sharp),
            maxWidth: 300,
          );
        } else if (password.isEmpty) {
          StatusAlert.show(
            context,
            title: 'Sign In Failed !!!',
            subtitle: 'Password is still empty',
            titleOptions: StatusAlertTextConfiguration(
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitleOptions: StatusAlertTextConfiguration(
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.white,
            configuration: const IconConfiguration(
              icon: Icons.error_outline_sharp,
              size: 20,
            ),
            maxWidth: 260,
            duration: Duration(seconds: 2),
          );
        } else {
          QuerySnapshot snap = await FirebaseFirestore.instance
              .collection("Employee")
              .where('id', isEqualTo: id)
              .get();

          if (snap.docs.isNotEmpty) {
            String storedPassword = snap.docs[0]['password'];
            if (storedPassword == password) {
              Employee.employeeId = id;
              sharedPreferences = await SharedPreferences.getInstance();
              await sharedPreferences.setString('token', id);
              StatusAlert.show(
                context,
                duration: Duration(seconds: 2),
                subtitle: 'ເຂົ້າສູ່ລະບົບສໍາເລັດ.',
                subtitleOptions: StatusAlertTextConfiguration(
                  style: GoogleFonts.notoSansLao(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                configuration: IconConfiguration(icon: Icons.done),
                maxWidth: 300,
              );
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeIndex()));
            } else {
              StatusAlert.show(
                context,
                title: 'ການເຂົ້າສູ່ລະບົບລົ້ມຫຼ້ຽວ ..',
                subtitle: 'ລະຫັດຜ່ານບໍ່ຖືກ',
                titleOptions: StatusAlertTextConfiguration(
                  style: GoogleFonts.notoSansLao(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                subtitleOptions: StatusAlertTextConfiguration(
                  style: GoogleFonts.notoSansLao(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                backgroundColor: Colors.white,
                configuration: const IconConfiguration(
                  icon: Icons.error_outline_sharp,
                  size: 90,
                ),
                maxWidth: 260,
                duration: Duration(seconds: 5),
              );
            }
          } else {
            StatusAlert.show(
              context,
              title: 'ການເຂົ້າສູ່ລະບົບລົ້ມຫຼ້ຽວ ..',
              subtitle: ' ID ບໍ່ຖືກ',
              titleOptions: StatusAlertTextConfiguration(
                style: GoogleFonts.notoSansLao(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              subtitleOptions: StatusAlertTextConfiguration(
                style: GoogleFonts.notoSansLao(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              configuration: const IconConfiguration(
                icon: Icons.error_outline_sharp,
                size: 90,
              ),
              maxWidth: 260,
              duration: Duration(seconds: 5),
            );
          }
        }
      } catch (e) {
        StatusAlert.show(
          context,
          duration: Duration(seconds: 2),
          title: 'Sign In Failed',
          subtitle: 'An error occurred: $e',
          configuration: IconConfiguration(icon: Icons.error_outline_sharp),
          maxWidth: 300,
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: CustomProgressHUD(
          key: UniqueKey(),
          inAsyncCall: isLoading,
          opacity: .7,
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/back.svg',
                        fit: BoxFit.cover,
                        height: 300,
                        width: double.infinity,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            const Image(
                              image: AssetImage('assets/images/images.png'),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              'ມະຫາວິທະຍາໄລ ສຸພານຸວົງ',
                              style: GoogleFonts.notoSansLao(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black38,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ' ຄະນະວິສະວະກໍາສາດ',
                              style: GoogleFonts.notoSansLao(
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black38,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'ລະບົບກວດສອບເຂົ້າ-ອອກວຽກ \n ພະນັກງານ',
                              style: GoogleFonts.notoSansLao(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black38,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          TextFormField(
                            cursorColor: Colors.purple,
                            controller: _txtIDcontroller,
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            decoration: InputDecoration(
                              hintText: "ປ້ອນໄອດີ",
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              prefixIcon: const Icon(
                                Icons.perm_identity,
                                color: Colors.black38,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            cursorColor: Colors.purple,
                            controller: _txtPasswordcontroller,
                            obscureText: isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: "ປ້ອນລະຫັດຜ່ານ",
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.black38,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                                child: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              GFCheckbox(
                                size: 25,
                                activeBgColor: Colors.red,
                                type: GFCheckboxType.square,
                                onChanged: (value) {
                                  setState(() {
                                    isChecked = value;
                                  });
                                },
                                value: isChecked,
                                inactiveIcon: null,
                              ),
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'ຈື່ໄອດີ ແລະ ລະຫັດຂ້ອຍໄວ້',
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black38,
                                      ),
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                Strings.txtForget,
                                style: GoogleFonts.notoSansLao(
                                  textStyle: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        await Future.delayed(
                                            const Duration(seconds: 1));

                                        login();

                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
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
                                      'ກໍາລັງເຂົ້າສູ່ລະບົບ.....',
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'ເຂົ້າສູ່ລະບົບ',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
