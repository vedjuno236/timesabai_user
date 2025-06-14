import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:status_alert/status_alert.dart';
import 'package:timesabai/components/model/weather_model/weather_model.dart';
import 'package:timesabai/components/services/weather_service.dart';
import 'package:timesabai/main.dart';
import 'package:timesabai/views/screens/out_door_screens.dart';
import 'package:timesabai/wearth.dart';
import '../../components/model/user_model/user_model.dart';
import 'package:lottie/lottie.dart' as lottie;

class TodayScreens extends StatefulWidget {
  const TodayScreens({super.key});
  @override
  State<TodayScreens> createState() => _TodayScreensState();
}

class _TodayScreensState extends State<TodayScreens> {
  String clockInAM = "------";
  String clockOutAM = "------";
  String clockInPM = "------";
  String clockOutPM = "------";
  String address = 'Fetching address...';
  bool isLoading = true;
  String image='';
    String tilte='';

  late GoogleMapController mapController;
  Position? _currentLocation;
  List<String> imageUrlsList = [];

  double targetLatitude = 19.9235658;
  double targetLongitude = 102.1857034;
  double allowedDistance = 50000;
  Artboard? _riveArtboard;
  SMIInput<double>? _levelInput;
  StateMachineController? controller;
  Future<void> preload() async {
    try {
      final file = await RiveFile.asset('assets/rives/weather.riv');
      final artboard = file.mainArtboard;

      final animationController = SimpleAnimation('Animation 1');
      artboard.addController(animationController);
      animationController.isActive = true;

      if (mounted) {
        setState(() => _riveArtboard = artboard);
      }
    } catch (e) {
      print("Failed to load Rive file: $e");
    }
  }

  late WeatherData weatherInfo;
  bool isLoadingS = false;
  myWeather() {
    isLoading = false;
    WeatherServices().fetchWeather().then((value) {
      setState(() {
        weatherInfo = value;
        isLoadingS = true;
      });
    });
  }

