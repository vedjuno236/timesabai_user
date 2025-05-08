import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../components/model/user_model/user_model.dart';
import 'edit_leave.dart';

enum ViewType { wait, approved, refused }

final viewProvider = StateProvider<ViewType>((ref) => ViewType.wait);
final isWaitProvider = StateProvider<bool>((ref) => true);
final isApprovedProvider = StateProvider<bool>((ref) => false);
final isRefusedProvider = StateProvider<bool>((ref) => false);

class HistoryLeave extends ConsumerWidget {
  const HistoryLeave({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewType = ref.watch(viewProvider);
    final waitIsActive = ref.watch(isWaitProvider);
    final approvedIsActive = ref.watch(isApprovedProvider);
    final refusedIsActive = ref.watch(isRefusedProvider);

    final pageSection = viewType == ViewType.wait
        ? const Wait()
        : viewType == ViewType.approved
            ? const Approved()
            : const Refused();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF577DF4),
        title: Text(
          'ປະຫັວດລາພັກ',
          style: GoogleFonts.notoSansLao(
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 30),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(height: 70),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        ref.read(viewProvider.notifier).state = ViewType.wait;
                        ref.read(isWaitProvider.notifier).state = true;
                        ref.read(isApprovedProvider.notifier).state = false;
                        ref.read(isRefusedProvider.notifier).state = false;
                      },
                      child: ViewTypeButton(
                        title: "ລໍຖ້າອະນຸມັດ", // "Wait for approval"
                        isActive: waitIsActive,
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        ref.read(viewProvider.notifier).state =
                            ViewType.approved;
                        ref.read(isWaitProvider.notifier).state = false;
                        ref.read(isApprovedProvider.notifier).state = true;
                        ref.read(isRefusedProvider.notifier).state = false;
                      },
                      child: ViewTypeButton(
                        title: "ອະນຸມັດແລ້ວ", // "Approved"
                        isActive: approvedIsActive,
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        ref.read(viewProvider.notifier).state =
                            ViewType.refused;
                        ref.read(isWaitProvider.notifier).state = false;
                        ref.read(isApprovedProvider.notifier).state = false;
                        ref.read(isRefusedProvider.notifier).state = true;
                      },
                      child: ViewTypeButton(
                        title: "ຖຶກປະຕິເສດ", // "Refused"
                        isActive: refusedIsActive,
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
                Padding(padding: const EdgeInsets.all(8.0), child: pageSection),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms).move(
                  begin: const Offset(-16, 0),
                  curve: Curves.easeOutQuad,
                ),
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
      height: 40,
      width: 110,
      child: OutlinedButton(
        onPressed: () {
          ref.read(viewProvider.notifier).state = title == "ລໍຖ້າອະນຸມັດ"
              ? ViewType.wait
              : title == "ອະນຸມັດແລ້ວ"
                  ? ViewType.approved
                  : ViewType.refused;

          ref.read(isWaitProvider.notifier).state = title == "ລໍຖ້າອະນຸມັດ";
          ref.read(isApprovedProvider.notifier).state = title == "ອະນຸມັດແລ້ວ";
          ref.read(isRefusedProvider.notifier).state = title == "ຖຶກປະຕິເສດ";
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isActive ? Colors.blue : Colors.white,
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.notoSansLao(
            textStyle: style.copyWith(
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class Wait extends StatefulWidget {
  const Wait({super.key});

  @override
  State<Wait> createState() => _WaitState();
}

class _WaitState extends State<Wait> {
  @override
  Widget build(BuildContext context) {
    if (Employee.id == null || Employee.id!.isEmpty) {
      return const Center(
        child: SpinKitCircle(
          color: Colors.blue,
          size: 40.0,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Employee")
          .doc(Employee.id) // Make sure Employee.id is valid
          .collection("Leave")
          .where('status',
              isEqualTo: 'ລໍຖ້າອະນຸມັດ') // Filter for only "Pending" status
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // Check if the snapshot has data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SpinKitCircle(
              color: Colors.blue,
              size: 40.0,
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          // Reverse the list of documents
          final snap = snapshot.data!.docs.reversed.toList();

          return Container(
            height: MediaQuery.of(context).size.height - 200,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: snap.length,
              itemBuilder: (context, index) {
                final doc = snap[index];
                final data = snap[index].data() as Map<String, dynamic>;
                DateTime fromDate = (data['fromDate'] as Timestamp).toDate();
                DateTime toDate = (data['toDate'] as Timestamp).toDate();

                // Format the dates
                String formattedFromDate =
                    DateFormat('dd MMMM yyyy ').format(fromDate);
                String formattedToDate =
                    DateFormat('dd MMMM yyyy ').format(toDate);
                String formattedFromTime = DateFormat('hh:mm').format(fromDate);
                String formattedToTime = DateFormat(' hh:mm').format(toDate);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditLeave(documentId: doc.id)
                          // builder: (context) => EditLeave(documentId: doc.id),
                          ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'No Document',
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          text: 'ຮູບແບບລາພັກ:    ',
                          style: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          children: [
                            TextSpan(
                              text: data['type'] ?? 'No Document',
                              style: GoogleFonts.notoSansLao(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          text: 'ວັນທີ:    ',
                          style: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          children: [
                            TextSpan(
                              text: "  $formattedFromDate - $formattedToDate",
                              style: GoogleFonts.notoSansLao(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          text: 'ເວລາ:    ',
                          style: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          children: [
                            TextSpan(
                              text: "  $formattedFromTime - $formattedToTime",
                              style: GoogleFonts.notoSansLao(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          text: 'ເຫດຜົນ:    ',
                          style: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          children: [
                            TextSpan(
                              text: data['doc'] ?? 'No Document',
                              style: GoogleFonts.notoSansLao(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          text: 'ປະເພດລາພັກ:    ',
                          style: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          children: [
                            TextSpan(
                              text: data['leaveType'] ?? 'No Document',
                              style: GoogleFonts.notoSansLao(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).move(
                begin: const Offset(-16, 0),
                curve: Curves.easeOutQuad,
              );
        } else {
          return Center(
            child: Text(
              "ຍັງບໍ່ທັນມີຂໍ້ມູນ.",
              style: GoogleFonts.notoSansLao(
                textStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class Approved extends StatefulWidget {
  const Approved({super.key});

  @override
  State<Approved> createState() => _ApprovedState();
}

class _ApprovedState extends State<Approved> {
  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<List<LeaveModel>>(
    //   future: leaveService.fetchLeaves(), // Fetch the leave data
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(
    //           child: CircularProgressIndicator()); // Show loading indicator
    //     } else if (snapshot.hasError) {
    //       return Center(
    //           child: Text('Error: ${snapshot.error}')); // Show error message
    //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
    //       return const Center(
    //           child: Text('No leave data available')); // Show no data message
    //     }
    //
    //     final leaveList = snapshot.data!;
    //
    //     return Container(
    //       height: MediaQuery.of(context).size.height -200,// Use Expanded to fit the ListView in its parent
    //       child: ListView.builder(
    //         itemCount: leaveList.length,
    //         itemBuilder: (context, index) {
    //           final leave = leaveList[index];
    //
    //           // Check if the status is "Waiting for approval"
    //           if (leave.status == "ອະນຸມັດແລ້ວ") {
    //             return Container(
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(10),
    //                 color: Colors.white,
    //                 boxShadow: [ // Optional shadow for better visibility
    //                   BoxShadow(
    //                     color: Colors.black12,
    //                     blurRadius: 4.0,
    //                     spreadRadius: 1.0,
    //                     offset: Offset(2.0, 2.0),
    //                   ),
    //                 ],
    //               ),
    //               margin: const EdgeInsets.only(top: 10),
    //               padding: const EdgeInsets.all(20.0),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     leave.name, // Display the employee's name
    //                     style: GoogleFonts.notoSansLao(
    //                       textStyle: const TextStyle(
    //                         fontSize: 15,
    //                         color: Colors.black,
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(height: 5),
    //                   Text(
    //                     "ວັນທີ: ${leave.fromDate} - ${leave.toDate}",
    //                     // Display date range
    //                     style: GoogleFonts.notoSansLao(
    //                       textStyle: const TextStyle(
    //                         fontSize: 15,
    //                         color: Colors.black,
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(height: 5),
    //                   Text(
    //                     "ເຫດຜົນ: ${leave.doc ?? 'N/A'}",
    //                     // Display the reason for leave, handle null
    //                     style: GoogleFonts.notoSansLao(
    //                       textStyle: const TextStyle(
    //                         fontSize: 15,
    //                         color: Colors.black,
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(height: 5),
    //                   Text(
    //                     "ປະເພດລາພັກ: ${leave.leaveType}", // Display leave type
    //                     style: GoogleFonts.notoSansLao(
    //                       textStyle: const TextStyle(
    //                         fontSize: 15,
    //                         color: Colors.black,
    //                       ),
    //                     ),
    //                   ),
    //                   const SizedBox(height: 5),
    //                   Text(
    //                     "ຈໍານວນການລາພັກ: ${leave.daySummary ?? 'N/A'}",
    //                     // Display leave summary, handle null
    //                     style: GoogleFonts.notoSansLao(
    //                       textStyle: const TextStyle(
    //                         fontSize: 15,
    //                         color: Colors.black,
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             );
    //           } else {
    //             // Optionally, you could display something else for other statuses
    //             return const SizedBox
    //                 .shrink(); // If status is not "Waiting for approval", do not display anything
    //           }
    //         },
    //       ),
    //     );
    //   },
    // );

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Employee")
          .doc(Employee.id)
          .collection("Leave")
          .where('status', isEqualTo: 'ອະນຸມັດແລ້ວ')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SpinKitCircle(
              color: Colors.blue,
              size: 40.0,
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final snap = snapshot.data!.docs;

          return Container(
            height: MediaQuery.of(context).size.height - 200,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: snap.length,
              itemBuilder: (context, index) {
                final data = snap[index].data() as Map<String, dynamic>;
                DateTime fromDate = (data['fromDate'] as Timestamp).toDate();
                DateTime toDate = (data['toDate'] as Timestamp).toDate();

                String formattedFromDate =
                    DateFormat('dd MMMM yyyy ').format(fromDate);
                String formattedToDate =
                    DateFormat('dd MMMM yyyy ').format(toDate);
                String formattedFromTime = DateFormat('hh:mm').format(fromDate);
                String formattedToTime = DateFormat(' hh:mm').format(toDate);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? 'No Document',
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        text: 'ວັນທີ:    ',
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        children: [
                          TextSpan(
                            text: "  $formattedFromDate - $formattedToDate",
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        text: 'ເວລາ:    ',
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        children: [
                          TextSpan(
                            text: "  $formattedFromTime - $formattedToTime",
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        text: 'ເຫດຜົນ:    ',
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        children: [
                          TextSpan(
                            text: data['doc'] ?? 'No Document',
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        text: 'ປະເພດລາພັກ:    ',
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        children: [
                          TextSpan(
                            text: data['leaveType'] ?? 'No Document',
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => Divider(),
            ),
          );
        } else {
          return Center(
            child: Text(
              "ຍັງບໍ່ທັນມີຂໍ້ມູນ.",
              style: GoogleFonts.notoSansLao(
                textStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class Refused extends StatefulWidget {
  const Refused({super.key});

  @override
  State<Refused> createState() => _RefusedState();
}

class _RefusedState extends State<Refused> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Employee")
          .doc(Employee.id) // Use the passed employee ID
          .collection("Leave")
          .where('status',
              isEqualTo: 'ປະຕິເສດ') // Filter for only "Approved" status
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // Check if the snapshot has data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final snap = snapshot.data!.docs;

          return Container(
            height: MediaQuery.of(context).size.height - 200,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: snap.length,
              itemBuilder: (context, index) {
                final data = snap[index].data() as Map<String, dynamic>;
                DateTime fromDate = (data['fromDate'] as Timestamp).toDate();
                DateTime toDate = (data['toDate'] as Timestamp).toDate();

                // Format the dates
                String formattedFromDate =
                    DateFormat('dd MMMM yyyy').format(fromDate);
                String formattedToDate =
                    DateFormat('dd MMMM yyyy').format(toDate);
                String formattedFromTime = DateFormat('hh:mm').format(fromDate);
                String formattedToTime = DateFormat(' hh:mm').format(toDate);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? 'No Document',
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        text: 'ວັນທີ/ ເວລາ:    ',
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        children: [
                          TextSpan(
                            text: "  $formattedFromDate - $formattedToDate",
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        text: 'ເຫດຜົນ:    ',
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        children: [
                          TextSpan(
                            text: data['doc'] ?? 'No Document',
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        text: 'ວັນທີ/ ເວລາ:    ',
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        children: [
                          TextSpan(
                            text: "  $formattedFromTime- $formattedToTime",
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        text: 'ປະເພດລາພັກ:    ',
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        children: [
                          TextSpan(
                            text: data['leaveType'] ?? 'No Document',
                            style: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => Divider(),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).move(
                begin: const Offset(-16, 0),
                curve: Curves.easeOutQuad,
              );
        } else {
          return Center(
            child: Text(
              "ຍັງບໍ່ທັນມີຂໍ້ມູນ.",
              style: GoogleFonts.notoSansLao(
                textStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
