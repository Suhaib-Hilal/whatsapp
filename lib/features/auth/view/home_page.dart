import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsappclone/shared/firestore_db.dart';
import 'package:whatsappclone/shared/user.dart';
import 'package:whatsappclone/theme/color_theme.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:whatsappclone/utils/abc.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        backgroundColor: AppColorsDark.appBarColor,
        elevation: 0,
        title: const Text(
          "WhatsApp",
          style: TextStyle(color: AppColorsDark.greyColor),
        ),
        actions: const [
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: AppColorsDark.iconColor,
                ),
                Icon(
                  Icons.search_rounded,
                  color: AppColorsDark.iconColor,
                ),
                Icon(
                  Icons.more_vert,
                  color: AppColorsDark.iconColor,
                ),
              ],
            ),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppColorsDark.backgroundColor,
          appBar: AppBar(
            elevation: 2,
            backgroundColor: AppColorsDark.appBarColor,
            toolbarHeight: 10,
            bottom: const TabBar(
              indicatorColor: AppColorsDark.greenColor,
              indicatorWeight: 2.5,
              unselectedLabelColor: AppColorsDark.greyColor,
              labelColor: AppColorsDark.greenColor,
              tabs: [
                Tab(text: "Chats"),
                Tab(text: "Status"),
                Tab(text: "Calls"),
              ],
            ),
          ),
          body: TabBarView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: FloatingActionButton(
                    backgroundColor: AppColorsDark.greenColor,
                    elevation: 0,
                    onPressed: () async {
                      if (!await FlutterContacts.requestPermission()) {
                        return;
                      }
                      if (!mounted) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ContactsPage(user: widget.user),
                        ),
                      );
                    },
                    child: const Icon(Icons.message),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 136,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 44,
                          child: FloatingActionButton(
                            onPressed: () {},
                            backgroundColor: AppColorsDark.appBarColor,
                            child: const Icon(Icons.edit),
                          ),
                        ),
                        FloatingActionButton(
                          backgroundColor: AppColorsDark.greenColor,
                          elevation: 0,
                          onPressed: () {},
                          child: const Icon(Icons.camera_alt_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: FloatingActionButton(
                    backgroundColor: AppColorsDark.greenColor,
                    elevation: 0,
                    onPressed: () {},
                    child: const Icon(Icons.add_ic_call_rounded),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactsPage extends StatefulWidget {
  final User user;
  const ContactsPage({super.key, required this.user});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  bool isSearching = false;
  Future<(List<User>, List<Contact>)> contactsFuture = getContactsInfo();
  TextEditingController contactSearchingController =
      TextEditingController(text: "");
  final shareMsg =
      "Let's chat on WhatsApp! It's a fast, simple and secure app we can use to message and call each other for free. Get it at https://github.com/Suhaib-Hilal/whatsapp.git";
  final contactsHelpUrl =
      "https://faq.whatsapp.com/cxt?entrypointid=missingcontacts&lg=en&lc=US&platform=android&anid=a223fcbb-4143-4961-bdb4-018ea1aac96c";

  @override
  Widget build(BuildContext context) {
    var topOptions = Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColorsDark.greenColor,
            ),
            child: const Icon(
              Icons.group,
              color: AppColorsDark.textColor1,
            ),
          ),
          title: const Text(
            "New Group",
            style: TextStyle(
              color: AppColorsDark.textColor1,
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColorsDark.greenColor,
            ),
            child: const Icon(
              Icons.person_add,
              color: AppColorsDark.textColor1,
            ),
          ),
          title: const Text(
            "New Contact",
            style: TextStyle(
              color: AppColorsDark.textColor1,
            ),
          ),
          trailing: const Padding(
            padding: EdgeInsets.only(right: 10, top: 4),
            child: Icon(
              Icons.qr_code_rounded,
              color: AppColorsDark.iconColor,
              size: 28,
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColorsDark.greenColor,
            ),
            child: const Icon(
              Icons.group,
              color: AppColorsDark.textColor1,
            ),
          ),
          title: const Text(
            "New Community",
            style: TextStyle(
              color: AppColorsDark.textColor1,
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
    return Scaffold(
      backgroundColor: AppColorsDark.backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColorsDark.appBarColor,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColorsDark.backgroundColor,
        ),
        backgroundColor: AppColorsDark.appBarColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            !isSearching
                ? const Text("Select contact")
                : TextField(
                    textAlignVertical: TextAlignVertical.bottom,
                    style: const TextStyle(
                      color: AppColorsDark.textColor1,
                      fontSize: 18,
                    ),
                    controller: contactSearchingController,
                    cursorColor: AppColorsDark.greenColor,
                    decoration: const InputDecoration(
                      hintText: "Search...",
                      hintStyle: TextStyle(
                        color: AppColorsDark.greyColor,
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
            FutureBuilder(
              future: contactsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || isSearching) {
                  return const SizedBox(height: 8);
                }

                final (contactsOnWhatsapp, _) = snapshot.data!;

                return Text(
                  "${contactsOnWhatsapp.length} contacts",
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FutureBuilder(
                  future: contactsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColorsDark.greenColor,
                        ),
                      );
                    }
                    return const SizedBox(width: 20);
                  },
                ),
                GestureDetector(
                  child: !isSearching
                      ? const Icon(Icons.search_rounded)
                      : const SizedBox(),
                  onTap: () {
                    setState(() => isSearching = true);
                  },
                ),
                if (!isSearching)
                  PopupMenuButton(
                    color: AppColorsDark.appBarColor,
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppColorsDark.textColor1,
                    ),
                    onSelected: (value) async {
                      switch (value) {
                        case 0:
                          Share.share(shareMsg);
                          break;
                        case 1:
                          FlutterContacts.openExternalPick();
                          break;
                        case 2:
                          setState(() {
                            contactsFuture = getContactsInfo();
                          });
                          break;
                        case 3:
                          launchUrl(Uri.parse(contactsHelpUrl));
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      final textStyle =
                          Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              );
                      return [
                        PopupMenuItem<int>(
                          value: 0,
                          height: 40,
                          child: Text(
                            "Invite a friend",
                            style: textStyle,
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 1,
                          height: 40,
                          child: Text(
                            "Contacts",
                            style: textStyle,
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 2,
                          height: 40,
                          child: Text(
                            "Refresh",
                            style: textStyle,
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 3,
                          height: 40,
                          child: Text(
                            "Help",
                            style: textStyle,
                          ),
                        ),
                      ];
                    },
                  )
                else
                  const SizedBox(),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            if (contactSearchingController.text == "")
              topOptions
            else
              const SizedBox(
                height: 12,
              ),
            FutureBuilder(
              future: contactsFuture,
              builder: (context, snapshot) {
                List<User> contactsOnWhatsapp = [];
                List<Contact> contactsNotOnWhatsapp = [];
                List<Widget> abc = [];

                if (snapshot.hasData) {
                  (contactsOnWhatsapp, contactsNotOnWhatsapp) = snapshot.data!;
                }

                if (contactsOnWhatsapp.isNotEmpty) {
                  if (contactSearchingController.text == "" &&
                          contactsOnWhatsapp.where((contact) {
                            return contact.name.toLowerCase().startsWith(
                                  contactSearchingController.text.toLowerCase(),
                                );
                          }).isNotEmpty ||
                      contactSearchingController.text != "" &&
                          contactsOnWhatsapp.where((contact) {
                            return contact.name.toLowerCase().startsWith(
                                  contactSearchingController.text.toLowerCase(),
                                );
                          }).isNotEmpty) {
                    abc.add(
                      const Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            "Contacts on whatsapp",
                            style: TextStyle(color: AppColorsDark.greyColor),
                          ),
                        ],
                      ),
                    );
                  }
                  if (contactSearchingController.text != "") {
                    contactsOnWhatsapp.where(
                      (contact) => contact.name.toLowerCase().startsWith(
                            contactSearchingController.text.toLowerCase(),
                          ),
                    );
                  }
                  for (final contact in contactsOnWhatsapp.where((contact) {
                    return contact.name.toLowerCase().startsWith(
                          contactSearchingController.text.toLowerCase(),
                        );
                  })) {
                    abc.add(
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                fromUser: widget.user,
                                toUser: contact,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColorsDark.dividerColor,
                                foregroundImage: contact.avatarUrl.isNotEmpty
                                    ? NetworkImage(contact.avatarUrl)
                                    : null,
                                child: contact.avatarUrl.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.name,
                                    style: const TextStyle(
                                      color: AppColorsDark.textColor1,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Text(
                                    "Hey there, I am using whatsapp.",
                                    style: TextStyle(
                                      color: AppColorsDark.greyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }
                if (contactsNotOnWhatsapp.isNotEmpty) {
                  if (contactSearchingController.text == "" &&
                          contactsNotOnWhatsapp
                              .where(
                                (contact) => contact.displayName
                                    .toLowerCase()
                                    .startsWith(
                                      contactSearchingController.text
                                          .toLowerCase(),
                                    ),
                              )
                              .isNotEmpty ||
                      contactSearchingController.text != "" &&
                          contactsNotOnWhatsapp.where((contact) {
                            return contact.displayName.toLowerCase().startsWith(
                                  contactSearchingController.text.toLowerCase(),
                                );
                          }).isNotEmpty) {
                    abc.add(
                      const Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            "Invite to whatsapp",
                            style: TextStyle(color: AppColorsDark.greyColor),
                          ),
                        ],
                      ),
                    );
                  }
                  if (contactSearchingController.text != "") {
                    contactsNotOnWhatsapp.where(
                      (contact) => contact.displayName.startsWith(
                        contactSearchingController.text,
                      ),
                    );
                  }
                  for (final contact in contactsNotOnWhatsapp.where((contact) {
                    return contact.displayName.toLowerCase().startsWith(
                          contactSearchingController.text.toLowerCase(),
                        );
                  })) {
                    abc.add(
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          right: 10,
                          left: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColorsDark.iconColor,
                                  foregroundImage: contact.photo != null
                                      ? MemoryImage(contact.photo!)
                                      : null,
                                  child: contact.photo == null
                                      ? const Icon(
                                          Icons.person,
                                          color: AppColorsDark.textColor1,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  contact.displayName,
                                  style: const TextStyle(
                                    color: AppColorsDark.textColor1,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                sendMessage(
                                  contact.phones[0].normalizedNumber,
                                  shareMsg,
                                );
                              },
                              child: const Text(
                                "Invite",
                                style: TextStyle(
                                  color: AppColorsDark.greenColor,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                }
                return Column(
                  children: abc,
                );
              },
            ),
            contactSearchingController.text != ""
                ? Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            Text(
                              "More",
                              style: TextStyle(color: AppColorsDark.greyColor),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                          right: 10,
                          left: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: AppColorsDark.appBarColor,
                              ),
                              child: const Icon(
                                Icons.person_add,
                                color: AppColorsDark.iconColor,
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              "New contact",
                              style: TextStyle(
                                color: AppColorsDark.textColor1,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                right: 10,
                left: 16,
              ),
              child: GestureDetector(
                onTap: () {
                  Share.share(shareMsg);
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppColorsDark.appBarColor,
                      ),
                      child: const Icon(
                        Icons.share,
                        color: AppColorsDark.iconColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      "Share invite link",
                      style: TextStyle(
                        color: AppColorsDark.textColor1,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
                left: 16,
              ),
              child: GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse(contactsHelpUrl));
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppColorsDark.appBarColor,
                      ),
                      child: const Icon(
                        Icons.question_mark_rounded,
                        color: AppColorsDark.iconColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      "Contacts help",
                      style: TextStyle(
                        color: AppColorsDark.textColor1,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<(List<User>, List<Contact>)> getContactsInfo() async {
  List<Contact> contacts =
      await FlutterContacts.getContacts(withProperties: true);
  List<User> contactsOnWhatsapp = [];
  List<Contact> contactsNotOnWhatsapp = [];

  for (var contact in contacts) {
    for (var phone in contact.phones) {
      User? user = await FirestoreDatabase.getUserByPhoneNumber(
        phone.normalizedNumber,
      );
      if (user != null) {
        contactsOnWhatsapp.add(user);
      } else {
        contactsNotOnWhatsapp.add(contact);
      }
    }
  }
  return (contactsOnWhatsapp, contactsNotOnWhatsapp);
}
