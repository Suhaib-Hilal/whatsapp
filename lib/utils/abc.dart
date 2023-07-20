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
  await launchUrl(Uri.parse('sms:$phoneNumber?body=$message'));
}
