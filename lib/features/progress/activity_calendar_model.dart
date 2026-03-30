class ActivityCalendarModel {
  final int month;
  final int year;
  final List<DateTime> days;

  ActivityCalendarModel({
    required this.month,
    required this.year,
    required this.days,
  });

  factory ActivityCalendarModel.fromJson(Map<String, dynamic> json) {
    return ActivityCalendarModel(
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      days: (json['days'] as List? ?? [])
          .map((e) => DateTime.parse(e))
          .toList(),
    );
  }
}
