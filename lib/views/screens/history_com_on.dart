import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';
import 'package:timesabai/views/widgets/date_month_year/shared/month_picker.dart';

import '../../components/model/user_model/user_model.dart';
import '../widgets/month_widget/month_widget.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String _month = DateFormat('MMMM yyyy').format(DateTime.now());
  DateTime? selectedDate = DateTime.now();

  // Function to get days from the start of the month to the current date
  List<DateTime> getDaysFromStartOfMonthToCurrent(
      DateTime selected, DateTime current) {
    final firstDayOfMonth = DateTime(selected.year, selected.month, 1);
    final lastDay =
        (current.year == selected.year && current.month == selected.month)
            ? current
            : DateTime(selected.year, selected.month + 1, 0);
    final daysCount = lastDay.day - firstDayOfMonth.day + 1;
    return List.generate(
      daysCount,
      (i) => DateTime(selected.year, selected.month, firstDayOfMonth.day + i),
    ).reversed.toList();
  }

  // Function to check if a day is Saturday or Sunday
  bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF577DF4),
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
                  fontSize: 12,
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
                //   final pickedDate = await showMonthPicker(
                //     context: context,
                //     initialDate: selectedDate ?? DateTime.now(),
                //     firstDate: DateTime(2024),
                //     lastDate: DateTime(2050),
                //   );

                //   if (pickedDate != null) {
                //     setState(() {
                //       selectedDate = pickedDate;
                //       _month = DateFormat.yMMMM('lo').format(pickedDate).trim();
                //     });
                //   }
                // },
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    DateTime now = DateTime.now();
                    DateTime maxDate = DateTime(now.year, now.month + 1, 0);
                    DateTime? tempSelectedMonth = selectedDate;
                    return AlertDialog(
                      elevation: 2,
                      shadowColor: Colors.blue,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      content: SizedBox(
                        height: 300,
                        width: 450,
                        child: MonthPicker(
                          selectedCellDecoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          selectedCellTextStyle: GoogleFonts.notoSansLao(
                            fontSize: 14,
                          ),
                          enabledCellsTextStyle: GoogleFonts.notoSansLao(
                            fontSize: 14,
                          ),
                          disabledCellsTextStyle: GoogleFonts.notoSansLao(
                              fontSize: 14, color: Colors.grey),
                          currentDateTextStyle: GoogleFonts.notoSansLao(
                            fontSize: 14,
                          ),
                          currentDateDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1,
                              color: Colors.black,
                            ),
                          ),
                          splashColor: Colors.blue,
                          slidersColor: Colors.black,
                          centerLeadingDate: true,
                          minDate: DateTime(2000),
                          currentDate: selectedDate ?? DateTime.now(),
                          selectedDate: selectedDate ?? DateTime.now(),
                          onDateSelected: (month) {
                            setState(() {
                              tempSelectedMonth = month;
                            });
                          },
                          maxDate: maxDate,
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.grey,
                            ),
                            child: Text('ຍົກເລີກ',
                                style: GoogleFonts.notoSansLao(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            if (tempSelectedMonth != null &&
                                tempSelectedMonth != selectedDate) {
                              setState(() {
                                selectedDate = tempSelectedMonth!;
                                // _month = DateFormat('MMMM')
                                //     .format(selectedDate!);
                                _month = DateFormat.yMMMM('lo')
                                    .format(selectedDate!);
                              });
                            }
                            Navigator.pop(context);
                          },
                          child: Text(
                            'ຕົກລົງ',
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  " ${_month.isEmpty ? 'ເລືອກເດືອນ' : _month}",
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

                  final daysInRange = selectedDate != null
                      ? getDaysFromStartOfMonthToCurrent(
                          selectedDate!, currentDate)
                      : [];

                  Map<String, QueryDocumentSnapshot> recordsMap = {};
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    for (var record in snapshot.data!.docs) {
                      DateTime recordDate = record['date'].toDate();
                      String dateKey =
                          DateFormat('yyyy-MM-dd').format(recordDate);
                      recordsMap[dateKey] = record;
                    }
                  }

                  return ListView.builder(
                    itemCount: daysInRange.length,
                    itemBuilder: (context, index) {
                      DateTime currentDay = daysInRange[index];
                      String dateKey =
                          DateFormat('yyyy-MM-dd').format(currentDay);
                      QueryDocumentSnapshot? record = recordsMap[dateKey];

                      // Determine status and other fields
                      String status;
                      String checkInAM = '--:--';
                      String checkOutAM = '--:--';
                      String checkInPM = '--:--';
                      String checkOutPM = '--:--';

                      if (record != null) {
                        // Use Firebase record if available
                        status = record['status'];
                        checkInAM = record['clockInAM'];
                        checkOutAM = record['clockOutAM'];
                        checkInPM = record['clockInPM'];
                        checkOutPM = record['clockOutPM'];
                      } else {
                        // If no record, check if it's a weekend
                        status = isWeekend(currentDay) ? 'ວັນພັກ' : 'ຂາດວຽກ';
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 90,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Center(
                                          child: Text(
                                            DateFormat('dd EE')
                                                .format(currentDay),
                                            style: GoogleFonts.notoSansLao(
                                              textStyle: const TextStyle(
                                                fontSize: 12,
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
                                const SizedBox(width: 15),
                                Column(
                                  children: [
                                    Text(
                                      'ບັນທືກເຂົ້າ',
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          checkInAM,
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: record != null
                                                  ? Colors.blue
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          checkInPM,
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: record != null
                                                  ? Colors.blue
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  children: [
                                    Text(
                                      'ບັນທືກອອກ',
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          checkOutAM,
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: record != null
                                                  ? Colors.redAccent
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          checkOutPM,
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: record != null
                                                  ? Colors.redAccent
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 35,
                                  width: 75,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: getStatusColor(status),
                                      side: BorderSide(
                                          color: getStatusColor(status)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () {},
                                    child: Text(
                                      status,
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
}
