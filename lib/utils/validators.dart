class Validators {
  static bool dayIsToday(DateTime dateTime) {
    var now = DateTime.now();
    if (dateTime.year != now.year) return false;
    if (dateTime.month != now.month) return false;
    if (dateTime.day != now.day) return false;
    return true;
  }
}
