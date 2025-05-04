class LeaveModel {
  final String user;
  final String name;
  final String date;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final String daySummary;
  final String imageUrl;
  final String documentUrl;
  final String doc;
  final String status;

  LeaveModel({
    required this.user,
    required this.name,
    required this.date,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.daySummary,
    required this.imageUrl,
    required this.documentUrl,
    required this.doc,
    required this.status,
  });

  // Define the fromJson method
  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      user: json['user'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
      leaveType: json['leaveType'] as String,
      fromDate: json['fromDate'] as String,
      toDate: json['toDate'] as String,
      daySummary: json['daySummary'] as String,
      imageUrl: json['imageUrl'] as String,
      documentUrl: json['documentUrl'] as String,
      doc: json['doc'] as String,
      status: json['status'] as String,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'name': name,
      'date': date,
      'leaveType': leaveType,
      'fromDate': fromDate,
      'toDate': toDate,
      'daySummary': daySummary,
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'doc': doc,
      'status': status,
    };
  }
}
