class PhoneNumber {
  PhoneNumber({
    required this.phoneNumberWithFormating,
    required this.phoneNumberWithoutFormating,
  });

  String phoneNumberWithFormating;
  String phoneNumberWithoutFormating;

  Map<String, dynamic> toMap() {
    return {
      "phoneNumberWithFormating": phoneNumberWithFormating,
      "phoneNumberWithoutFormating": phoneNumberWithoutFormating,
    };
  }

  static PhoneNumber fromMap(phoneData) {
    return PhoneNumber(
      phoneNumberWithFormating: phoneData["phoneNumberWithFormating"],
      phoneNumberWithoutFormating: phoneData["phoneNumberWithoutFormating"],
    );
  }
}
