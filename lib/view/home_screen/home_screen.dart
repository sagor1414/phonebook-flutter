// ignore_for_file: avoid_print

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phonebook/view/details%20page/contact_details.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../widget/shimmer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getContactPermission();
  }

  // Get user permission
  void getContactPermission() async {
    if (await Permission.contacts.isGranted) {
      fetchContacts();
    } else {
      await Permission.contacts.request();
    }
  }

  // Fetch all contacts
  void fetchContacts() async {
    try {
      List<Contact> contactList =
          (await ContactsService.getContacts()).toList();

      setState(() {
        contacts = contactList;
        filteredContacts = contactList; // Initialize filteredContacts
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching contacts: $e");
    }
  }

  // Update contact
  void updateContact(Contact updatedContact) {
    int index = contacts.indexWhere(
        (contact) => contact.identifier == updatedContact.identifier);
    if (index != -1) {
      setState(() {
        contacts[index] = updatedContact;
      });
    }
  }

  // Navigate to details page
  void navigateToContactDetails(Contact contact) {
    int index = contacts.indexWhere((c) => c.identifier == contact.identifier);
    if (index != -1) {
      final updatedContact = contacts[index];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactDetails(
            contact: updatedContact,
            onContactUpdate: updateContact,
            onContactDelete: (updatedContact) {
              updateContact(updatedContact);
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
  }

  // Filter contacts based on the search query
  void filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredContacts = contacts;
      } else {
        filteredContacts = contacts
            .where((contact) =>
                contact.givenName
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ??
                false)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            Contact contact = await ContactsService.openContactForm();
            // ignore: unnecessary_null_comparison
            if (contact != null) {
              fetchContacts();
            }
          } on FormOperationException catch (e) {
            switch (e.errorCode) {
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
                print(e.toString());
                break;
              default:
            }
          }
        },
        backgroundColor: Theme.of(context).primaryColorLight,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          Flexible(
            child: TextField(
              onChanged: filterContacts,
              decoration: const InputDecoration(
                hintText: "Search Contacts",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: getShimmerLoading(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Container(
                          width: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: CircleAvatar(
                            backgroundImage: () {
                              if (filteredContacts[index].avatar != null &&
                                  filteredContacts[index].avatar!.isNotEmpty) {
                                try {
                                  return Image.memory(
                                          filteredContacts[index].avatar!,
                                          fit: BoxFit.cover)
                                      .image;
                                } catch (e) {
                                  print("Error loading image: $e");
                                }
                              }
                              return Image.asset('assets/icons/avatar.png',
                                      fit: BoxFit.cover)
                                  .image;
                            }(),
                          ),
                        ),
                        title: Text(
                          filteredContacts[index].givenName ?? "Unknown",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: (filteredContacts[index].phones != null &&
                                filteredContacts[index].phones!.isNotEmpty)
                            ? filteredContacts[index]
                                .phones![0]
                                .value
                                ?.text
                                .size(11)
                                .color(const Color.fromARGB(255, 122, 122, 122))
                                .fontWeight(FontWeight.w400)
                                .make()
                            : "no phone number"
                                .text
                                .color(const Color.fromARGB(255, 122, 122, 122))
                                .make(),
                        horizontalTitleGap: 12,
                      ).box.make().onTap(() {
                        navigateToContactDetails(filteredContacts[index]);
                      });
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
