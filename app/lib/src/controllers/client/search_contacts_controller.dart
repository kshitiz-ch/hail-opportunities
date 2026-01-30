import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class SearchContactsController extends GetxController {
  List<Client> contacts = [];

  String searchQuery = '';
  ApiResponse searchResponse = ApiResponse();

  Timer? _debounce;

  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    // getContacts(query: '');
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> getContacts({String? query}) async {
    // Reset contacts list every time search happens
    contacts.clear();
    try {
      searchResponse.state = NetworkState.loading;
      update();

      List<Client> contactsFound = await searchContacts(query);

      contacts = contactsFound;

      searchResponse.state = NetworkState.loaded;
    } catch (error) {
      LogUtil.printLog(error);
      searchResponse.state = NetworkState.error;
      searchResponse.message = "Something went wrong. Please try again";
    } finally {
      update();
    }
  }

  Future<List<Client>> searchContacts(query) async {
    List<Client> contactsFound = [];

    void addContactToSearchList(contact, phoneNumber) {
      Client clientModel = Client(
        name: contact?.displayName,
        phoneNumber: phoneNumber.toString().replaceAll(' ', ''),
        email: '',
        isSourceContacts: true,
      );
      bool isPhoneNumberExists =
          checkPhoneNumberExists(contactsFound, clientModel.phoneNumber);

      if (!isPhoneNumberExists) {
        contactsFound.insert(0, clientModel);
      }
    }

    // Request permission first, then get contacts
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties:
            true, // Get detailed contact info including phone numbers
      );

      // Filter contacts by query if provided
      if (query != null && query.isNotEmpty) {
        contacts = contacts.where((contact) {
          return contact.displayName
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      }

      // Limit no of contacts shown
      if (contacts.length > 20) {
        contacts = contacts.sublist(0, 20);
      }

      contacts.forEach(
        (contact) {
          bool hasMultipleNumbers = contact.phones.length > 1;
          if (hasMultipleNumbers) {
            contact.phones.forEach(
              (phoneNumberItem) {
                addContactToSearchList(contact, phoneNumberItem.number);
              },
            );
          } else {
            var phoneNumber = contact.phones.isNotEmpty
                ? contact.phones[0].number.toString().replaceAll(' ', '')
                : null;
            addContactToSearchList(contact, phoneNumber);
          }
        },
      );
    } else {
      // Permission denied
      LogUtil.printLog('Contacts permission denied');
    }

    return contactsFound;
  }

  onContactSearch(String query) {
    if (query.isEmpty) {
      searchQuery = query;
      getContacts(query: '');

      update();
      _debounce!.cancel();
    } else {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }

      _debounce = Timer(
        const Duration(milliseconds: 500),
        () {
          searchQuery = query;
          getContacts(query: query);

          update();
        },
      );
    }
  }

  bool checkPhoneNumberExists(List<Client> contacts, phone) {
    bool isPhoneNumberExists = false;
    for (var i = 0; i < contacts.length; i++) {
      String currentContactPhone = sanitizePhoneNumber(phone);
      String existingContactPhone =
          sanitizePhoneNumber(contacts[i].phoneNumber);
      if (currentContactPhone == existingContactPhone) {
        isPhoneNumberExists = true;
        break;
      }
    }

    return isPhoneNumberExists;
  }

  void clearSearchBar() {
    searchQuery = '';
    searchController.clear();
    getContacts(query: '');
  }
}
