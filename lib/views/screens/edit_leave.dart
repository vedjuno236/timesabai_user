
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:timesabai/views/screens/history_leave.dart';

import '../../components/model/user_model/user_model.dart';

class EditLeave extends StatefulWidget {
  final String documentId;

  const EditLeave({Key? key, required this.documentId}) : super(key: key);

  @override
  _EditLeaveState createState() => _EditLeaveState();
}

class _EditLeaveState extends State<EditLeave> {
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();

  TextEditingController datefromeController = TextEditingController();
  TextEditingController datetoController = TextEditingController();
  TextEditingController daySummaryController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  String? leaveTpe;
  List<String> leaveTpeItems = ['ລາພັກປະຈໍາປີ', 'ລາພັກປ່ວຍ'];
  List<File> _mages = [];

  FilePickerResult? _pickedFile;
  String _imageUrl = '';

  bool isLoading = false;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    String formattedFromDate = DateFormat('dd/MM/yyyy').format(
        selectedFromDate);
    String formattedToDate = DateFormat('dd/MM/yyyy').format(selectedToDate);
    datefromeController.text = formattedFromDate;
    datetoController.text = formattedToDate;
    _calculateDayDifference();
    _loadLeaveData();
    _initializeDateFields();
  }

  @override
  void dispose() {
    datefromeController.dispose();
    datetoController.dispose();
    daySummaryController.dispose();
    documentController.dispose();
    super.dispose();
  }
  void _initializeDateFields() {
    datefromeController.text = _formatDate(selectedFromDate);
    datetoController.text = _formatDate(selectedToDate);
    _calculateDayDifference();
  }
  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);


  void _calculateDayDifference() {
    if (datefromeController.text.isNotEmpty &&
        datetoController.text.isNotEmpty) {
      DateTime fromDate = DateFormat('dd/MM/yyyy').parse(
          datefromeController.text);
      DateTime toDate = DateFormat('dd/MM/yyyy').parse(datetoController.text);
      int dayDifference = toDate
          .difference(fromDate)
          .inDays + 1;
      daySummaryController.text = "ສະຫຼຸບວັນພັກ : $dayDifference ວັນ";
    }
  }

  Future<void> _loadLeaveData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(Employee.id)
          .collection("Leave")
          .doc(widget.documentId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Document Data: $data');

        leaveTpe = data['leaveType'] ?? '';
        documentController.text = data['doc'] ?? '';
        daySummaryController.text = data['daySummary'] ?? '';
        _fromDate = (data['fromDate'] as Timestamp).toDate();
        _toDate = (data['toDate'] as Timestamp).toDate();
        datefromeController.text = DateFormat('dd MMMM yyyy').format(_fromDate!);
        datetoController.text = DateFormat('dd MMMM yyyy').format(_toDate!);


        String imageUrl = data['imageUrl'] ?? '';
        if (imageUrl.isNotEmpty) {
          print('Image URL: $imageUrl');
          setState(() {
            _imageUrl = imageUrl;
          });
        } else {
          print('No image URL found');
        }

        print('Leave Type loaded: $leaveTpe');
      } else {
        print("Document not found");
      }
    } catch (e) {
      print("Error loading leave data: $e");
    }
  }



  Future<void> _updateLeaveData() async {
    try {

      Timestamp fromDateTime = Timestamp.fromDate(selectedFromDate);
      Timestamp toDateTime = Timestamp.fromDate(selectedToDate);

      List<String> imageUrls = [];
      if (_mages != null && _mages!.isNotEmpty) {
        for (var image in _mages!) {
          String imageUrl = await _uploadImageToFirebase(image);
          if (imageUrl.isNotEmpty) {
            imageUrls.add(imageUrl);
          }
        }
      } else if (_imageUrl.isNotEmpty) {
        imageUrls.add(_imageUrl);
      }

      await FirebaseFirestore.instance
          .collection("Employee")
          .doc(Employee.id)
          .collection("Leave")
          .doc(widget.documentId)
          .update({
        'leaveType': leaveTpe,
        'doc': documentController.text,
        'fromDate': fromDateTime,
        'toDate': toDateTime,
        'imageUrl': imageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Leave data updated successfully")),

      );
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryLeave())
      );
    } catch (e) {
      print("Error updating leave data: $e");
    }
  }

