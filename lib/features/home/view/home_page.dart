import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsappclone/shared/firestore_db.dart';
import 'package:whatsappclone/shared/user.dart';
import 'package:whatsappclone/theme/color_theme.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:whatsappclone/utils/abc.dart';

import '../../chat/view/chat_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) return;
      setState(() {});
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await FirestoreDatabase.updateUserStatus(widget.user.id, "Online");
    } else {
      await FirestoreDatabase.updateUserStatus(widget.user.id, "Offline");
    }
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
              Stack(
                children: [
                  StreamBuilder(
                    stream: FirestoreDatabase.getRecentChats(widget.user),
                    builder: ((context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();

                      final recents = snapshot.data!;
                      return ListView.builder(
                        itemCount: recents.length,
                        itemBuilder: (context, index) {
                          final recent = recents[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ChatPage(
                                            fromUser: widget.user,
                                            toUser: recent.author,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: AppColorsDark.dividerColor,
                                    foregroundImage:
                                        recent.author.avatarUrl.isNotEmpty
                                            ? NetworkImage(
                                                recent.author.avatarUrl,
                                              )
                                            : null,
                                    child: recent.author.avatarUrl.isEmpty
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Text(
                                    recent.author.name,
                                    style: const TextStyle(
                                      color: AppColorsDark.textColor1,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    recent.lastMsg.content.length > 30
                                        ? "${recent.lastMsg.content.substring(0, 30)}..."
                                        : recent.lastMsg.content,
                                    style: const TextStyle(
                                      color: AppColorsDark.greyColor,
                                    ),
                                  ),
                                  trailing: Text(
                                    formattedTimestamp(
                                      recent.lastMsg.timestamp,
                                    ),
                                    style: const TextStyle(
                                      color: AppColorsDark.greyColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                recent == recents.last
                                    ? Column(
                                        children: [
                                          const Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: AppColorsDark.dividerColor,
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.lock_rounded,
                                                color: AppColorsDark.iconColor,
                                                size: 12,
                                              ),
                                              const SizedBox(width: 4),
                                              RichText(
                                                text: const TextSpan(
                                                  text:
                                                      "Your personal messages are ",
                                                  style: TextStyle(
                                                    color:
                                                        AppColorsDark.iconColor,
                                                    fontSize: 12,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text:
                                                          "end-to-end encrypted",
                                                      style: TextStyle(
                                                        color: AppColorsDark
                                                            .greenColor,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
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
                              builder: (context) =>
                                  ContactsPage(user: widget.user),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.message,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
                            foregroundColor: Colors.white,
                            backgroundColor: AppColorsDark.appBarColor,
                            child: const Icon(Icons.edit),
                          ),
                        ),
                        FloatingActionButton(
                          foregroundColor: Colors.white,
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
                    foregroundColor: Colors.white,
                    backgroundColor: AppColorsDark.greenColor,
                    elevation: 0,
                    onPressed: () {},
                    child: const Icon(
                      Icons.add_ic_call_rounded,
                      color: Colors.white,
                    ),
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
  final contactSearchingController = TextEditingController(text: "");
  final shareMsg =
      "Let's chat on WhatsApp! It's a fast, simple and secure app we can use to message and call each other for free. Get it at https://github.com/Suhaib-Hilal/whatsapp.git";
  final contactsHelpUrl =
      "https://faq.whatsapp.com/cxt?entrypointid=missingcontacts&lg=en&lc=US&platform=android&anid=a223fcbb-4143-4961-bdb4-018ea1aac96c";

  @override
  Widget build(BuildContext context) {
    final topOptions = Column(
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
    final searchingTextField = TextField(
      onChanged: (value) => setState(() {}),
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
            !isSearching ? const Text("Select contact") : searchingTextField,
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
            contactSearchingController.text == ""
                ? topOptions
                : const SizedBox(height: 12),
            FutureBuilder(
              future: contactsFuture,
              builder: (context, snapshot) {
                List<User> contactsOnWhatsapp = [];
                List<Contact> contactsNotOnWhatsapp = [];
                List<Widget> abc = [];
                final searching = contactSearchingController.text != "";
                final searchTextLength = contactSearchingController.text.length;
                final searchText = contactSearchingController.text;

                if (snapshot.hasData) {
                  (contactsOnWhatsapp, contactsNotOnWhatsapp) = snapshot.data!;
                  final whatsappContacts = contactsOnWhatsapp.where((contact) {
                    return contact.name
                        .toLowerCase()
                        .startsWith(searchText.toLowerCase());
                  });
                  final contacts = contactsNotOnWhatsapp.where(
                    (contact) {
                      return contact.displayName
                          .toLowerCase()
                          .startsWith(searchText.toLowerCase());
                    },
                  );
                  if (whatsappContacts.isEmpty && contacts.isEmpty) {
                    var text = "";
                    if (searchTextLength >= 20) {
                      text = "${searchText.substring(0, 20)}...";
                    } else {
                      text = searchText;
                    }
                    abc.add(
                      Text(
                        "No results found for '$text'",
                        style: const TextStyle(
                          color: AppColorsDark.greyColor,
                        ),
                      ),
                    );
                  }
                }

                if (contactsOnWhatsapp.isNotEmpty) {
                  final whatsappContacts = contactsOnWhatsapp.where((contact) {
                    return contact.name
                        .toLowerCase()
                        .startsWith(searchText.toLowerCase());
                  });

                  if (!searching && whatsappContacts.isNotEmpty ||
                      searching && whatsappContacts.isNotEmpty) {
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
                  for (final contact in whatsappContacts) {
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
                                  !searching
                                      ? Text(
                                          contact.name,
                                          style: const TextStyle(
                                            color: AppColorsDark.textColor1,
                                            fontSize: 16,
                                          ),
                                        )
                                      : RichText(
                                          text: TextSpan(
                                            text: "",
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: contact.name.substring(
                                                    0, searchTextLength),
                                                style: const TextStyle(
                                                  color:
                                                      AppColorsDark.blueColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              TextSpan(
                                                text: contact.name.substring(
                                                  searchTextLength,
                                                  contact.name.length,
                                                ),
                                              ),
                                            ],
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
                  final contacts = contactsNotOnWhatsapp.where(
                    (contact) {
                      return contact.displayName.toLowerCase().startsWith(
                            contactSearchingController.text.toLowerCase(),
                          );
                    },
                  );
                  if (!searching && contacts.isNotEmpty ||
                      searching && contacts.isNotEmpty) {
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
                  for (final contact in contacts) {
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
                                !searching
                                    ? Text(
                                        contact.displayName,
                                        style: const TextStyle(
                                          color: AppColorsDark.textColor1,
                                          fontSize: 16,
                                        ),
                                      )
                                    : RichText(
                                        text: TextSpan(
                                          text: "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:
                                                  contact.displayName.substring(
                                                0,
                                                searchTextLength,
                                              ),
                                              style: const TextStyle(
                                                color: AppColorsDark.blueColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  contact.displayName.substring(
                                                searchTextLength,
                                                contact.displayName.length,
                                              ),
                                            ),
                                          ],
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
            if (contactSearchingController.text != "")
              Column(
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
            else
              const SizedBox(),
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
                onTap: () => launchUrl(Uri.parse(contactsHelpUrl)),
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
  List<Contact> contacts = await FlutterContacts.getContacts(
    withProperties: true,
  );
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
