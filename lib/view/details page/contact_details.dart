// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ContactDetails extends StatefulWidget {
  final Contact contact;
  final Function(Contact) onContactUpdate;
  final Function(Contact) onContactDelete;

  const ContactDetails({
    Key? key,
    required this.contact,
    required this.onContactUpdate,
    required this.onContactDelete,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<ContactDetails> createState() => _ContactDetailsState(contact);
}

class _ContactDetailsState extends State<ContactDetails> {
  late Contact _contact;

  _ContactDetailsState(Contact contact) {
    _contact = contact;
  }

  Future<void> onAction(String action) async {
    switch (action) {
      case 'Edit':
        try {
          Contact updatedContact =
              await ContactsService.openExistingContact(_contact);
          widget.onContactUpdate(updatedContact);
          setState(() {
            _contact = updatedContact;
          });
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
        break;
      case 'Delete':
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Builder(
                builder: (context) {
                  return showDeleteConfirmation();
                },
              );
            });
        break;
    }
  }

  Widget showDeleteConfirmation() {
    Widget cancelButton = ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text("Cancel", style: TextStyle(color: Colors.white)),
    );
    Widget deleteButton = ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      onPressed: () async {
        await ContactsService.deleteContact(_contact);
        await widget.onContactDelete(_contact);
        Navigator.pop(context);
      },
      child: const Text(
        "Delete",
        style: TextStyle(color: Colors.white),
      ),
    );
    return AlertDialog(
      title: const Text("Delete contact"),
      content: const Text("Are you sure you want to delete this contact"),
      actions: [cancelButton, deleteButton],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Contact Details'.text.make(),
        actions: [
          PopupMenuButton(
            onSelected: onAction,
            itemBuilder: (BuildContext context) {
              return ['Edit', 'Delete'].map((action) {
                return PopupMenuItem(value: action, child: Text(action));
              }).toList();
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          30.heightBox,
          // Display avatar or placeholder image based on the conditions
          getAvatarImage(),
          10.heightBox,
          '${_contact.givenName}'.text.color(Colors.black).make(),
          10.heightBox,
          if (_contact.phones != null && _contact.phones!.isNotEmpty)
            'phone ${_contact.phones![0].value}'.text.color(Colors.black).make()
          else
            ''.text.color(Colors.black).make(),
          20.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              60.widthBox,
              Image.asset(
                'assets/icons/call.png',
                width: 40,
              ),
              Image.asset('assets/icons/chat.png', width: 40),
              60.widthBox,
            ],
          ),
        ],
      ),
    );
  }

  Widget getAvatarImage() {
    if (_contact.avatar != null && _contact.avatar!.isNotEmpty) {
      return ClipOval(
        child: Builder(
          builder: (context) {
            return Image.memory(
              _contact.avatar!,
              fit: BoxFit.cover,
              width: 150,
              height: 150,
            );
          },
        ),
      );
    } else {
      return ClipOval(
        child: Image.asset(
          'assets/icons/avatar.png',
          fit: BoxFit.cover,
          width: 150,
          height: 150,
        ),
      );
    }
  }
}
