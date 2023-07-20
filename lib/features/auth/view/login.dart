import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/color_theme.dart';
import '../model/phone_number.dart';
import 'package:country_picker/country_picker.dart';
import 'package:phone_number/phone_number.dart' as phone;

import 'country_picker.dart';
import 'verification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final textFieldWidth = 250;
  Country selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India (IN) [+91]',
    fullExampleWithPlusSign: '+919123456789',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
  );
  late final TextEditingController countryFieldController;
  late final TextEditingController countryPhoneCodeController;
  late final TextEditingController phoneNumberController;

  @override
  void initState() {
    countryFieldController =
        TextEditingController(text: selectedCountry.displayNameNoCountryCode);
    countryPhoneCodeController =
        TextEditingController(text: selectedCountry.phoneCode);
    phoneNumberController = TextEditingController(text: "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsDark.backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColorsDark.appBarColor,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColorsDark.backgroundColor,
        ),
        title: const Center(child: Text("Enter your phone number")),
        backgroundColor: AppColorsDark.appBarColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'WhatsApp will need to verify your phone number. ',
                  children: <TextSpan>[
                    TextSpan(
                      text: "What's my number?",
                      style: TextStyle(
                        color: AppColorsDark.blueColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: textFieldWidth.toDouble(),
                child: TextField(
                  readOnly: true,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.bottom,
                  controller: countryFieldController,
                  style: const TextStyle(
                    color: AppColorsDark.textColor1,
                  ),
                  cursorColor: AppColorsDark.greenColor,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CountryPicker(
                              selectedCountry: selectedCountry,
                              callback: (Country selected) async {
                                selectedCountry = selected;
                                countryFieldController.text =
                                    selected.displayNameNoCountryCode;
                                countryPhoneCodeController.text =
                                    selected.phoneCode;
                                await formatPhoneNumber(selected);
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    suffixIconColor: AppColorsDark.greenColor,
                    suffixIconConstraints: const BoxConstraints(minWidth: 10),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColorsDark.greenColor,
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 6, 83, 66),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 25 / 100 * textFieldWidth.toDouble(),
                    child: TextField(
                      onChanged: (value) async {
                        final countries = CountryService().getAll();
                        for (var country in countries) {
                          if (value == country.phoneCode) {
                            selectedCountry = country;
                            countryFieldController.text =
                                country.displayNameNoCountryCode;
                            await formatPhoneNumber(country);
                            return;
                          }
                        }
                        selectedCountry = Country(
                          phoneCode: "",
                          countryCode: "",
                          e164Sc: -1,
                          geographic: false,
                          level: -1,
                          name: "Invalid Country",
                          example: "",
                          displayName: "Invalid Country",
                          displayNameNoCountryCode: "Invalid Country",
                          e164Key: "",
                        );
                        countryFieldController.text = "Invalid Country";
                        setState(() {});
                      },
                      textAlign: TextAlign.center,
                      controller: countryPhoneCodeController,
                      keyboardType: const TextInputType.numberWithOptions(),
                      cursorColor: AppColorsDark.greenColor,
                      style: const TextStyle(color: AppColorsDark.textColor1),
                      decoration: const InputDecoration(
                        prefixText: "+",
                        prefixStyle: TextStyle(color: AppColorsDark.textColor2),
                        hintStyle: TextStyle(color: AppColorsDark.textColor1),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColorsDark.greenColor,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 6, 83, 66),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 75 / 100 * textFieldWidth.toDouble() - 10,
                    child: TextField(
                      onChanged: (value) async {
                        await formatPhoneNumber(selectedCountry);
                        phoneNumberController.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: phoneNumberController.text.length));
                        setState(() {});
                      },
                      textAlign: TextAlign.left,
                      controller: phoneNumberController,
                      cursorColor: AppColorsDark.greenColor,
                      style: const TextStyle(color: AppColorsDark.textColor1),
                      keyboardType: const TextInputType.numberWithOptions(),
                      decoration: const InputDecoration(
                        hintText: "Phone number",
                        hintStyle: TextStyle(color: AppColorsDark.textColor2),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColorsDark.greenColor,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 6, 83, 66),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Carrier charges may apply",
                style: TextStyle(color: AppColorsDark.greyColor),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: SizedBox(
              width: 150,
              child: ElevatedButton(
                  onPressed: () async {
                    final isValid = await phone.PhoneNumberUtil().validate(
                      phoneNumberController.text,
                      regionCode: selectedCountry.countryCode,
                    );

                    if (!mounted) return;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        final infoContainer = Container(
                          width: 340,
                          height: 175,
                          decoration: const BoxDecoration(
                            color: AppColorsDark.backgroundColor,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "You entered the phone number:",
                                  style: TextStyle(
                                      color: AppColorsDark.greyColor,
                                      fontSize: 16,
                                      decoration: TextDecoration.none,
                                      fontFamily:
                                          String.fromEnvironment("Consolas")),
                                ),
                                Text(
                                  "+${countryPhoneCodeController.text} ${phoneNumberController.text}",
                                  style: const TextStyle(
                                      color: AppColorsDark.greyColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                      fontFamily:
                                          String.fromEnvironment("Consolas")),
                                ),
                                const Text(
                                  "Is this OK, or would you like to edit the number?",
                                  style: TextStyle(
                                    color: AppColorsDark.greyColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                    fontFamily:
                                        String.fromEnvironment("Consolas"),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // fieldFocusNode.requestFocus();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        "Edit",
                                        style: TextStyle(
                                          color: AppColorsDark.greenColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                          fontFamily: String.fromEnvironment(
                                            "Consolas",
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        String phoneNumberWithFormating =
                                            "+${countryPhoneCodeController.text}${phoneNumberController.text}";
                                        String phoneNumber =
                                            phoneNumberController.text
                                                .replaceAll("-", "")
                                                .replaceAll(" ", "")
                                                .replaceAll("(", "")
                                                .replaceAll(")", "");
                                        phoneNumber =
                                            "+${countryPhoneCodeController.text} $phoneNumber";

                                        if (!mounted) return;
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      VerificationPage(
                                                    phoneNumber: PhoneNumber(
                                                      phoneNumberWithFormating:
                                                          phoneNumberWithFormating,
                                                      phoneNumberWithoutFormating:
                                                          phoneNumber,
                                                    ),
                                                  ),
                                                ),
                                                (route) => false);
                                      },
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(
                                          color: AppColorsDark.greenColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                          fontFamily: String.fromEnvironment(
                                            "Consolas",
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                        final errorContainer = Container(
                          width: 340,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: AppColorsDark.backgroundColor,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "The phone number you entered is not valid!",
                                style: TextStyle(
                                  color: AppColorsDark.greyColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                  fontFamily:
                                      String.fromEnvironment("Consolas"),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "OK",
                                  style: TextStyle(
                                    color: AppColorsDark.greenColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        return Center(
                          child: isValid ? infoContainer : errorContainer,
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(AppColorsDark.greenColor),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  child: const Text("NEXT")),
            ),
          )
        ],
      ),
    );
  }

  Future<void> formatPhoneNumber(Country country) async {
    final phoneNumber = phoneNumberController.text
        .replaceAll("-", "")
        .replaceAll(" ", "")
        .replaceAll("(", "")
        .replaceAll(")", "");

    final formatted = await phone.PhoneNumberUtil().format(
      phoneNumber,
      country.countryCode,
    );
    phoneNumberController.text = formatted;
    setState(() {});
  }
}
