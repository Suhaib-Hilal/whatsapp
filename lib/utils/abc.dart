import 'package:url_launcher/url_launcher.dart';

String formattedTime(int time) {
  int hours = 0;
  int minutes = time ~/ 60;
  int seconds = time % 60;

  if (minutes > 60) {
    hours = minutes ~/ 60;
    minutes = minutes % 60;
  }

  String hoursStr = hours < 10 ? "0$hours" : "$hours";
  String minuteStr = minutes < 10 ? "0$minutes" : "$minutes";
  String secondsStr = seconds < 10 ? "0$seconds" : "$seconds";

  return ([hoursStr, minuteStr, secondsStr]..removeWhere((str) => str == "00"))
      .join(":");
}

void sendMessage(String phoneNumber, String message) async {
  final url = 'sms:$phoneNumber?body=${Uri.encodeComponent(message)}';

  if (await canLaunchUrl(Uri(path: url))) {
    await launchUrl(Uri(path: url));
  } else {
    throw 'Could not launch $url';
  }
}
