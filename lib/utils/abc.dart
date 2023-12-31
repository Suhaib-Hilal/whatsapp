import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

String formattedTimestamp(Timestamp timestamp, {bool onlyTime = false}) {
  final date = timestamp.toDate();
  final now = DateTime.now();

  if (!onlyTime) {
    if (now.year > date.year ||
        now.month > date.month ||
        now.day - date.day > 1) {
      return "${date.day}/${date.month}/${date.year}";
    }

    if (now.day - date.day == 1) {
      return "Yesterday";
    }
  }
  if (date.hour > 9 && date.minute > 9) {
    return "${date.hour}:${date.minute}";
  } else if (date.hour > 9 && date.minute < 9) {
    return "${date.hour}:0${date.minute}";
  } else if (date.hour < 9 && date.minute > 9) {
    return "0${date.hour}:${date.minute}";
  }
  return "0${date.hour}:0${date.minute}";
}

Future<bool> checkInternetConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

Future<String> getUserStatus() async {
  bool isOnline = await checkInternetConnectivity();
  if (isOnline) {
    return "Online";
  } else {
    return "Offline";
  }
}

void sendMessage(String phoneNumber, String message) async {
  await launchUrl(Uri.parse('sms:$phoneNumber?body=$message'));
}

Future<(double, double)> getImageDimensions(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final image = await decodeImageFromList(bytes);
  image.dispose();

  return (image.width.toDouble(), image.height.toDouble());
}

Future<XFile?> getSelectedImage(String text) async {
  if (text == "Camera") {
    return ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);
  }
  return ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
}

String getFormattedSize(int sizeInBytes) {
  final kilobytes = (sizeInBytes / 1024);
  if (kilobytes >= 500) {
    return "${(kilobytes / 1024).toStringAsFixed(2)} MB";
  } else {
    return "${kilobytes.toStringAsFixed(2)} KB";
  }
}
