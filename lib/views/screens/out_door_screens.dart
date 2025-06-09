import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:timesabai/components/constants/colors.dart';
import 'package:timesabai/components/model/user_model/user_model.dart';
import 'package:timesabai/components/styles/size_config.dart';
import 'package:timesabai/views/screens/history_com_on.dart';
import 'package:timesabai/views/screens/home_index.dart';
import 'package:timesabai/views/widgets/loading_platform/loading_platform.dart';
import 'package:widgets_easier/widgets_easier.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;

enum AppState {
  free,
  picked,
}

class OutDoorScreens extends StatefulWidget {
  const OutDoorScreens({Key? key}) : super(key: key);

  @override
  _OutDoorScreensState createState() => _OutDoorScreensState();
}

class _OutDoorScreensState extends State<OutDoorScreens> {
  XFile? _imageFile;

  bool isLoading = false;
  String address = 'Fetching address...';
  double targetLatitude = 19.9235658;
  double targetLongitude = 102.1857034;
  late GoogleMapController mapController;

  String clockInAM = "------";
  String clockOutAM = "------";
  String clockInPM = "------";
  String clockOutPM = "------";

  Position? _currentLocation;
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) return;
      }

      _currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (_currentLocation != null) {
        await _getAddressFromLatLng(
            _currentLocation!.latitude, _currentLocation!.longitude);
      }

      setState(() {});
    } catch (e) {
      print('Could not get location: $e');
      setState(() => address = 'Unable to fetch location');
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
              '${place.name ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
        });
      }
    } catch (e) {
      print('Could not get address: $e');
      setState(() => address = 'Unable to fetch address');
    }
  }

  Future<void> _loadTodayRecord() async {
    try {
      setState(() => isLoading = true);
      DateTime now = DateTime.now();
      String todayDate = DateFormat('dd MMMM yyyy').format(now);

      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: Employee.employeeId)
          .get();

      if (snap.docs.isNotEmpty) {
        DocumentSnapshot record = await FirebaseFirestore.instance
            .collection("Employee")
            .doc(snap.docs[0].id)
            .collection("Record")
            .doc(todayDate)
            .get();

        if (record.exists) {
          setState(() {
            clockInAM = record['clockInAM'] ?? "------";
            clockOutAM = record['clockOutAM'] ?? "------";
            clockInPM = record['clockInPM'] ?? "------";
            clockOutPM = record['clockOutPM'] ?? "------";
            if (clockInAM.isEmpty || clockInAM == "----/----")
              clockInAM = "------";
            if (clockOutAM.isEmpty || clockOutAM == "----/----")
              clockOutAM = "------";
            if (clockInPM.isEmpty || clockInPM == "----/----")
              clockInPM = "------";
            if (clockOutPM.isEmpty || clockOutPM == "----/----")
              clockOutPM = "------";
          });
        } else {
          print('No record found for $todayDate, using default values');
          setState(() {
            clockInAM = "------";
            clockOutAM = "------";
            clockInPM = "------";
            clockOutPM = "------";
          });
        }
      } else {
        print('No employee found with ID: ${Employee.employeeId}');
      }
    } catch (e) {
      print('Error loading record: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> recordAttendance() async {
    try {
      // Query Firestore for employee document
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: Employee.employeeId)
          .get();

      if (snap.docs.isNotEmpty) {
        DateTime now = DateTime.now();
        String todayDate = DateFormat('dd MMMM yyyy').format(now);
        String currentTime = DateFormat('hh:mm').format(now);

        // Reference to the employee's record document
        DocumentReference recordRef = FirebaseFirestore.instance
            .collection("Employee")
            .doc(snap.docs[0].id)
            .collection("Record")
            .doc(todayDate);

        // Check if _imageFile is not null
        String? imageUrl;
        if (_imageFile != null) {
          // Upload image to Firebase Storage
          String fileName = path.basename(_imageFile!.path);
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('employee_images/${snap.docs[0].id}/$todayDate/$fileName');
          UploadTask uploadTask = storageRef.putFile(File(_imageFile!.path));
          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } else {
          // Handle case where no image is provided
          Fluttertoast.showToast(
            msg: "ກະລຸນາອັບໂຫຼດຮູບກ່ອນ",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }

        // Handle AM clock-in
        if (now.isBefore(DateTime(now.year, now.month, now.day, 12, 0)) &&
            clockInAM == "------") {
          print('Recording clockInAM at $currentTime');
          setState(() {
            clockInAM = currentTime;
          });
          await recordRef.set({
            'date': FieldValue.serverTimestamp(),
            'clockInAM': currentTime,
            'clockOutAM': "------",
            'clockInPM': "------",
            'clockOutPM': "------",
            'checkInLocation': address,
            'status': 'ໄປປະຊຸມ',
            'type_clock_in': 'ນອກຫ້ອງການ',
            'image': imageUrl,
            'title': description.text,
          }, SetOptions(merge: true));

          Fluttertoast.showToast(
            msg: "ລົງທະບຽນເຂົ້າຕອນເຊົ້າສຳເລັດ: $currentTime",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        // Handle AM clock-out
        else if (clockInAM != "------" && clockOutAM == "------") {
          setState(() {
            clockOutAM = currentTime;
          });
          await recordRef.update({
            'clockOutAM': currentTime,
            'checkOutLocation': address,
            'type_clock_in': 'ນອກຫ້ອງການ',
            'image': imageUrl, // Update with new image URL
            'title': description.text,
          });

          Fluttertoast.showToast(
            msg: "ລົງທະບຽນອອກຕອນເຊົ້າສຳເລັດ: $currentTime",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        // Handle PM clock-in
        else if (now.isAfter(DateTime(now.year, now.month, now.day, 12, 0)) &&
            clockInPM == "------") {
          setState(() {
            clockInPM = currentTime;
          });
          await recordRef.set({
            'date': FieldValue.serverTimestamp(),
            'clockInAM': clockInAM,
            'clockOutAM': clockOutAM,
            'clockInPM': currentTime,
            'clockOutPM': "------",
            'checkInLocation': address,
            'status': 'ໄປປະຊຸມ',
            'type_clock_out': 'ນອກຫ້ອງການ',
            'image': imageUrl, // Store the Firebase Storage URL
            'title': description.text,
          }, SetOptions(merge: true));

          Fluttertoast.showToast(
            msg: "ລົງທະບຽນເຂົ້າຕອນບ່າຍສຳເລັດ: $currentTime",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        // Handle PM clock-out
        else if (clockInPM != "------" && clockOutPM == "------") {
          setState(() {
            clockOutPM = currentTime;
          });
          await recordRef.update({
            'clockOutPM': currentTime,
            'checkOutLocation': address,
            'type_clock_out': 'ນອກຫ້ອງການ',
            'image': imageUrl, // Update with new image URL
            'title': description.text,
          });

          Fluttertoast.showToast(
            msg: "ລົງທະບຽນອອກຕອນບ່າຍສຳເລັດ: $currentTime",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          print(
              'No action taken: Invalid state or all check-ins/outs complete');
          Fluttertoast.showToast(
            msg: "ບໍ່ສາມາດບັນທືກໄດ້ ຍັງບໍ່ທັນຮອດເວລາ",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }
      } else {
        Fluttertoast.showToast(
          msg: "ບໍ່ພົບຂໍ້ມູນພະນັກງານ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error recording attendance: $e');
      Fluttertoast.showToast(
        msg: "ເກີດຂໍ້ຜິດພາດ: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void initState() {
    _getCurrentLocation();
    _loadTodayRecord();
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController description = TextEditingController();

  AppState state = AppState.free;

  Widget build(BuildContext context) {
    bool isComplete = clockInPM != "------" && clockOutPM != "------";

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: CustomProgressHUD(
        key: UniqueKey(),
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height, // Full screen height
            child: Column(
              children: [
                // Part 1: Google Map (Top Half)
                Container(
                  height: MediaQuery.of(context).size.height *
                      0.4, // 40% of screen height
                  child: _currentLocation == null
                      ? const Center(
                          child: SpinKitCircle(
                            color: Colors.blueAccent,
                            size: 80.0,
                          ),
                        )
                      : GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                            mapController.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(_currentLocation!.latitude,
                                    _currentLocation!.longitude),
                              ),
                            );
                          },
                          initialCameraPosition: CameraPosition(
                            target: LatLng(_currentLocation!.latitude,
                                _currentLocation!.longitude),
                            zoom: 18.0,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('current_location'),
                              position: LatLng(targetLatitude, targetLongitude),
                            ),
                          },
                          circles: {
                            Circle(
                              circleId: const CircleId('current_location'),
                              center: LatLng(_currentLocation!.latitude,
                                  _currentLocation!.longitude),
                              radius: 15,
                              fillColor: Colors.blue.withOpacity(0.3),
                              strokeColor: Colors.blue,
                              strokeWidth: 1,
                            ),
                          },
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                          mapType: MapType.hybrid,
                        ),
                ),
                // Part 2: Form Container (Bottom Part)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                style: GoogleFonts.notoSansLao(fontSize: 18),
                                text: 'ທ່ານອອກໄປວຽກນອກ',
                                children: [
                                  TextSpan(
                                    text:
                                        'ເພື່ອໄປປະຊຸມວຽກຢູ່ນອກ ຕ້ອງການບັນທືກການມາປະຈໍາການຂອງທ່ານ',
                                    style:
                                        GoogleFonts.notoSansLao(fontSize: 18),
                                  ),
                                  TextSpan(
                                    text: "🥰😍",
                                    style:
                                        GoogleFonts.notoSansLao(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Color(0xFFF3F3F3),
                              thickness: 1.0,
                              height: 20.0,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ລາຍລະອຽດການ ແລະ ສະຖານທີ ອອກວຽກນອກ',
                                      style:
                                          GoogleFonts.notoSansLao(fontSize: 16),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(120)
                                      ],
                                      maxLines: 1,
                                      controller: description,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusColor: kGary,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: kGary, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: kGary, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: kGary, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        hintText: 'ກະລຸນາປ້ອນ',
                                        hintStyle: GoogleFonts.notoSansLao(
                                            fontSize: 16),
                                        prefixIcon:
                                            Icon(Icons.location_on_outlined),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'ກະລຸນາປ້ອນລ່ຍລະອຽດ';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'ແນບຮູບພາບອອກວຽກນອກ',
                                      style:
                                          GoogleFonts.notoSansLao(fontSize: 16),
                                    ),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () async {
                                        bottomSheetPushContainer(
                                          context: context,
                                          height: 150,
                                          isScrollControlled: true,
                                          child: buttonChooseImage(context),
                                        );
                                      },
                                      child: Container(
                                        decoration: ShapeDecoration(
                                          color: Colors.white,
                                          shape: DashedBorder(
                                            color: Color(0xFFE2E6EA),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        height: _imageFile == null ? 200 : null,
                                        width: double.infinity,
                                        child: _imageFile == null
                                            ? Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'ອັບໂຫລດຮູບພາບ',
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                              fontSize: 16),
                                                    ),
                                                    SizedBox(height: 10),
                                                    SizedBox(
                                                        child:
                                                            Icon(Icons.image)),
                                                  ],
                                                ),
                                              )
                                            : Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            13.0),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: Image(
                                                        image: FileImage(File(
                                                            _imageFile!.path)),
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 5,
                                                    right: 5,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _imageFile = null;
                                                          state =
                                                              AppState.picked;
                                                        });
                                                      },
                                                      child: const CircleAvatar(
                                                        radius: 15,
                                                        backgroundColor:
                                                            kRedColor,
                                                        child: Icon(
                                                          Icons.close,
                                                          color:
                                                              kTextWhiteColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IntrinsicWidth(
              child: SizedBox(
                height: 50,
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: kRedColor),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    backgroundColor: kPinkLigthColor,
                  ),
                  child: Text(
                    'ຍົກເລີກ',
                    style: GoogleFonts.notoSansLao(
                        fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
            IntrinsicWidth(
              child: SizedBox(
                height: 50,
                width: 150,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          if (_formKey.currentState!.validate()) {
                            if (_imageFile == null) {
                              Fluttertoast.showToast(
                                  msg: 'ກະລຸນາແນບຮູບມາພ້ອມເດີ',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: kYellowColor,
                                  textColor: kBack87,
                                  fontSize: 16.0,
                                  fontAsset: 'NotoSansLao');
                              return;
                            }

                            await recordAttendance().whenComplete(() {
                              _loadTodayRecord().whenComplete(() =>
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomeIndex())).whenComplete(
                                      () => Navigator.pop(context)));
                                      setState(() {
                                        
                                      });
                            });

                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    backgroundColor: kYellowFirstColor,
                  ),
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ກໍາລັງບັນທືກ',
                              style: GoogleFonts.notoSansLao(fontSize: 16),
                            ),
                          ],
                        )
                      : Text(
                          'ບັນທືກ',
                          style: GoogleFonts.notoSansLao(
                              fontSize: 16, color: Colors.black),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buttonChooseImage(context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'ເລືອກຮູບພາບ',
            style: GoogleFonts.notoSansLao(fontSize: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () async {
                  await _takePhoto(ImageSource.camera);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.camera_alt_outlined, color: kBlueColor),
                label: Text(
                  'Camera',
                  style: GoogleFonts.notoSansLao(fontSize: 16),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await _takePhoto(ImageSource.gallery);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.image_outlined, color: kBlueColor),
                label: Text(
                  'Gallery',
                  style: GoogleFonts.notoSansLao(fontSize: 16),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _takePhoto(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
    );

    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
        state = AppState.picked;
      });
    }
  }

  Future<void> bottomSheetPushContainer({
    BuildContext? context,
    Widget? child,
    double? constantsSize,
    double? height,
    bool isScrollControlled = true, // เปลี่ยนค่าเริ่มต้นเป็น true
  }) {
    return showModalBottomSheet(
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      context: context!,
      builder: (context) => Container(
        height: height ?? 150,
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: kPrimaryColor.shade50, blurRadius: 10)],
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }
}
