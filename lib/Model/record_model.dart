class RecordModel {
  String? date;
  bool? fall;

  RecordModel({this.date, this.fall});

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      date: json['date'],
      fall: json['fall'] is bool ? json['fall'] : json['fall'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'fall': fall,
    };
  }
}
