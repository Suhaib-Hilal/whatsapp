import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

import '../../../theme/color_theme.dart';

class CountryPicker extends StatefulWidget {
  final void Function(Country country) callback;
  final Country selectedCountry;

  const CountryPicker(
      {super.key, required this.selectedCountry, required this.callback});

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  List<Country> countries = CountryService().getAll();
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorsDark.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColorsDark.appBarColor,
          title: !isSearching
              ? const Text("Pick a country")
              : TextField(
                  autofocus: true,
                  onChanged: (value) {
                    countries = CountryService().getAll();
                    countries.removeWhere((c) => !(c.name
                        .toLowerCase()
                        .startsWith(value.toLowerCase())));
                    setState(() {});
                  },
                  style: const TextStyle(
                    color: AppColorsDark.textColor1,
                  ),
                  cursorColor: AppColorsDark.greenColor,
                  decoration: const InputDecoration(
                    hintText: "Search for a country",
                    hintStyle: TextStyle(
                      color: AppColorsDark.textColor1,
                    ),
                    border: InputBorder.none,
                  ),
                ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() => isSearching = true);
              },
            ),
          ],
        ),
        body: ListView.separated(
          itemCount: countries.length,
          itemBuilder: (context, index) {
            if (!isSearching) {
              countries
                  .removeWhere((c) => c.name == widget.selectedCountry.name);
              countries.insert(0, widget.selectedCountry);
            }
            return ListTile(
              leading: Text(
                countries[index].flagEmoji,
                style: const TextStyle(
                  fontSize: 26,
                ),
              ),
              title: Text(
                countries[index].name,
                style: const TextStyle(color: AppColorsDark.textColor1),
              ),
              subtitle: Text(
                countries[index].displayName,
                style: const TextStyle(
                  color: AppColorsDark.textColor2,
                ),
              ),
              trailing: SizedBox(
                width: 60,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "+${countries[index].phoneCode}",
                      style: const TextStyle(color: AppColorsDark.textColor1),
                    ),
                    index == countries.indexOf(widget.selectedCountry)
                        ? const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.check,
                              color: AppColorsDark.greenColor,
                            ),
                          )
                        : const SizedBox(width: 30),
                  ],
                ),
              ),
              onTap: () {
                setState(() {});
                widget.callback(countries[index]);
                Navigator.of(context).pop();
              },
            );
          },
          separatorBuilder: ((context, index) {
            return const Divider(
              height: 1,
              thickness: 1,
              color: AppColorsDark.dividerColor,
              indent: 15,
              endIndent: 15,
            );
          }),
        ));
  }
}
