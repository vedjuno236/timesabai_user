# timesabai

A new Flutter project.

## Getting Started

ແອັບນີ້ສ້າງຊື້ນມາເພື່ອບົດຈົບເຈົ້າເດີ 🥰🐟
------/----- ຮາຮາຮາາາາາາາາາາາາາ

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.








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