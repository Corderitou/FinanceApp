class WorkLocationFrequency {
  final String locationName;
  final int frequency;
  final DateTime firstVisit;
  final DateTime lastVisit;

  WorkLocationFrequency({
    required this.locationName,
    required this.frequency,
    required this.firstVisit,
    required this.lastVisit,
  });
}

class WorkLocationReportData {
  final List<WorkLocationFrequency> locations;
  final DateTime startDate;
  final DateTime endDate;
  final int totalVisits;

  WorkLocationReportData({
    required this.locations,
    required this.startDate,
    required this.endDate,
    required this.totalVisits,
  });
}