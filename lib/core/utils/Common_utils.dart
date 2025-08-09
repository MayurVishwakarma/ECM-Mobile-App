
import 'package:intl/intl.dart';


getshortdate(String date) {
  try {
    if (date.isNotEmpty) {
      final DateTime now = DateTime.parse(date);
      final DateFormat formatter = DateFormat('d-MMM-y H:m:s');
      final String formatted =
          formatter.format(now.add(Duration(hours: 5, minutes: 30)));
      return formatted;
    } else {
      return '';
    }
  } catch (_) {}
}