// Method to upload an image to Firebase Storage
  Future<String> _uploadImageToFirebase(File image) async {
    try {
      // Generate a unique file name using timestamp
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('leave_images/$fileName');

      // Upload the image to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

      // Get the download URL
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return ''; // Return empty string if the upload fails
    }
  }



  @override
  Widget build(BuildContext context) {

    Future<void> _pickImageFromGallery() async {
      final returnImage = await ImagePicker().pickImage(
          source: ImageSource.gallery);
      if (returnImage != null && returnImage.path.isNotEmpty) {
        setState(() {
          _mages .add( File(returnImage.path));
          _imageUrl='';
        });
      }
      Navigator.pop(context);
    }
    Future<void> _pickImageFromCamera() async {
      final returnImage = await ImagePicker().pickImage(source: ImageSource.camera);
      if (returnImage != null && returnImage.path.isNotEmpty) {
        setState(() {
          _mages .add( File(returnImage.path));
          _imageUrl='';
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

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1230AE),
        title: Text(
          'ແກ້ໄຂການລາພັກ',
          style: GoogleFonts.notoSansLao(
            textStyle: const TextStyle(
              fontSize:15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
                child: DropdownButton<String>(
                  value: leaveTpe,
                  hint: Text(
                    'ເລຶອກປະເພດລາພັກ${leaveTpe?.isNotEmpty == true ? ' : $leaveTpe' : ''}',
                    style: GoogleFonts.notoSansLao(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      leaveTpe = newValue ?? '';  // If null, set to empty string
                    });
                  },
                  items: leaveTpeItems.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,  // Display the correct leave type from the list
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
                )



            ),
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
                                        datefromeController.text = DateFormat('dd/MM/yyyy').format(selectedFromDate);
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
                        Text("ຈາກວັນທີ", style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),),
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
                ),
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
                                    initialDateTime: selectedToDate,
                                    mode: CupertinoDatePickerMode.date,
                                    onDateTimeChanged: (date) {
                                      setState(() {
                                        selectedToDate = date;
                                        datetoController.text = DateFormat('dd/MM/yyyy').format(selectedToDate);
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
                        Text("ຫາວັນທີ", style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),),
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
                ),
              ],
            ),

            const SizedBox(height: 10),
            TextFormField(
              controller: daySummaryController,
              cursorColor: Colors.white,
              style:  GoogleFonts.notoSansLao(
                textStyle: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                ),
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
            ),


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
                      onTap: (){
                        showFilePicker();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),

                          height: 60,
                          child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      _pickedFile != null
                                          ? const Icon(
                                        Icons.picture_as_pdf, // Display PDF icon when file is selected
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
                                        _pickedFile!.files.first.name, // Display the file name
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
                      showImage(context);  // เปิดการเลือกภาพเมื่อกด
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      height: 60,
                      child: Row(
                        children: [
                          if (_imageUrl.isNotEmpty)
                            Image.network(
                              _imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          else if (_mages != null)
                            if (_mages.isNotEmpty)
                              Row(
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
                              ),

                          if (_mages.isEmpty )
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "ຮູບພາບ (ຖ້າມີ)",  // ข้อความบอกว่า "ภาพ (ถ้ามี)"
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
                  await Future.delayed(
                      const Duration(seconds: 2));
                  _updateLeaveData();

                  setState(() {
                    isLoading = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  side: const BorderSide(color: Colors.white), // Ensure to add const here
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SpinKitCircle(
                  color: Colors.white,
                  size: 30.0,
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send,color: Colors.white,),
                    const SizedBox(width: 20),
                    Text(
                      'ແກ້ໄຂການລາພັກ', // Fixed the placement of the text
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
        ),
      ),
    );

  }
}

