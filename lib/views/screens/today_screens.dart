import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:slide_to_act/slide_to_act.dart';
import 'package:status_alert/status_alert.dart';
import '../../components/model/user_model/user_model.dart';

class TodayScreens extends StatefulWidget {
  const TodayScreens({super.key});
  @override
  State<TodayScreens> createState() => _TodayScreensState();
}

class _TodayScreensState extends State<TodayScreens> {
  TimeOfDay timeOfDay = TimeOfDay.now();
  String checkIn = "----/----";
  String checkOut = "----/----";
  String location = "";
  bool isLoading = true;

  late GoogleMapController mapController;
  loc.LocationData? _currentLocation;
  final loc.Location _locationService = loc.Location(); // Using the alias here
  String address = 'Fetching address...';

  @override
  void initState() {
    super.initState();
    _getRecord();
    _getCurrentLocation();
    fetchImages();
  }

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: Employee.employeeId)
          .get();

      print(snap.docs[0].id);

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
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

  Future<void> _getCurrentLocation() async {
    try {
      bool _serviceEnabled = await _locationService.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _locationService.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      loc.PermissionStatus _permissionGranted =
          await _locationService.hasPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        _permissionGranted = await _locationService.requestPermission();
        if (_permissionGranted != loc.PermissionStatus.granted) {
          return;
        }
      }

      // Get current location
      _currentLocation = await _locationService.getLocation();

      if (_currentLocation != null) {
        _getAddressFromLatLng(
            _currentLocation!.latitude!, _currentLocation!.longitude!);
      }

      setState(() {});
    } catch (e) {
      print('Could not get location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          address =
              '${place.name}, ${place.locality}, ${place.administrativeArea}';
        });
      }
    } catch (e) {
      print('Could not get address: $e');
    }
  }

  String? imageUrl;
  List<String> imageUrlsList = [];
  Future<void> fetchImages() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('images').get();

      if (snapshot.docs.isNotEmpty) {
        List<String> imageUrls = [];
        for (var doc in snapshot.docs) {
          imageUrls.add(doc['image_url']);
        }
        setState(() {
          imageUrlsList = imageUrls;
        });
      } else {
        print('No images found');
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  double targetLatitude = 19.9235658;
  double targetLongitude = 102.1857034;
  double allowedDistance = 50000;
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
            body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageUrlsList.isNotEmpty
                        ? CachedNetworkImageProvider(imageUrlsList[0])
                        : const CachedNetworkImageProvider(
                            "https://www.iro-su.edu.la/wp-content/uploads/slider/cache/b103b63cc699a591fa912d8d463dba03/WhatsApp-Image-2023-12-13-at-15.00.23.jpg", // fallback image
                          ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    width: double.infinity,
                    height: double.infinity,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 40, // Adjust the size as needed
                                        backgroundImage: Employee
                                                .profileimage.isNotEmpty
                                            ? NetworkImage(
                                                Employee.profileimage)
                                            : const NetworkImage(
                                                'https://i.pinimg.com/736x/59/37/5f/59375f2046d3b594d59039e8ffbf485a.jpg'),
                                        onBackgroundImageError:
                                            (exception, stackTrace) =>
                                                const Icon(Icons.error),
                                        child: Employee.profileimage.isEmpty
                                            ? const Icon(Icons
                                                .person) // Placeholder icon if no image is provided
                                            : null,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        Employee.firstName,
                                        style: GoogleFonts.notoSansLao(
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "ID:${Employee.employeeId}",
                                        style: GoogleFonts.notoSansLao(
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        ' ຕໍາແໜ່ງ: ${Employee.positionModel?.name ?? 'ບໍ່່ມີຂໍ້ມູນ'}',
                                        style: GoogleFonts.notoSansLao(
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "ສັງກັດຢູ່ພາກ:${Employee.departmentModel?.name ?? 'ບໍ່່ມີຂໍ້ມູນ'}",
                                        style: GoogleFonts.notoSansLao(
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 210,
                                      decoration: BoxDecoration(
                                        // color: Color(0xFFF0D988C),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 7,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            StreamBuilder(
                                                stream: Stream.periodic(
                                                    Duration(seconds: 1)),
                                                builder: (context, snaphot) {
                                                  return Center(
                                                    child: Text(
                                                      DateFormat('hh:mm:ss ')
                                                          .format(
                                                              DateTime.now()),
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
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
                                                    color: Colors.white,
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
                                          height: 100,
                                          width: 180,
                                          decoration: BoxDecoration(
                                            // color: Color(0xFFF0D988C),
                                            // color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.0,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                spreadRadius: 1,
                                                blurRadius: 7,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: Text(
                                                    checkIn,
                                                    style:
                                                        GoogleFonts.notoSansLao(
                                                      textStyle:
                                                          const TextStyle(
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Center(
                                                  child: Text(
                                                    'ໂມງເຂົ້າວຽກ',
                                                    style:
                                                        GoogleFonts.notoSansLao(
                                                      textStyle:
                                                          const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
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
                                          height: 100,
                                          width: 180,
                                          decoration: BoxDecoration(
                                            // color: Color(0xFFF0D988C),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.white,
                                              width:
                                                  1.0, // Specify the border width if needed
                                            ),
                                            boxShadow: [
                                              // Uncomment and modify this if you want shadows
                                              BoxShadow(
                                                color: Colors.white.withOpacity(
                                                    0.3), // Adjust the color opacity
                                                spreadRadius: 1,
                                                blurRadius: 7,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                            // Specify the border width if needed
                                          ),
                                          // boxShadow: [ // Uncomment and modify this if you want shadows
                                          //   BoxShadow(
                                          //     color: Colors.white.withOpacity(0.3), // Adjust the color opacity
                                          //     spreadRadius: 1,
                                          //     blurRadius: 7,
                                          //     offset: const Offset(0, 5),
                                          //   ),
                                          // ],

                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Text(
                                                  checkOut,
                                                  style:
                                                      GoogleFonts.notoSansLao(
                                                    textStyle: const TextStyle(
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Center(
                                                child: Text(
                                                  'ໂມງອອກວຽກ',
                                                  style:
                                                      GoogleFonts.notoSansLao(
                                                    textStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
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
                                          final GlobalKey<SlideActionState>
                                              key = GlobalKey();
                                          return SlideAction(
                                              borderRadius: 50,
                                              height: 80,
                                              text: checkIn.trim() ==
                                                      "----/----"
                                                  ? "ເລື່ອນເພື່ອເຂົ້າວຽກ" // "Press to check in"
                                                  : "ເລື່ອນເພື່ອອອກວຽກ", // "Press to check out"
                                              textStyle:
                                                  GoogleFonts.notoSansLao(
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFF37474F),
                                                ),
                                              ),
                                              outerColor: checkIn.trim() ==
                                                      "----/----"
                                                  ? Colors
                                                      .white // Fixed color code
                                                  : Color(0xFFFDE6E4),
                                              innerColor: Color(0xFFF37474F),
                                              key: key,
                                              onSubmit: () async {
                                                QuerySnapshot snap =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("Employee")
                                                        .where('id',
                                                            isEqualTo: Employee
                                                                .employeeId)
                                                        .get();

                                                if (snap.docs.isNotEmpty) {
                                                  DateTime now = DateTime.now();
                                                  String todayDate =
                                                      DateFormat('dd MMMM yyyy')
                                                          .format(now);

                                                  double targetLatitudes = 0.0;
                                                  double targetLongitudes = 0.0;
                                                  double allowedDistances = 0.0;
                                                  QuerySnapshot
                                                      settingsSnapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              "settings")
                                                          .get();

                                                  for (DocumentSnapshot doc
                                                      in settingsSnapshot
                                                          .docs) {
                                                    if (doc.exists) {
                                                      targetLatitudes =
                                                          (doc['targetLatitude']
                                                                  as num)
                                                              .toDouble();
                                                      targetLongitudes =
                                                          (doc['targetLongitude']
                                                                  as num)
                                                              .toDouble();
                                                      allowedDistances =
                                                          (doc['allowedDistance']
                                                                  as num)
                                                              .toDouble();
                                                    }
                                                  }

                                                  Position locationPosition =
                                                      await Geolocator
                                                          .getCurrentPosition(
                                                              desiredAccuracy:
                                                                  LocationAccuracy
                                                                      .high);
                                                  double distanceInMeters =
                                                      Geolocator
                                                          .distanceBetween(
                                                    locationPosition.latitude,
                                                    locationPosition.longitude,
                                                    targetLatitudes,
                                                    targetLongitudes,
                                                  );
                                                  print(
                                                      '12345${locationPosition}');
                                                  print(
                                                      'qqewe${locationPosition}');
                                                  print(locationPosition
                                                      .longitude);
                                                  print(locationPosition
                                                      .latitude);

                                                  if (distanceInMeters >
                                                      allowedDistances) {
                                                    StatusAlert.show(
                                                      context,
                                                      title:
                                                          'ຂໍອະໄພ ທ່ານບໍ່ສາມາດບັນທືກຂໍ້ມູນໄດ້ !!!',
                                                      subtitle:
                                                          'ທ່ານໄດ້ຢູ່ໄກຈາກຕໍາແໜ່ງໃນການບັນທືກເຂົ້າ - ອອກ',
                                                      titleOptions:
                                                          StatusAlertTextConfiguration(
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                          textStyle:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                      ),
                                                      subtitleOptions:
                                                          StatusAlertTextConfiguration(
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                          textStyle:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                      configuration:
                                                          const IconConfiguration(
                                                        icon: Icons
                                                            .error_outline_sharp,
                                                        color: Colors.redAccent,
                                                        size: 80,
                                                      ),
                                                      maxWidth: 260,
                                                      duration:
                                                          Duration(seconds: 5),
                                                    );

                                                    return;
                                                      }
                                                  bool isLate = now.isAfter(
                                                    DateTime(
                                                      now.year,
                                                      now.month,
                                                      now.day,
                                                      8,
                                                      0,
                                                    ),
                                                  );

                                                  DocumentSnapshot snap2 =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              "Employee")
                                                          .doc(snap.docs[0].id)
                                                          .collection("Record")
                                                          .doc(todayDate)
                                                          .get();

                                                  if (snap2.exists) {
                                                    String checkIn =
                                                        snap2['checkIn'];

                                                    setState(() {
                                                      checkOut =
                                                          DateFormat('hh:mm')
                                                              .format(now);
                                                    });

                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("Employee")
                                                        .doc(snap.docs[0].id)
                                                        .collection("Record")
                                                        .doc(todayDate)
                                                        .update({
                                                      'date': Timestamp.now(),
                                                      'checkIn': checkIn,
                                                      'checkOut':
                                                          DateFormat('hh:mm')
                                                              .format(now),
                                                      'checkOutLocation':
                                                          address,
                                                    });
                                                  }

                                                  String checkInTime =
                                                      DateFormat('hh:mm')
                                                          .format(now);

                                                  setState(() {
                                                    checkIn = checkInTime;
                                                  });

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("Employee")
                                                      .doc(snap.docs[0].id)
                                                      .collection("Record")
                                                      .doc(todayDate)
                                                      .set({
                                                    'date': Timestamp.now(),
                                                    'checkIn': checkInTime,
                                                    'checkOut':
                                                        DateFormat('hh:mm')
                                                            .format(now),
                                                    'checkInLocation': address,
                                                    'status': isLate
                                                        ? 'ມາວຽກຊ້າ'
                                                        : 'ມາວຽກ',
                                                  });
                                               
                                                } else {
                                                  print(
                                                      "No employee found with the given ID.");
                                                }

                                                key.currentState!.reset();
                                              });
                                        },
                                      ),
                                    )
                                  : Container(
                                      child: Text(
                                        " ບັນທືກການເຂົ້າວຽກສໍາເລັດ ! ",
                                        style: GoogleFonts.notoSansLao(
                                          textStyle: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 10),
                              Container(
                                height: 240,
                                width: double.infinity,
                                child: _currentLocation == null
                                    ? const Center(
                                        child: SpinKitCircle(
                                          color: Colors.white,
                                          size: 100.0,
                                        ),
                                      )
                                    : GoogleMap(
                                        onMapCreated:
                                            (GoogleMapController controller) {
                                          mapController = controller;
                                          mapController.animateCamera(
                                            CameraUpdate.newLatLng(
                                              LatLng(
                                                _currentLocation!.latitude!,
                                                _currentLocation!.longitude!,
                                              ),
                                            ),
                                          );
                                        },
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                            _currentLocation!.latitude!,
                                            _currentLocation!.longitude!,
                                          ),
                                          zoom: 18.0,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId:
                                                MarkerId('current_location'),
                                            position: LatLng(
                                              targetLatitude,
                                              targetLongitude,
                                            ),
                                          ),
                                        },
                                        circles: {
                                          Circle(
                                            circleId: const CircleId(
                                                'current_location'),
                                            center: LatLng(
                                              _currentLocation!.latitude!,
                                              _currentLocation!.longitude!,
                                            ),
                                            radius: 15,
                                            fillColor:
                                                Colors.blue.withOpacity(0.3),
                                            strokeColor: Colors.blue,
                                            strokeWidth: 1,
                                          ),
                                        },
                                        mapType: MapType.hybrid,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ))));
  }
}
