import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';

import '../../components/model/user_model/user_model.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String _month = DateFormat('MMMM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor:   Color(0xFF577DF4),
          elevation: 0,
          title: Row(
            children: [
              Text(
                'ປະຫວັດມາການ',
                style: GoogleFonts.notoSansLao(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                'ເດືອນ: $_month',
                style: GoogleFonts.notoSansLao(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () async {
                  final selectedDate =
                      await SimpleMonthYearPicker.showMonthYearPickerDialog(
                    context: context,
                    titleTextStyle: GoogleFonts.notoSansLao(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1230AE),
                      ),
                    ),
                    monthTextStyle: GoogleFonts.notoSansLao(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1230AE),
                      ),
                    ),
                    yearTextStyle: GoogleFonts.notoSansLao(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1230AE),
                      ),
                    ),
                    disableFuture: true,
                  );

                  if (selectedDate != null) {
                    final DateFormat laoDateFormat = DateFormat.MMMM('lo');
                    String formattedDate = laoDateFormat.format(selectedDate);

                    print('Selected Date in Lao: $formattedDate');

                    setState(() {
                      _month = formattedDate;
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "ເລືອກເດືອນ: ${_month.isEmpty ? "ເລືອກເດືອນ" : _month}",
                    style: GoogleFonts.notoSansLao(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1230AE),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Expanded(
                // child: StreamBuilder<QuerySnapshot>(
                //     stream: FirebaseFirestore.instance
                //         .collection("Employee")
                //     .doc(Employee.id)
                //     .collection("Record")
                //     .snapshots(),
                child: StreamBuilder<QuerySnapshot>(
                  stream: (Employee.id != null && Employee.id.isNotEmpty)
                      ? FirebaseFirestore.instance
                          .collection("Employee")
                          .doc(Employee.id)
                          .collection("Record")
                          .snapshots()
                      : null,
                      
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                          child: Text('An error occurred: ${snapshot.error}'));
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final snap = snapshot.data!.docs;

                      final currentDate = DateTime.now();

                      List<QueryDocumentSnapshot> todayRecords = [];
                      List<QueryDocumentSnapshot> otherRecords = [];

                      for (var record in snap) {
                        DateTime recordDate = record['date'].toDate();
                        if (recordDate.year == currentDate.year &&
                            recordDate.month == currentDate.month &&
                            recordDate.day == currentDate.day) {
                          todayRecords.add(record);
                        } else {
                          otherRecords.add(record);
                        }
                      }

                      otherRecords
                          .sort((a, b) => b['date'].compareTo(a['date']));
                      List<QueryDocumentSnapshot> sortedRecords = [
                        ...todayRecords,
                        ...otherRecords
                      ];

                      return ListView.separated(
                        itemCount: sortedRecords.length,
                        itemBuilder: (context, index) {
                          DateTime recordDate =
                              sortedRecords[index]['date'].toDate();
                          return DateFormat('MMMM', 'lo')
                                      .format(snap[index]['date'].toDate()) ==
                                  _month
                              ? Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 90,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.black12,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              children: [
                                                Center(
                                                  child: Text(
                                                    DateFormat(' dd EE ')
                                                        .format(recordDate),
                                                    style:
                                                        GoogleFonts.notoSansLao(
                                                      textStyle:
                                                          const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        Column(
                                          children: [
                                            Text('ບັນທືກເຂົ້າ',
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                )),
                                            Text(
                                                sortedRecords[index]['checkIn'],
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                )),
                                          ],
                                        ),
                                        SizedBox(width: 15),
                                        Column(
                                          children: [
                                            Text('ບັນທືກອອກ',
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                )),
                                            Text(
                                                sortedRecords[index]
                                                    ['checkOut'],
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.redAccent,
                                                  ),
                                                )),
                                          ],
                                        ),
                                        SizedBox(width: 20),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: getStatusColor(
                                                sortedRecords[index]['status']),
                                            side: BorderSide(
                                                color: Colors.black12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () {},
                                          child: Text(
                                            sortedRecords[index]['status'],
                                            style: GoogleFonts.notoSansLao(
                                              textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : SizedBox();
                        },
                        separatorBuilder: (context, index) => const Divider(
                          height: 30,
                          color: Colors.black12,
                          thickness: 1,
                          indent: 10,
                          endIndent: 10,
                        ),
                      );
                    } else {
                      return Center(
                          child: Text('ບໍ່ມີຂໍ້ມູນ !!.',
                              style: GoogleFonts.notoSansLao(
                                textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              )));
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

Color getStatusColor(String status) {
  switch (status) {
    case 'ມາວຽກຊ້າ':
      return Colors.orange;
    case 'ຂາດວຽກ':
      return Colors.red;
    case 'ວັນພັກ':
      return Colors.grey;
    default:
      return Colors.blue;
  }
}
