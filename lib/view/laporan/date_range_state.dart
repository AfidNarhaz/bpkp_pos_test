class GlobalDateRange {
  static DateTime startDate =
      DateTime.now().subtract(const Duration(days: 6)); // default 1 minggu
  static DateTime endDate = DateTime.now();

  static void setRange(DateTime start, DateTime end) {
    startDate = DateTime(start.year, start.month, start.day);
    endDate = DateTime(end.year, end.month, end.day);
  }
}
