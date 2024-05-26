class Validators {
  static bool dayIsToday(DateTime? dateTime) {
    if (dateTime == null) {
      return false;
    }
    var now = DateTime.now();
    if (dateTime.year != now.year) return false;
    if (dateTime.month != now.month) return false;
    if (dateTime.day != now.day) return false;
    return true;
  }
}
