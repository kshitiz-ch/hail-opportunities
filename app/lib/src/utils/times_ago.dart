import 'package:intl/src/intl/date_format.dart';

String timeAgo(DateTime d) {
  Duration diff = DateTime.now().difference(d);
  if (diff.inDays > 365)
    return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
  if (diff.inDays > 30)
    return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
  if (diff.inDays > 7)
    return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
  if (diff.inDays > 0)
    return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
  if (diff.inHours > 0)
    return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
  if (diff.inMinutes > 0)
    return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
  return "just now";
}

String notificationDateFormat(DateTime d) {
  Duration diff = DateTime.now().difference(d);
  if (diff.inDays > 30) return DateFormat('dd MMM yyyy').format(d);
  if (diff.inDays > 0) return "${diff.inDays}d ago";
  if (diff.inHours > 0) return "${diff.inHours}h ago";
  if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
  return "just now";
}

String? expiryDateFormat(DateTime? d) {
  if (d == null) return null;
  Duration diff = (d).difference(DateTime.now());

  if (diff.inDays > 30) return null;

  if (diff.inDays > 0) return "${diff.inDays} day(s)";
  if (diff.inHours > 0) return "${diff.inHours} hour(s)";
  if (diff.inMinutes > 0) return "${diff.inMinutes} minute(s)";
  return null;
}
