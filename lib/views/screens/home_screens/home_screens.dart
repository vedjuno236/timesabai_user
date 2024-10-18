import 'dart:async';
import 'package:geocoding/geocoding.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:timesabai/components/model/departmant_model/departmant_model.dart';
import 'package:timesabai/components/services/location_services/location_services.dart';
import '../../../components/model/position_model/position_model.dart';
import '../../../components/model/user_model/user_model.dart';
import '../../../components/services/employee_service.dart';
import '../profile_screens/profileScreens.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({Key? key}) : super(key: key);

  @override
  _HomeScreensState createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  TimeOfDay timeOfDay = TimeOfDay.now();
  String checkIn = "----/----";
  String checkOut = "----/----";
  String location = "";
  String id = "";

  @override
  void initState() {
    super.initState();
    _getRecord();
    _startLocationService();
     getId();
    // getEmployeeDetails();
  }

  void getId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Employee")
        .where('id', isEqualTo: Employee.employeeId)
        .get();

    if (snap.docs.isNotEmpty) {
      setState(() {
        Employee.id = snap.docs[0].id;
      });
    } else {
      print("No employee found with this employeeId: ${Employee.employeeId}");
    }
  }

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: Employee.id)
          .get();

      print(snap.docs[0].id);

      String todayDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(todayDate)
          .get();
      setState(() {
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
      });
    } catch (e) {
      setState(() {
        checkIn = "----/----";
        checkOut = "----/----";
      });
    }
  }

  void _startLocationService() async {
    LocationService().initialize();
    LocationService().getLongitude().then((value) {
      setState(() {
        Employee.long = value!;
      });

      LocationService().getLatitude().then((value) {
        setState(() {
          Employee.lat = value!;
        });
      });
    });
  }

  void _getLocation() async {
    try {
      List<Placemark> placemark = await placemarkFromCoordinates(
          Employee.lat, Employee.long);

      setState(() {
        location = "${placemark[0].street}, ${placemark[0]
            .administrativeArea}, ${placemark[0].postalCode}, ${placemark[0]
            .country}";
      });

      print('🙏🙏🙏🙏${placemark[0].country}');
      print('💪💪💪💪${placemark[0].name }');
      print('🙏😹${placemark[0].postalCode}');
      print('🙏${placemark[0].administrativeArea}');
    } catch (e) {
      print('Error occurred: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: PreferredSize(
      preferredSize: Size.fromHeight(100.0), // Set the desired height here
      child: AppBar(
        backgroundColor: Colors.blueAccent,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: CachedNetworkImage(
            width: 60,
            height: 60,
            imageUrl: Employee.profileimage.isNotEmpty
                ? Employee.profileimage
                : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKQcvmHvgciTlnwD21AR1C8g_GBM0ogm-7SA&s',
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    ),

        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                children: [

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Stack(
              //       children: [
              //         SizedBox(
              //           width: 70,
              //           height: 70,
              //           child: ClipRRect(
              //             borderRadius: BorderRadius.circular(100),
              //             child: CachedNetworkImage(
              //               width: 70,
              //               height: 70,
              //               imageUrl: Employee.profileimage.isNotEmpty ? Employee.profileimage
              //                   :'https://example.com/default_profile_image.png',
              //               progressIndicatorBuilder: (context, url, downloadProgress) =>
              //                   CircularProgressIndicator(value: downloadProgress.progress),
              //               errorWidget: (context, url, error) => const Icon(Icons.error),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.end,
              //       children: [
              //         Text(
              //           Employee.firstName,
              //           style: GoogleFonts.notoSansLao(
              //             textStyle: const TextStyle(
              //               fontSize: 16,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.black,
              //             ),
              //           ),
              //         ),
                  /*    Text(
                        Employee.firstName,
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),*/
              //
              //         Text(
              //           ' ຕໍາແໜ່ງ: $positionName',
              //           style: GoogleFonts.notoSansLao(
              //             textStyle: const TextStyle(
              //               fontSize: 14,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.black,
              //             ),
              //           ),
              //         ),
              //         Text(
              //           "ສັງກັດ: $departmentName",
              //           style: GoogleFonts.notoSansLao(
              //             textStyle: const TextStyle(
              //               fontSize: 14,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.black,
              //             ),
              //           ),
              //         ),




              //       ],
              //     ),
              //   ],
              // ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 250,
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
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder(
                                stream: Stream.periodic(Duration(seconds: 1)),
                                builder: (context, snaphot) {
                                  return Center(
                                    child: Text(
                                      DateFormat('hh:mm:ss ')
                                          .format(DateTime.now()),
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                DateFormat.yMMMMEEEEd('lo_LA')
                                    .format(DateTime.now()),
                                style: GoogleFonts.notoSansLao(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          width: 180,
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
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    checkIn,
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    'ໂມງເຂົ້າວຽກ',
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 120,
                          width: 180,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  checkOut,
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Text(
                                  'ໂມງອອກວຽກ',
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              checkOut.trim() == "----/----"
                  ? Container(
                      child: Builder(
                        builder: (context) {
                          final GlobalKey<SlideActionState> key = GlobalKey();
                          return SlideAction(
                            text: checkIn.trim() == "----/----"
                                ? "ກົດເພື່ອເຂົ້າວຽກ"
                                : "ກົດເພື່ອອອກວຽກ",
                            textStyle: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            outerColor: Colors.white,
                            innerColor: Colors.blueAccent,
                            key: key,
                            onSubmit: () async {
                              if (Employee.lat != 0) {
                                _getLocation();
                                QuerySnapshot snap = await FirebaseFirestore
                                    .instance
                                    .collection("Employee")
                                    .where('id', isEqualTo: Employee.id)
                                    .get();
                                String todayDate = DateFormat('dd MMMM yyyy')
                                    .format(DateTime.now());

                                DocumentSnapshot snap2 = await FirebaseFirestore
                                    .instance
                                    .collection("Employee")
                                    .doc(snap.docs[0].id)
                                    .collection("Record")
                                    .doc(todayDate)
                                    .get();

                                try {
                                  String checkIn = snap2['checkIn'];
                                  setState(() {
                                    checkOut = DateFormat('hh:mm')
                                        .format(DateTime.now());
                                  });
                                  await FirebaseFirestore.instance
                                      .collection("Employee")
                                      .doc(snap.docs[0].id)
                                      .collection("Record")
                                      .doc(todayDate)
                                      .update({
                                    'date': Timestamp.now(),
                                    'checkIn': checkIn,
                                    'checkOut': checkOut,
                                    'checkInLocation': location
                                  });
                                } catch (e) {
                                  setState(() {
                                    checkIn = DateFormat('hh:mm')
                                        .format(DateTime.now());
                                  });
                                  await FirebaseFirestore.instance
                                      .collection("Employee")
                                      .doc(snap.docs[0].id)
                                      .collection("Record")
                                      .doc(todayDate)
                                      .set({
                                    'date': Timestamp.now(),
                                    'checkIn': DateFormat('hh:mm')
                                        .format(DateTime.now()),

                                    'checkOut': "----/----",
                                    'checkOutLocation': location
                                  });
                                  print("Document created for today's date.");
                                }
                                key.currentState!.reset();
                              } else {
                                Timer(Duration(seconds: 2), () async {
                                  _getLocation();
                                  QuerySnapshot snap = await FirebaseFirestore
                                      .instance
                                      .collection("Employee")
                                      .where('id', isEqualTo: Employee.id)
                                      .get();
                                  String todayDate = DateFormat(
                                      'dd MMMM yyyy')
                                      .format(DateTime.now());

                                  DocumentSnapshot snap2 = await FirebaseFirestore
                                      .instance
                                      .collection("Employee")
                                      .doc(snap.docs[0].id)
                                      .collection("Record")
                                      .doc(todayDate)
                                      .get();

                                  try {
                                    String checkIn = snap2['checkIn'];
                                    setState(() {
                                      checkOut = DateFormat('hh:mm')
                                          .format(DateTime.now());
                                    });
                                    await FirebaseFirestore.instance
                                        .collection("Employee")
                                        .doc(snap.docs[0].id)
                                        .collection("Record")
                                        .doc(todayDate)
                                        .update({
                                      'date': Timestamp.now(),

                                      'checkIn': checkIn,
                                      'checkOut': checkOut,
                                      'checkInLocation': location,

                                    });
                                  } catch (e) {
                                    setState(() {
                                      checkIn = DateFormat('hh:mm')
                                          .format(DateTime.now());
                                    });
                                    await FirebaseFirestore.instance
                                        .collection("Employee")
                                        .doc(snap.docs[0].id)
                                        .collection("Record")
                                        .doc(todayDate)
                                        .set({
                                      'date': Timestamp.now(),
                                      'checkIn': DateFormat('hh:mm')
                                          .format(DateTime.now()),

                                      'checkOut': "----/----",
                                      'checkOutLocation': location,

                                    });
                                    print(
                                        "Document created for today's date.");
                                  }
                                  key.currentState!.reset();
                                });
                              }
                            }
                          );
                        },
                      ),
                    )
                  : Container(
                      child: Text(
                        " ບັນທືກການເຂົ້າວຽກສໍາເລັດ ! ",
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),


              SizedBox(height: 10),
             location != "" ?Column(
               children: [
                 Center(
                   child: Text("ຕໍາແໜ່າງ : "+ location,style:GoogleFonts.notoSansLao(
                       textStyle: const TextStyle(
                         fontSize: 15,
                         fontWeight: FontWeight.bold,
                         color: Colors.black38,
                       ) ),),
                 ),
               ],
             ): const SizedBox(),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('ຄໍາສັ່ງຕ່າງໆ',
                          style: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                          height: 100,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Colors
                                        .white, // Change this to any color and opacity
                                    BlendMode
                                        .srcATop, // You can use different blend modes like multiply, overlay, etc.
                                  ),
                                  child:
                                      Image.asset("assets/images/clock.png"),
                                ),
                                SizedBox(height: 5),
                                Text('ແກ້ໄຂເວລາ',
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )),
                              ],
                            ),
                          )),
                      SizedBox(width: 20),
                      GestureDetector(
                        // onTap: (){
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) =>
                        //           LaPhakScreens( ), // Pass employeeId here
                        //     ),
                        //   );
                        // },

                        child: Container(
                            height: 100,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors
                                          .white, // Change this to any color and opacity
                                      BlendMode
                                          .srcATop, // You can use different blend modes like multiply, overlay, etc.
                                    ),
                                    child: Image.asset(
                                        "assets/images/calendar.png"),
                                  ),
                                  SizedBox(height: 5),
                                  Text('ຂໍລາພັກ',
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text('ປະຫວັດຕ່າງໆ',
                          style: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                          //   onTap: () async {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) =>
                          //             HistoryScreens(), // Pass employeeId here
                          //       ),
                          //     );
                          //   },
                            child: Column(
                              children: [
                                ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Colors.blue,
                                    BlendMode.srcATop,
                                  ),
                                  child: SizedBox(
                                    width: 30, // Set the desired width
                                    height: 30, // Set the desired height
                                    child: Image.asset(
                                        "assets/images/history.png"),
                                  ),
                                ),
                                Text('ປະຫວັດມາການ',
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.blue,
                                  BlendMode.srcATop,
                                ),
                                child: SizedBox(
                                  width: 25, // Set the desired width
                                  height: 25, // Set the desired height
                                  child: Image.asset(
                                      "assets/images/calendar.png"),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text('ປະຫວັດລາພັກ',
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  )),
                            ],
                          ),
                          Column(
                            children: [
                              ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.blue,
                                  BlendMode.srcATop,
                                ),
                                child: SizedBox(
                                  width: 25, // Set the desired width
                                  height: 25, // Set the desired height
                                  child:
                                      Image.asset("assets/images/clock.png"),
                                ),
                              ),
                             const  SizedBox(
                                height: 5,
                              ),
                              Text('ປະຫວັດແກ້ເວລາ',
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  )),
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreens(), // Pass employeeId here
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Colors.blue,
                                    BlendMode.srcATop,
                                  ),
                                  child: SizedBox(
                                    width: 25, // Set the desired width
                                    height: 25, // Set the desired height
                                    child:
                                        Image.asset("assets/images/user.png"),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text('ຂໍ້ມູນສ່ວນຕົວ',
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                ],
              )
            ]),
          ),
        ));
  }
}
