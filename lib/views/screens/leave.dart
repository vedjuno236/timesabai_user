import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:timesabai/components/model/user_model/user_model.dart';
import 'package:timesabai/views/screens/history_leave.dart';
import 'package:timesabai/views/widgets/loading_platform/loading_platform.dart';

import '../../../components/provider/bottom_provider/bottom_provider.dart';
import 'package:timesabai/components/provider/bottom_provider/bottom_provider.dart'
    as bottom;
import 'package:timesabai/views/screens/history_leave.dart' as history;

class Laphak extends ConsumerWidget {
  const Laphak({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLoading = false;
    final viewType = ref.watch(bottom.viewTypeProvider);
    final tableViewIsActive = ref.watch(isTableViewActiveProvider);
    final heatmapDiagramIsActive = ref.watch(isHeatmapDiagramActiveProvider);

    final pageSection = viewType == bottom.ViewType.tableView
        ? DayScreens()
        : const TimesScreens();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF577DF4),
        title: Text(
          'ຂໍລາພັກ',
          style: GoogleFonts.notoSansLao(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              const SizedBox(height: 95),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(viewTypeProvider.notifier).state =
                          bottom.ViewType.tableView;
                      ref.read(isTableViewActiveProvider.notifier).state = true;
                      ref.read(isHeatmapDiagramActiveProvider.notifier).state =
                          false;
                    },
                    child: ViewTypeButton(
                      title: "ແບບວັນ",
                      isActive: tableViewIsActive,
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      ref.read(viewTypeProvider.notifier).state =
                          bottom.ViewType.heatmapDiagram;
                      ref.read(isTableViewActiveProvider.notifier).state =
                          false;
                      ref.read(isHeatmapDiagramActiveProvider.notifier).state =
                          true;
                    },
                    child: ViewTypeButton(
                      title: "ແບບຊົ່ວໂມງ",
                      isActive: heatmapDiagramIsActive,
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
              Padding(padding: const EdgeInsets.all(8.0), child: pageSection),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewTypeButton extends ConsumerWidget {
  const ViewTypeButton({
    Key? key,
    required this.title,
    required this.isActive,
    required this.style,
  }) : super(key: key);

  final String title;
  final bool isActive;
  final TextStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 60,
      width: 150,
      child: OutlinedButton(
        onPressed: () {
          ref.read(viewTypeProvider.notifier).state = title == "ແບບວັນ"
              ? bottom.ViewType.tableView
              : bottom.ViewType.heatmapDiagram;
          ref.read(isTableViewActiveProvider.notifier).state =
              title == "ແບບວັນ";
          ref.read(isHeatmapDiagramActiveProvider.notifier).state =
              title == "ແບບຊົ່ວໂມງ";
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isActive ? Colors.blue : Colors.white,
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range),
            SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.notoSansLao(
                textStyle: style.copyWith(
                  color: isActive
                      ? Colors.white
                      : Colors.black, // Change color based on isActive
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DayScreens extends StatefulWidget {
  const DayScreens({Key? key}) : super(key: key);

  @override
  _DayScreensState createState() => _DayScreensState();
}

class _DayScreensState extends State<DayScreens> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();

  TextEditingController datefromeController = TextEditingController();
  TextEditingController datetoController = TextEditingController();
  TextEditingController daySummaryController = TextEditingController();
  TextEditingController documentController = TextEditingController();

  List<Map<String, dynamic>> _leaveType = [];
  String? leaveTypeId;
  String? selectedLeaveType;

  List<File> _mages = [];
  FilePickerResult? _pickedFile;

  bool isLoading = false;
  Future<void> _fetchLeaveType() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('type_leave').get();
      final leaveTypes = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();

      setState(() {
        _leaveType = leaveTypes;
      });
    } catch (error) {
      print("Failed to fetch leave types: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    String formattedFromDate =
        DateFormat('dd/MM/yyyy').format(selectedFromDate);
    String formattedToDate = DateFormat('dd/MM/yyyy').format(selectedToDate);
    datefromeController.text = formattedFromDate;
    datetoController.text = formattedToDate;
    _fetchLeaveType();
    _calculateDayDifference();
  }

  @override
  void dispose() {
    datefromeController.dispose();
    datetoController.dispose();
    daySummaryController.dispose();
    documentController.dispose();
    super.dispose();
  }

  void _calculateDayDifference() {
    if (datefromeController.text.isNotEmpty &&
        datetoController.text.isNotEmpty) {
      DateTime fromDate =
          DateFormat('dd/MM/yyyy').parse(datefromeController.text);
      DateTime toDate = DateFormat('dd/MM/yyyy').parse(datetoController.text);
      int dayDifference = toDate.difference(fromDate).inDays +
          1; // Include both start and end date
      daySummaryController.text = "ສະຫຼຸບວັນພັກ : $dayDifference ວັນ";
    }
  }

  Future<void> _saveDayData() async {
    try {
      List<String> imageUrls = [];
      String? documentUrl;

      // Handle images
      if (_mages.isNotEmpty) {
        for (var imageFile in _mages) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageRef =
              FirebaseStorage.instance.ref().child('leave_images/$fileName');
          UploadTask uploadTask = storageRef.putFile(imageFile);
          TaskSnapshot snapshot = await uploadTask;
          String imageUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }
      } else {
        imageUrls = ["ບໍ່ມີຂໍ້ມູນ"];
      }

      // Handle document
      if (_pickedFile != null && _pickedFile!.files.isNotEmpty) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('leave_documents/$fileName.pdf');
        UploadTask uploadTask =
            storageRef.putFile(File(_pickedFile!.files.single.path!));
        TaskSnapshot snapshot = await uploadTask;
        documentUrl = await snapshot.ref.getDownloadURL();
      } else {
        documentUrl = "ບໍ່ມີຂໍ້ມູນ";
      }

      // Convert dates to Timestamps
      Timestamp fromDateTime = Timestamp.fromDate(selectedFromDate);
      Timestamp toDateTime = Timestamp.fromDate(selectedToDate);

      // Fetch Employee data
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: Employee.employeeId)
          .get();

      if (snap.docs.isNotEmpty) {
        DocumentReference leaveRequests = FirebaseFirestore.instance
            .collection("Employee")
            .doc(snap.docs[0].id)
            .collection("Leave")
            .doc();
        await leaveRequests.set({
          'user': Employee.employeeId,
          'name': Employee.firstName,
          'leaveType': selectedLeaveType,
          'fromDate': fromDateTime,
          'toDate': toDateTime,
          'daySummary': daySummaryController.text,
          'imageUrl': imageUrls,
          'documentUrl': documentUrl,
          'doc': documentController.text,
          'date': Timestamp.fromDate(DateTime.now()),
          'status': 'ລໍຖ້າອະນຸມັດ',
          'type': 'ລາພັກແບບວັນ'
        });

        if (!mounted) return; // ป้องกัน error ถ้า context ถูก dispose ไปแล้ว
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Lottie.asset('assets/svg/successfully.json',
                  width: 70, height: 70),
              content: Text('ສົ່ງຂໍລາພັກສໍາເລັດ \nລໍຖ້າການອະນຸມັດ',
                  style: GoogleFonts.notoSansLao(fontSize: 17)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryLeave(),
                      ),
                    ).whenComplete(() {
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text('ຕົກລົງ',
                      style: GoogleFonts.notoSansLao(fontSize: 17)),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Employee not found!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _pickImageFromGallery() async {
      final returnImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (returnImage != null && returnImage.path.isNotEmpty) {
        setState(() {
          _mages.add(File(returnImage.path));
        });
      }
      Navigator.pop(context);
    }

    Future<void> _pickImageFromCamera() async {
      final returnImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (returnImage != null && returnImage.path.isNotEmpty) {
        setState(() {
          _mages.add(File(returnImage.path));
        });
        print("🤮 ${_mages}");
      }
      Navigator.pop(context); // Dismiss the modal
    }

    void showImage(BuildContext context) {
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
                              size: 50,
                              color: Colors.blue,
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
                              color: Colors.blue,
                              size: 50,
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

    Future<void> showFilePicker() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = result;
        });
      }
    }

    return Column(
      children: [
        Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: selectedLeaveType,
            hint: Text(
              'ເລຶອກປະເພດລາພັກ',
              style: GoogleFonts.notoSansLao(
                textStyle: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
            onChanged: (String? newValue) {
              setState(() {
                selectedLeaveType = newValue;
                leaveTypeId = _leaveType
                    .firstWhere((type) => type['name'] == newValue)['id'];
              });
            },
            items: _leaveType
                .map<DropdownMenuItem<String>>((Map<String, dynamic> type) {
              return DropdownMenuItem<String>(
                value: type['name'], // Use the name as the display value
                child: Text(
                  type['name'],
                  style: GoogleFonts.notoSansLao(
                    textStyle:
                        const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
              );
            }).toList(),
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            underline: const SizedBox(),
          ),
        ).animate().scaleXY(
            begin: 0,
            end: 1,
            delay: 300.ms,
            duration: 300.ms,
            curve: Curves.easeInOutCubic),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(Icons.close),
                            ),
                            Expanded(
                              child: CupertinoDatePicker(
                                initialDateTime: selectedFromDate,
                                mode: CupertinoDatePickerMode.date,
                                onDateTimeChanged: (date) {
                                  setState(() {
                                    selectedFromDate = date;
                                    datefromeController.text =
                                        DateFormat('dd/MM/yyyy')
                                            .format(selectedFromDate);
                                    _calculateDayDifference();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ຈາກວັນທີ",
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    AbsorbPointer(
                      child: TextFormField(
                        controller: datefromeController,
                        cursorColor: Colors.white,
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: "ຈາກວັນທີ",
                          hintStyle: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black38,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.date_range_sharp,
                            color: Colors.black38,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scaleXY(
                begin: 0,
                end: 1,
                delay: 300.ms,
                duration: 300.ms,
                curve: Curves.easeInOutCubic),
            const SizedBox(width: 10), // Space between the two fields
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(Icons.close),
                            ),
                            Expanded(
                              child: CupertinoDatePicker(
                                minimumDate: selectedFromDate,
                                initialDateTime: selectedToDate,
                                mode: CupertinoDatePickerMode.date,
                                onDateTimeChanged: (date) {
                                  setState(() {
                                    selectedToDate = date;
                                    datetoController.text =
                                        DateFormat('dd/MM/yyyy')
                                            .format(selectedToDate);
                                    _calculateDayDifference();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ຫາວັນທີ",
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    AbsorbPointer(
                      child: TextFormField(
                        controller: datetoController,
                        cursorColor: Colors.white,
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: "ຫາວັນທີ",
                          hintStyle: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black38,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.date_range,
                            color: Colors.black38,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scaleXY(
                begin: 0,
                end: 1,
                delay: 300.ms,
                duration: 300.ms,
                curve: Curves.easeInOutCubic),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: daySummaryController,
          cursorColor: Colors.white,
          style: GoogleFonts.notoSansLao(
            textStyle: const TextStyle(
                fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          decoration: InputDecoration(
            hintText: "ສະຫຼຸບວັນພັກ",
            hintStyle: GoogleFonts.notoSansLao(
              textStyle: const TextStyle(
                fontSize: 15,
                color: Colors.black38,
              ),
            ),
            prefixIcon: const Icon(
              Icons.science_outlined,
              color: Colors.black38,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black12),
            ),
          ),
        ).animate().scaleXY(
            begin: 0,
            end: 1,
            delay: 300.ms,
            duration: 300.ms,
            curve: Curves.easeInOutCubic),
        SizedBox(height: 10),
        Row(
          children: [
            Text(
              'ລາຍລະອຽດ',
              style: GoogleFonts.notoSansLao(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ).animate().scaleXY(
            begin: 0,
            end: 1,
            delay: 300.ms,
            duration: 300.ms,
            curve: Curves.easeInOutCubic),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              TextFormField(
                cursorColor: Colors.white,
                controller: documentController,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: "ເຫດຜົນ",
                  hintStyle: GoogleFonts.notoSansLao(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.book, // Choose an appropriate icon
                    color: Colors.black38,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                  onTap: () {
                    showFilePicker();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      height: 60,
                      child: Row(children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              _pickedFile != null
                                  ? const Icon(
                                      Icons
                                          .picture_as_pdf, // Display PDF icon when file is selected
                                      color: Colors.red,
                                      size: 40,
                                    )
                                  : Icon(
                                      Icons.description, // Placeholder icon
                                      color: Colors.grey.shade600,
                                    ),
                              SizedBox(width: 10),
                              _pickedFile != null
                                  ? Text(
                                      _pickedFile!.files.first
                                          .name, // Display the file name
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "ເອກະສານ (ຖ້າມີ)",
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ]))),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  showImage(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  height: 60,
                  child: Row(
                    children: [
                      _mages.isNotEmpty
                          ? Row(
                              children: _mages.map((file) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.file(
                                    file,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "ຮູບພາບ (ຖ້າມີ)",
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ).animate().scaleXY(
            begin: 0,
            end: 1,
            delay: 300.ms,
            duration: 300.ms,
            curve: Curves.easeInOutCubic),
        SizedBox(height: 20),
        SizedBox(
          height: 60,
          width: 600,
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () async {
                    setState(() {
                      isLoading = true;
                    });
                    await Future.delayed(const Duration(seconds: 2));
                    _saveDayData();

                    setState(() {
                      isLoading = false;
                    });
                  },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              side: const BorderSide(
                  color: Colors.white), // Ensure to add const here
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? Text(
                    'ກໍາລັງສົ່ງຄໍາຂໍລາພັກ .....', // Fixed the placement of the text
                    style: GoogleFonts.notoSansLao(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'ສົ່ງຄໍາຂໍລາພັກ', // Fixed the placement of the text
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ).animate().scaleXY(
            begin: 0,
            end: 1,
            delay: 300.ms,
            duration: 300.ms,
            curve: Curves.easeInOutCubic),
      ],
    );
  }
}

class TimesScreens extends StatefulWidget {
  const TimesScreens({Key? key}) : super(key: key);

  @override
  _TimesScreensState createState() => _TimesScreensState();
}

class _TimesScreensState extends State<TimesScreens> {
  DateTime selectedDate = DateTime.now();
  TextEditingController timefromeController = TextEditingController();
  TextEditingController timetoController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  String calculatedDuration = "";
  DateTime selectedFromTime = DateTime.now();
  DateTime selectedToTime = DateTime.now();
  String? leaveTpe;
  List<String> leaveTpeItems = ['ລາພັກປະຈໍາປີ', 'ລາພັກປ່ວຍ'];
  File? _mages;
  FilePickerResult? _pickedFile;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    timefromeController.text = DateFormat('HH:mm').format(selectedDate);
    timetoController.text = DateFormat('HH:mm').format(selectedDate);
    dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  }

  @override
  void dispose() {
    timefromeController.dispose();
    timetoController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void _calculateDuration() {
    if (selectedFromTime != null && selectedToTime != null) {
      Duration difference = selectedToTime.difference(selectedFromTime);
      setState(() {
        if (difference.inMinutes >= 0) {
          // Calculate hours and minutes
          int hours = difference.inHours;
          int minutes = difference.inMinutes % 60;
          calculatedDuration =
              "$hours ຊົ່ວໂມງ ${minutes > 0 ? '$minutes ນາທີ' : ''}";
        } else {
          calculatedDuration = "Invalid time range";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _pickImageFromGallery() async {
      final returnImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (returnImage != null && returnImage.path.isNotEmpty) {
        setState(() {
          _mages = File(returnImage.path);
        });
      }
      Navigator.pop(context);
    }

    Future<void> _pickImageFromCamera() async {
      final returnImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (returnImage != null && returnImage.path.isNotEmpty) {
        setState(() {
          _mages = File(
              returnImage.path); // Update the state with the selected image
        });
        print("🤮 ${_mages}");
      }
      Navigator.pop(context); // Dismiss the modal
    }

    void showImage(BuildContext context) {
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
                              size: 50,
                              color: Colors.blue,
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
                              color: Colors.blue,
                              size: 50,
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

    Future<void> showFilePicker() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = result;
        });
      }
    }

    Future<void> _saveTimeData() async {
      try {
        List<String> imageUrls = [];
        String? documentUrl;

        if (_mages != null && _mages!.path.isNotEmpty) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageRef =
              FirebaseStorage.instance.ref().child('leave_images/$fileName');
          UploadTask uploadTask = storageRef.putFile(_mages!);
          TaskSnapshot snapshot = await uploadTask;
          String imageUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        } else {
          imageUrls = ["ບໍ່ມີຂໍ້ມູນ"];
        }
        // Check if a PDF is picked and upload it
        if (_pickedFile != null && _pickedFile!.files.isNotEmpty) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('leave_documents/$fileName.pdf');
          UploadTask uploadTask =
              storageRef.putFile(File(_pickedFile!.files.single.path!));
          TaskSnapshot snapshot = await uploadTask;
          documentUrl = await snapshot.ref.getDownloadURL();
        } else {
          documentUrl = "ບໍ່ມີຂໍ້ມູນ"; // No data
        }

        // Retrieve the employee document reference
        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection("Employee")
            .where('id', isEqualTo: Employee.employeeId)
            .get();

        if (snap.docs.isNotEmpty) {
          // Get the Leave subcollection reference
          DocumentReference leaveRequests = FirebaseFirestore.instance
              .collection("Employee")
              .doc(snap.docs[0].id) // Use the employee's document ID
              .collection("Leave")
              .doc(); // Create a new document

          // Add the leave request data
          Timestamp fromTime = Timestamp.fromDate(selectedFromTime);
          Timestamp toTime = Timestamp.fromDate(selectedToTime);

          await leaveRequests.set({
            'user': Employee.id,
            'name': Employee.firstName,
            'date': dateController.text,
            'leaveType': leaveTpe,
            'fromDate': fromTime,
            'toDate': toTime,

            'daySummary': calculatedDuration,
            'imageUrl': imageUrls, // Save the image URL
            'documentUrl': documentUrl,
            'date': Timestamp.fromDate(DateTime.now()),
            'status': 'ລໍຖ້າອະນຸມັດ',
            'doc': documentController.text,
            'type': 'ລາພັກແບບຊົ່ວໂມງ'
          });

          if (!mounted) return; // ป้องกัน error ถ้า context ถูก dispose ไปแล้ว
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Lottie.asset('assets/svg/successfully.json',
                    width: 70, height: 70),
                content: Text('ສົ່ງຂໍລາພັກສໍາເລັດ \nລໍຖ້າການອະນຸມັດ',
                    style: GoogleFonts.notoSansLao(fontSize: 17)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryLeave(),
                        ),
                      ).whenComplete(() {
                        Navigator.of(context).pop();
                      });
                    },
                    child: Text('ຕົກລົງ',
                        style: GoogleFonts.notoSansLao(fontSize: 17)),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Employee not found!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save data: $e")),
        );
      }
    }

    return Column(
      children: [
        Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: leaveTpe, // This will store the selected value
            hint: Text(
              'ເລຶອກປະເພດລາພັກ',
              style: GoogleFonts.notoSansLao(
                textStyle: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ),
            onChanged: (String? newValue) {
              setState(() {
                leaveTpe = newValue; // Update the selected leave type
              });
            },
            items: leaveTpeItems.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value, // Display the correct leave type from the list
                  style: GoogleFonts.notoSansLao(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            underline: const SizedBox(),
          ),
        ),
        const SizedBox(height: 20),
        // Date Picker
        GestureDetector(
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.close),
                      ),
                      Expanded(
                        child: CupertinoDatePicker(
                          initialDateTime: selectedDate,
                          mode: CupertinoDatePickerMode.date,
                          onDateTimeChanged: (date) {
                            setState(() {
                              selectedDate = date;
                              dateController.text = "${selectedDate.toLocal()}"
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
              controller: dateController,
              cursorColor: Colors.white,
              style: GoogleFonts.notoSansLao(
                textStyle: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              decoration: InputDecoration(
                hintText: "ຈາກວັນທີ",
                hintStyle: GoogleFonts.notoSansLao(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.black38,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.date_range_sharp,
                  color: Colors.black38,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        // Start Time Picker
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.close),
                            ),
                            Expanded(
                              child: CupertinoDatePicker(
                                initialDateTime: selectedDate,
                                mode: CupertinoDatePickerMode.time,
                                onDateTimeChanged: (date) {
                                  setState(() {
                                    selectedFromTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      date.hour,
                                      date.minute,
                                    );
                                    timefromeController.text =
                                        DateFormat('HH:mm').format(
                                            selectedFromTime); // Update the controller with the new time
                                    _calculateDuration(); // Calculate duration whenever the time is selected
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ຈາກເວລາ",
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    AbsorbPointer(
                      child: TextFormField(
                        controller: timefromeController,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: "ເວລາເລີ່ມ",
                          hintStyle: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black38,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_clock,
                            color: Colors.black38,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.close),
                            ),
                            Expanded(
                              child: CupertinoDatePicker(
                                minimumDate: selectedFromTime,
                                initialDateTime: selectedDate,
                                mode: CupertinoDatePickerMode.time,
                                onDateTimeChanged: (date) {
                                  setState(() {
                                    selectedToTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      date.hour,
                                      date.minute,
                                    );
                                    timetoController.text = DateFormat('HH:mm')
                                        .format(
                                            selectedToTime); // Update the controller with the new time
                                    _calculateDuration(); // Calculate duration whenever the time is selected
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ຮອດເວລາ",
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    AbsorbPointer(
                      child: TextFormField(
                        controller: timetoController,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: "ເວລາສີ້ນສຸດ",
                          hintStyle: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black38,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_clock,
                            color: Colors.black38,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
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
        SizedBox(height: 10),
        // Duration Output Field
        TextFormField(
          cursorColor: Colors.white,
          readOnly: true, // Make this field read-only
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: "ສະຫຼຸບຊົ່ວໂມງພັກ: $calculatedDuration",
            hintStyle: GoogleFonts.notoSansLao(
              textStyle: const TextStyle(
                fontSize: 15,
                color: Colors.black38,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black12),
            ),
          ),
        ),

        SizedBox(height: 20),
        Row(
          children: [
            Text(
              'ລາຍລະອຽດ',
              style: GoogleFonts.notoSansLao(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              TextFormField(
                cursorColor: Colors.white,
                controller: documentController,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: "ເຫດຜົນ",
                  hintStyle: GoogleFonts.notoSansLao(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.black38,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.book, // Choose an appropriate icon
                    color: Colors.black38,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                  onTap: () {
                    showFilePicker();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      height: 60,
                      child: Row(children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              _pickedFile != null
                                  ? Icon(
                                      Icons
                                          .picture_as_pdf, // Display PDF icon when file is selected
                                      color: Colors.red,
                                      size: 40,
                                    )
                                  : Icon(
                                      Icons.description, // Placeholder icon
                                      color: Colors.grey.shade600,
                                    ),
                              SizedBox(width: 10),
                              _pickedFile != null
                                  ? Text(
                                      _pickedFile!.files.first
                                          .name, // Display the file name
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "ເອກະສານ (ຖ້າມີ)",
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ]))),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  showImage(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  height: 60,
                  child: Row(
                    children: [
                      _mages != null
                          ? Image.file(
                              _mages!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "ຮູບພາບ (ຖ້າມີ)",
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),

        SizedBox(height: 20),
        SizedBox(
          height: 60,
          width: 600,
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () async {
                    setState(() {
                      isLoading = true;
                    });
                    await Future.delayed(const Duration(seconds: 2));

                    _saveTimeData();
                    setState(() {
                      isLoading = false;
                    });
                  },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              side: const BorderSide(
                  color: Colors.white), // Ensure to add const here
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? Text(
                    'ກໍາລັງສົ່ງຄໍາຂໍລາພັກ .....', // Fixed the placement of the text
                    style: GoogleFonts.notoSansLao(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'ສົ່ງຄໍາຂໍລາພັກ', // Fixed the placement of the text
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