  Future<void> saveSettingsToSharedPreferences() async {
    try {
      double targetLatitudes = 0.0;
      double targetLongitudes = 0.0;
      double allowedDistances = 0.0;

      QuerySnapshot settingsSnapshot =
          await FirebaseFirestore.instance.collection("settings").get();

      for (DocumentSnapshot doc in settingsSnapshot.docs) {
        if (doc.exists) {
          targetLatitudes = (doc['targetLatitude'] as num).toDouble();
          targetLongitudes = (doc['targetLongitude'] as num).toDouble();
          allowedDistances = (doc['allowedDistance'] as num).toDouble();
        }
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setDouble('targetLatitude', targetLatitudes);
      await prefs.setDouble('targetLongitude', targetLongitudes);
      await prefs.setDouble('allowedDistance', allowedDistances);
    } catch (e) {
      print('Error saving settings to SharedPreferences: $e');
      throw Exception('Failed to save settings: $e');
    }
  }

  @override
  void initState() {
    weatherInfo = WeatherData(
      name: '',
      temperature: Temperature(current: 0.0),
      humidity: 0,
      wind: Wind(speed: 0.0),
      maxTemperature: 0,
      minTemperature: 0,
      pressure: 0,
      seaLevel: 0,
      weather: [],
    );
    myWeather();
    super.initState();
    saveSettingsToSharedPreferences();
    preload();
    _loadTodayRecord();
    _getCurrentLocation();
    fetchImages();
  }

  Future<void> _loadTodayRecord() async {
    try {
      setState(() => isLoading = true);
      DateTime now = DateTime.now();
      String todayDate = DateFormat('dd MMMM yyyy').format(now);
      logger.d('TimeNow: $now, Date: $todayDate');
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
               image = record['image'] ;
            tilte = record['title'] ;
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

  Future<bool> validateUserLocation(BuildContext context) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        StatusAlert.show(
          context,
          title: 'ຂໍ້ຜິດພາດ',
          subtitle: 'ກະລຸນາເປີດການບໍລິການສະຖານທີ່',
          titleOptions: StatusAlertTextConfiguration(
            style: GoogleFonts.notoSansLao(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          subtitleOptions: StatusAlertTextConfiguration(
            style: GoogleFonts.notoSansLao(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          configuration: const IconConfiguration(
            icon: Icons.error_outline_sharp,
            color: Colors.redAccent,
            size: 80,
          ),
          maxWidth: 260,
          duration: const Duration(seconds: 5),
        );
        return false;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          StatusAlert.show(
            context,
            title: 'ຂໍ້ຜິດພາດ',
            subtitle: 'ກະລຸນາອະນຸຍາດການເຂົ້າເຖິງສະຖານທີ່',
            titleOptions: StatusAlertTextConfiguration(
              style: GoogleFonts.notoSansLao(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            subtitleOptions: StatusAlertTextConfiguration(
              style: GoogleFonts.notoSansLao(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            backgroundColor: Colors.white,
            configuration: const IconConfiguration(
              icon: Icons.error_outline_sharp,
              color: Colors.redAccent,
              size: 80,
            ),
            maxWidth: 260,
            duration: const Duration(seconds: 5),
          );
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        StatusAlert.show(
          context,
          title: 'ຂໍ້ຜິດພາດ',
          subtitle: 'ການເຂົ້າເຖິງສະຖານທີ່ຖືກປະຕິເສດຖາວອນ',
          titleOptions: StatusAlertTextConfiguration(
            style: GoogleFonts.notoSansLao(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          subtitleOptions: StatusAlertTextConfiguration(
            style: GoogleFonts.notoSansLao(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          configuration: const IconConfiguration(
            icon: Icons.error_outline_sharp,
            color: Colors.redAccent,
            size: 80,
          ),
          maxWidth: 260,
          duration: const Duration(seconds: 5),
        );
        return false;
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final double targetLatitude = prefs.getDouble('targetLatitude') ?? 0.0;
      final double targetLongitude = prefs.getDouble('targetLongitude') ?? 0.0;
      final double allowedDistance = prefs.getDouble('allowedDistance') ?? 0.0;

      Position locationPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double distanceInMeters = Geolocator.distanceBetween(
        locationPosition.latitude,
        locationPosition.longitude,
        targetLatitude,
        targetLongitude,
      );

      print('Distance: $distanceInMeters, Allowed: $allowedDistance');

      if (distanceInMeters > allowedDistance) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OutDoorScreens()),
        );

        // StatusAlert.show(
        //   context,
        //   title: 'ຂໍອະໄພ ທ່ານບໍ່ສາມາດບັນທືກຂໍ້ມູນໄດ້ !!!',
        //   subtitle: 'ທ່ານໄດ້ຢູ່ໄກຈາກຕໍາແໜ່ງໃນການບັນທືກເຂົ້າ - ອອກ',
        //   titleOptions: StatusAlertTextConfiguration(
        //     style: GoogleFonts.notoSansLao(
        //       textStyle: const TextStyle(
        //         fontWeight: FontWeight.bold,
        //         fontSize: 20,
        //       ),
        //     ),
        //   ),
        //   subtitleOptions: StatusAlertTextConfiguration(
        //     style: GoogleFonts.notoSansLao(
        //       textStyle: const TextStyle(
        //         fontWeight: FontWeight.bold,
        //         fontSize: 15,
        //       ),
        //     ),
        //   ),
        //   backgroundColor: Colors.white,
        //   configuration: const IconConfiguration(
        //     icon: Icons.error_outline_sharp,
        //     color: Colors.redAccent,
        //     size: 80,
        //   ),
        //   maxWidth: 260,
        //   duration: const Duration(seconds: 5),
        // );
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating location: $e');
      StatusAlert.show(
        context,
        title: 'ຂໍ້ຜິດພາດ',
        subtitle: 'ບໍ່ສາມາດດຶງຂໍ້ມູນສະຖານທີ່ໄດ້',
        titleOptions: StatusAlertTextConfiguration(
          style: GoogleFonts.notoSansLao(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        subtitleOptions: StatusAlertTextConfiguration(
          style: GoogleFonts.notoSansLao(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        configuration: const IconConfiguration(
          icon: Icons.error_outline_sharp,
          color: Colors.redAccent,
          size: 80,
        ),
        maxWidth: 260,
        duration: const Duration(seconds: 5),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = clockInPM != "------" && clockOutPM != "------";
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
            body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageUrlsList.isNotEmpty
                        ? CachedNetworkImageProvider(imageUrlsList[0])
                        : const CachedNetworkImageProvider(
                            "https://www.iro-su.edu.la/wp-content/uploads/slider/cache/b103b63cc699a591fa912d8d463dba03/WhatsApp-Image-2023-12-13-at-15.00.23.jpg"),
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
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundImage: Employee
                                              .profileimage.isNotEmpty
                                          ? NetworkImage(Employee.profileimage)
                                          : const NetworkImage(
                                              'https://i.pinimg.com/736x/59/37/5f/59375f2046d3b594d59039e8ffbf485a.jpg'),
                                      onBackgroundImageError:
                                          (exception, stackTrace) =>
                                              const Icon(Icons.error),
                                      child: Employee.profileimage.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                  ).animate().scaleXY(
                                      begin: 0,
                                      end: 1,
                                      delay: 300.ms,
                                      duration: 300.ms,
                                      curve: Curves.easeInOutCubic),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        Employee.firstName,
                                        style: GoogleFonts.notoSansLao(
                                          textStyle: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "ID:${Employee.employeeId}",
                                        style: GoogleFonts.notoSansLao(
                                          textStyle: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'ຕໍາແໜ່ງ: ${Employee.positionModel?.name ?? 'ບໍ່ມີຂໍ້ມູນ'}',
                                        style: GoogleFonts.notoSansLao(
                                          textStyle: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "ສັງກັດຢູ່ພາກ:${Employee.departmentModel?.name ?? 'ບໍ່ມີຂໍ້ມູນ'}",
                                        style: GoogleFonts.notoSansLao(
                                          textStyle: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).animate().scaleXY(
                                      begin: 0,
                                      end: 1,
                                      delay: 400.ms,
                                      duration: 400.ms,
                                      curve: Curves.easeInOutCubic),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 210,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.white, width: 1.0),
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
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_riveArtboard != null)
                                            Row(
                                              children: [
                                                SizedBox(
                                                  height: 50,
                                                  width: 100,
                                                  child: Rive(
                                                    artboard: _riveArtboard!,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    "${weatherInfo.temperature.current.toStringAsFixed(0)}°C",
                                                    style:
                                                        GoogleFonts.notoSansLao(
                                                      textStyle:
                                                          const TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    )),
                                              ],
                                            ),

                                          const SizedBox(height: 20),
                                          StreamBuilder(
                                              stream: Stream.periodic(
                                                  const Duration(seconds: 1)),
                                              builder: (context, snapshot) {
                                                return Center(
                                                  child: Text(
                                                    DateFormat('hh:mm:ss ')
                                                        .format(DateTime.now()),
                                                    style:
                                                        GoogleFonts.notoSansLao(
                                                      textStyle:
                                                          const TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                          // const SizedBox(height: 5),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
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
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().scaleXY(
                                      begin: 0,
                                      end: 1,
                                      delay: 400.ms,
                                      duration: 400.ms,
                                      curve: Curves.easeInOutCubic),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 180,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 1.0),
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
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'ເຂົ້າຕອນເຊົ້າ',
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'ອອກຕອນເຊົ້າ',
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      clockInAM,
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      clockOutAM,
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 1.0),
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
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'ເຂົ້າຕອນແລງ',
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'ອອກຕອນແລງ',
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      clockInPM,
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      clockOutPM,
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animate().scaleXY(
                                      begin: 0,
                                      end: 1,
                                      delay: 500.ms,
                                      duration: 500.ms,
                                      curve: Curves.easeInOutCubic),
                                ],
                              ),
                              const SizedBox(height: 20),
                              isComplete
                                  ? Container(
                                      child: Text(
                                        "ບັນທືກການເຂົ້າ-ອອກວຽກສໍາເລັດ!",
                                        style: GoogleFonts.notoSansLao(
                                          textStyle: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      child: Builder(
                                        builder: (context) {
                                          final GlobalKey<SlideActionState>
                                              key = GlobalKey();
                                          return SlideAction(
                                            borderRadius: 50,
                                            height: 80,
                                            text: _getSlideText(),
                                            textStyle: GoogleFonts.notoSansLao(
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF37474F),
                                              ),
                                            ),
                                            outerColor: _getOuterColor(),
                                            innerColor: const Color(0xFF37474F),
                                            key: key,
                                            onSubmit: () async {
                                              try {
                                                bool isLocationValid =
                                                    await validateUserLocation(
                                                        context);
                                                if (!isLocationValid) {
                                                  key.currentState?.reset();
                                                  return;
                                                }
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
                                                  String currentTime =
                                                      DateFormat('hh:mm')
                                                          .format(now);

                                                  // Determine late status
                                                  bool isLate = false;
                                                  DocumentReference recordRef =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              "Employee")
                                                          .doc(snap.docs[0].id)
                                                          .collection("Record")
                                                          .doc(todayDate);

                                                  // Update or set the record
                                                  if (now.isBefore(DateTime(
                                                          now.year,
                                                          now.month,
                                                          now.day,
                                                          12,
                                                          0)) &&
                                                      clockInAM == "------") {
                                                    isLate = now.isAfter(
                                                        DateTime(
                                                            now.year,
                                                            now.month,
                                                            now.day,
                                                            8,
                                                            0));
                                                    print(
                                                        'Recording clockInAM at $currentTime');
                                                    setState(() {
                                                      clockInAM = currentTime;
                                                    });
                                                    await recordRef.set({
                                                      'date': FieldValue
                                                          .serverTimestamp(),
                                                      'clockInAM': currentTime,
                                                      'clockOutAM': "------",
                                                      'clockInPM': "------",
                                                      'clockOutPM': "------",
                                                      'checkInLocation':
                                                          address,
                                                      'status': isLate
                                                          ? 'ມາວຽກຊ້າ'
                                                          : 'ມາວຽກ',
                                                      'type_clock_in':
                                                          'ຫ້ອງການ',
                                                      'image':
                                                          image, 
                                                      'title': tilte,
                                                    }, SetOptions(merge: true));
                                                    // Show success toast
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          'ບັນທຶກເຂົ້າວຽກຕອນເຊົ້າສຳເລັດ',
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.green,
                                                      textColor: Colors.white,
                                                      fontSize: 15.0,
                                                      webPosition: "center",
                                                      webBgColor: "#4CAF50",
                                                    );
                                                  } else if (clockInAM !=
                                                          "------" &&
                                                      clockOutAM == "------") {
                                                    logger.d(
                                                        'Recording clockOutAM at $currentTime');
                                                    setState(() {
                                                      clockOutAM = currentTime;
                                                    });
                                                    await recordRef.update({
                                                      'clockOutAM': currentTime,
                                                      'checkOutLocation':
                                                          address,
                                                      'type_clock_in':
                                                          'ຫ້ອງການ',
                                                      'image':
                                                          image, // Store the Firebase Storage URL
                                                      'title': tilte,
                                                    });
                                                    // Show success toast
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          'ບັນທຶກອອກວຽກຕອນເຊົ້າສຳເລັດ',
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.green,
                                                      textColor: Colors.white,
                                                      fontSize: 15.0,
                                                      webPosition: "center",
                                                      webBgColor: "#4CAF50",
                                                    );
                                                  } else if (now.isAfter(
                                                          DateTime(
                                                              now.year,
                                                              now.month,
                                                              now.day,
                                                              12,
                                                              0)) &&
                                                      clockInPM == "------") {
                                                    isLate = now.isAfter(
                                                        DateTime(
                                                            now.year,
                                                            now.month,
                                                            now.day,
                                                            13,
                                                            00));
                                                    logger.d(
                                                        'Recording clockInPM at $currentTime');
                                                    setState(() {
                                                      clockInPM = currentTime;
                                                    });
                                                    await recordRef.set({
                                                      'date': FieldValue
                                                          .serverTimestamp(),
                                                      'clockInAM': clockInAM,
                                                      'clockOutAM': clockOutAM,
                                                      'clockInPM': currentTime,
                                                      'clockOutPM': "------",
                                                      'checkInLocation':
                                                          address,
                                                      'status': isLate
                                                          ? 'ມາວຽກຊ້າ'
                                                          : 'ມາວຽກ',
                                                      'type_clock_out':
                                                          'ຫ້ອງການ',
                                                      'image':
                                                          image, // Store the Firebase Storage URL
                                                      'title': tilte,
                                                         
                                                    }, SetOptions(merge: true));
                                                    // Show success toast
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          'ບັນທຶກເຂົ້າວຽກຕອນບ່າຍສຳເລັດ',
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.green,
                                                      textColor: Colors.white,
                                                      fontSize: 15.0,
                                                      webPosition: "center",
                                                      webBgColor: "#4CAF50",
                                                    );
                                                  } else if (clockInPM !=
                                                          "------" &&
                                                      clockOutPM == "------") {
                                                    logger.d(
                                                        'Recording clockOutPM at $currentTime');
                                                    setState(() {
                                                      clockOutPM = currentTime;
                                                    });
                                                    await recordRef.update({
                                                      'clockOutPM': currentTime,
                                                      'checkOutLocation':
                                                          address,
                                                      'type_clock_out':
                                                          'ຫ້ອງການ',
                                                      'image':
                                                          image, // Store the Firebase Storage URL
                                                      'title': tilte,

                                                    });
                                                    // Show success toast
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          'ບັນທຶກອອກວຽກຕອນບ່າຍສຳເລັດ',
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      backgroundColor:
                                                          Colors.green,
                                                      textColor: Colors.white,
                                                      fontSize: 15.0,
                                                      webPosition: "center",
                                                      webBgColor: "#4CAF50",
                                                    );
                                                  } else {
                                                    print(
                                                        'No action taken: Invalid state or all check-ins/outs complete');
                                                    return;
                                                  }

                                                  // Refresh record after update
                                                  await _loadTodayRecord();
                                                  print(
                                                      'Updated state: AM In: $clockInAM, AM Out: $clockOutAM, PM In: $clockInPM, PM Out: $clockOutPM');
                                                } else {
                                                  print(
                                                      "No employee found with ID: ${Employee.employeeId}");
                                                  // Optional: Show toast for no employee found
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        'ບໍ່ພົບພະນັກງານທີ່ມີ ID: ${Employee.employeeId}',
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    textColor: Colors.white,
                                                    fontSize: 15.0,
                                                    webPosition: "center",
                                                    webBgColor: "#B71C1C",
                                                  );
                                                }
                                              } catch (e) {
                                                print(
                                                    'Error recording time: $e');
                                                // Fluttertoast.showToast(
                                                //   msg:
                                                //       'ບໍ່ສາມາດບັນທຶກເວລາໄດ້ ກະລຸນາລອງໃໝ່',
                                                //   toastLength:
                                                //       Toast.LENGTH_LONG,
                                                //   gravity: ToastGravity.CENTER,
                                                //   backgroundColor:
                                                //       Colors.redAccent,
                                                //   textColor: Colors.white,
                                                //   fontSize: 15.0,
                                                //   webPosition: "center",
                                                //   webBgColor: "#B71C1C",
                                                // );
                                              }

                                              key.currentState?.reset();
                                            },
                                          );
                                        },
                                      ),
                                    ).animate().scaleXY(
                                      begin: 0,
                                      end: 1,
                                      delay: 500.ms,
                                      duration: 500.ms,
                                      curve: Curves.easeInOutCubic),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                height: 240,
                                width: double.infinity,
                                child: _currentLocation == null
                                    ? const Center(
                                        child: SpinKitCircle(
                                          color: Colors.white,
                                          size: 80.0,
                                        ),
                                      )
                                    : GoogleMap(
                                        onMapCreated:
                                            (GoogleMapController controller) {
                                          mapController = controller;
                                          mapController.animateCamera(
                                            CameraUpdate.newLatLng(
                                              LatLng(_currentLocation!.latitude,
                                                  _currentLocation!.longitude),
                                            ),
                                          );
                                        },
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                              _currentLocation!.latitude,
                                              _currentLocation!.longitude),
                                          zoom: 18.0,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId: const MarkerId(
                                                'current_location'),
                                            position: LatLng(targetLatitude,
                                                targetLongitude),
                                          ),
                                        },
                                        circles: {
                                          Circle(
                                            circleId: const CircleId(
                                                'current_location'),
                                            center: LatLng(
                                                _currentLocation!.latitude,
                                                _currentLocation!.longitude),
                                            radius: 15,
                                            fillColor:
                                                Colors.blue.withOpacity(0.3),
                                            strokeColor: Colors.blue,
                                            strokeWidth: 1,
                                          ),
                                        },
                                        myLocationButtonEnabled: true,
                                        myLocationEnabled: true,
                                        zoomControlsEnabled: true,
                                        zoomGesturesEnabled: true,
                                        // myLocationButtonEnabled: true,
                                        // myLocationEnabled: true,
                                        // zoomControlsEnabled: true,
                                        // zoomGesturesEnabled: true,
                                        mapType: MapType.hybrid,
                                      ),
                              ).animate().scaleXY(
                                  begin: 0,
                                  end: 1,
                                  delay: 500.ms,
                                  duration: 500.ms,
                                  curve: Curves.easeInOutCubic),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ))));
  }

  String _getSlideText() {
    DateTime now = DateTime.now();
    // logger.d(
    //     'Slide text check: Time: ${DateFormat('HH:mm:ss').format(now)}, clockInAM: $clockInAM, clockInPM: $clockInPM');
    if (now.isBefore(DateTime(now.year, now.month, now.day, 12, 00)) &&
        clockInAM == "------") {
      print('Showing AM check-in text');
      return "ເລື່ອນເພື່ອເຂົ້າວຽກເຊົ້າ";
    } else if (clockInAM != "------" && clockOutAM == "------") {
      print('Showing AM check-out text');
      return "ເລື່ອນເພື່ອອອກວຽກເຊົ້າ";
    } else if (now.isAfter(DateTime(now.year, now.month, now.day, 12, 00)) &&
        clockInPM == "------") {
      print('Showing PM check-in text');
      return "ເລື່ອນເພື່ອເຂົ້າວຽກຕອນແລງ";
    } else if (clockInPM != "------" && clockOutPM == "------") {
      print('Showing PM check-out text');
      return "ເລື່ອນເພື່ອອອກວຽກຕອນແລງ";
    }
    print('Showing default empty text');
    return " ບໍ່ທັນຮອດໂມງເຂົ້າວຽກຕອນແລງ ..!🤗";
  }

  Color _getOuterColor() {
    if (clockInAM == "------" || clockInPM == "------") {
      return Colors.white;
    } else if (clockOutAM == "------" || clockOutPM == "------") {
      return Color(0xFFFCE6E4);
    }
    return Color(0xFFFCE6E4); // Default return value
  }
}
