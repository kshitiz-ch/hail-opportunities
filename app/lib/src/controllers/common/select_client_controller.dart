import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/main.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/clients/models/family_list_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:graphql/client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectClientController extends GetxController {
  List<Client?>? recentClients = [];
  List<Client?>? searchClients = [];
  List<Client> familyMembers = [];
  Client? selectedClient;
  Client? activeClient;
  Client? lastSelectedClient;

  bool shouldSearchContacts = false;
  bool shouldCheckContactPermission = true;
  bool showTrackerSyncClients = false;
  bool enablePartnerOfficeSupport = false;

  String searchQuery = '';
  String searchErrorMessage = '';

  NetworkState searchState = NetworkState.cancel;
  NetworkState fetchFamilyState = NetworkState.cancel;

  Timer? _debounce;

  TextEditingController searchController = TextEditingController();

  PartnerOfficeModel? partnerOfficeModel;

  // Constructor
  SelectClientController({
    this.lastSelectedClient,
    this.shouldCheckContactPermission = true,
    this.showTrackerSyncClients = false,
    this.enablePartnerOfficeSupport = false,
  });

  @override
  void onInit() {
    getRecentClients();
    if (shouldCheckContactPermission) {
      // checkContactPermissionStatus();
    }
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  checkContactPermissionStatus() async {
    try {
      bool isContactPermissionGranted = await Permission.contacts.isGranted;
      if (isContactPermissionGranted) {
        toggleSearchContactSwitch(true);
      } else {
        SharedPreferences sharedPreferences = await prefs;
        bool hasContactPermissionAsked = sharedPreferences
                .getBool(SharedPreferencesKeys.hasContactPermissionAsked) ??
            false;

        if (!hasContactPermissionAsked && !isContactPermissionGranted) {
          sharedPreferences.setBool(
              SharedPreferencesKeys.hasContactPermissionAsked, true);

          List<Permission> permissionList = [
            Permission.contacts,
          ];

          Map<Permission, PermissionStatus> permissionStatuses =
              await permissionList.request();

          if (permissionStatuses[Permission.contacts]!.isGranted) {
            toggleSearchContactSwitch(true);
          }
        }
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  resetSelectedClient() {
    selectedClient = null;
  }

  getRecentClients() async {
    try {
      searchState = NetworkState.loading;
      update([GetxId.searchClient]);

      int? agentId = await getAgentId();
      String apiKey = (await getApiKey())!;

      String? agentExternalId = enablePartnerOfficeSupport
          ? (await getAgentExternalIdList()).join(',')
          : await getAgentExternalId();

      late QueryResult response;

      if (showTrackerSyncClients) {
        final payload = {
          'requestAgentId': agentExternalId,
          'offset': 0,
          'limit': 20,
          'trakCobOpportunityValueFilter': '+1',
        };

        response =
            await AdvisorRepository().getTicobOpportunities(payload, apiKey);
      } else {
        response = await (ClientListRepository().queryClientData(
          agentId.toString(),
          false,
          false,
          apiKey,
          limit: 20,
          requestAgentId: agentExternalId,
        ));
      }

      if (response.hasException) {
        response.exception!.graphqlErrors.forEach((graphqlError) {
          LogUtil.printLog(graphqlError.message);
        });
        searchErrorMessage = "Something went wrong";
        searchState = NetworkState.error;
      } else {
        ClientListModel clientListModel = ClientListModel.fromJson(
          response.data!['hydra'],
        );
        recentClients = clientListModel.clients;
        searchState = NetworkState.loaded;

        // If lastSelected is not null, update recentClients list
        // with lastSelected as the first element
        if (lastSelectedClient != null) {
          addLastSelectedToRecentClients(lastSelectedClient);
        }
      }
    } catch (error) {
      LogUtil.printLog(error);
      searchErrorMessage = "Something went wrong";

      searchState = NetworkState.error;
    } finally {
      update([GetxId.searchClient]);
    }
  }

  Future<void> getClientFamily() async {
    try {
      fetchFamilyState = NetworkState.loading;
      activeClient = selectedClient;

      // Reset family members state
      familyMembers = [];
      update([GetxId.searchClient]);

      String apiKey = (await getApiKey())!;

      final response = await ClientListRepository()
          .fetchFamilyMembers(apiKey, selectedClient!.taxyID!);
      if (response.hasException) {
        response.exception.graphqlErrors.forEach(
          (graphqlError) {
            LogUtil.printLog(
                'fetchClientFamily error==> ${graphqlError.message}');
          },
        );
        fetchFamilyState = NetworkState.error;
      } else {
        final familyListModel =
            (response.data!['hagrid']['familyMembers'] as List)
                .map(
                  (memberJson) => FamilyModel.fromJson(memberJson),
                )
                .toList();

        familyListModel.forEach((FamilyModel member) {
          String name = '${member.memberName ?? ""}';
          if (name.trim().isNullOrEmpty) {
            name = member.memberName ?? '';
          }
          Client client = Client(
            taxyID: member.memberUserID,
            email: member.emailAddress,
            name: name,
            phoneNumber: member.memberPhoneNumber,
            isSourceContacts: false,
          );
          familyMembers.add(client);
        });
        fetchFamilyState = NetworkState.loaded;
      }
    } catch (error) {
      fetchFamilyState = NetworkState.error;
    } finally {
      update([GetxId.searchClient]);
    }
  }

  void addLastSelectedToRecentClients(Client? client) {
    int index =
        recentClients!.indexWhere((element) => element!.id == client!.id);

    if (index == -1) {
      recentClients!.insert(0, client);
    } else {
      recentClients!.insert(0, recentClients!.removeAt(index));
    }
  }

  getSearchClient(String query) async {
    // fix:
    // empty state Ui is shown for fraction of second because
    // searchState = NetworkState.loaded;
    // as toggleSearchContactSwitch onInit calls getSearchClient
    // before getRecentClients is completed
    if (query.isNullOrEmpty && recentClients.isNullOrEmpty) {
      return;
    }
    try {
      searchState = NetworkState.loading;
      update([GetxId.searchClient]);

      List<Client?>? clientsFound = [];

      int? agentId = await getAgentId();
      String? apiKey = await getApiKey();
      String? agentExternalId = enablePartnerOfficeSupport
          ? (await getAgentExternalIdList()).join(',')
          : await getAgentExternalId();

      // If no search query, then use the recent client list
      if (query.isEmpty) {
        clientsFound = recentClients;
      } else {
        late QueryResult response;

        if (showTrackerSyncClients) {
          final payload = {
            'requestAgentId': agentExternalId,
            'offset': 0,
            'limit': 20,
            if (query.isNotNullOrEmpty) 'q': query,
            'trakCobOpportunityValueFilter': '+1',
          };

          response =
              await AdvisorRepository().getTicobOpportunities(payload, apiKey!);
        } else {
          response = await ClientListRepository().queryClientData(
            agentId.toString(),
            false,
            false,
            apiKey!,
            query: query,
            requestAgentId: enablePartnerOfficeSupport ? agentExternalId : '',
            limit: 20,
            offset: 0,
          );
        }

        if (!response.hasException) {
          ClientListModel clientSearchList =
              ClientListModel.fromJson(response.data!['hydra']);

          clientsFound.addAll(clientSearchList.clients!);
        }
      }

      if (shouldSearchContacts && query.isNotEmpty) {
        try {
          await getContacts(query, clientsFound);
        } catch (error) {
          LogUtil.printLog(error);
        }
      }

      searchClients = clientsFound;
      update([GetxId.searchClient]);
    } catch (error) {
      searchErrorMessage = "Something went wrong";
      searchState = NetworkState.error;
    } finally {
      searchState = NetworkState.loaded;
      update([GetxId.searchClient]);
    }
  }

  getContacts(query, List<Client?>? clientsFound) async {
    void addContactToSearchClientList(Contact contact, phoneNumber) {
      Client? clientModel = Client(
        name: contact.displayName,
        phoneNumber: phoneNumber.toString().replaceAll(' ', ''),
        email: '',
        isSourceContacts: true,
      );

      bool isPhoneNumberExists =
          checkPhoneNumberExists(clientsFound, clientModel.phoneNumber);

      if (!isPhoneNumberExists) {
        clientsFound!.insert(0, clientModel);
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
                addContactToSearchClientList(contact, phoneNumberItem.number);
              },
            );
          } else {
            var phoneNumber = contact.phones.isNotEmpty
                ? contact.phones[0].number.toString().replaceAll(' ', '')
                : null;
            addContactToSearchClientList(contact, phoneNumber);
          }
        },
      );
    } else {
      // Permission denied
      LogUtil.printLog('Contacts permission denied in SelectClientController');
    }
  }

  onClientSearch(String query) {
    if (query.isEmpty) {
      searchClients = [];
      searchQuery = query;
      resetSelectedClient();

      update([GetxId.searchClient]);
      _debounce!.cancel();
    } else {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }

      _debounce = Timer(
        const Duration(milliseconds: 500),
        () {
          resetSelectedClient();
          searchQuery = query;

          if (query.isNotEmpty) {
            getSearchClient(query);
          } else {
            searchClients = [];
          }

          update([GetxId.searchClient]);
        },
      );
    }
  }

  onClientSelect(Client? client) {
    if (selectedClient == client) {
      return;
    } else {
      selectedClient = client;
    }

    update([GetxId.searchClient]);
  }

  toggleSearchContactSwitch(bool enableSearchContact) {
    // shouldSearchContacts = enableSearchContact;
    resetSelectedClient();
    update([GetxId.searchClient]);

    getSearchClient(searchQuery);
    // if (enableSearchContact && searchQuery.isNotEmpty) {
    //   getSearchClient(searchQuery);
    // } else {
    //   getSearchClient(null);
    // }
  }

  bool checkPhoneNumberExists(List<Client?>? contacts, phone) {
    bool isPhoneNumberExists = false;
    if (contacts.isNullOrEmpty) {
      return false;
    }

    for (var i = 0; i < contacts!.length; i++) {
      String currentContactPhone = sanitizePhoneNumber(phone);
      String existingContactPhone =
          sanitizePhoneNumber(contacts[i]!.phoneNumber);
      if (currentContactPhone == existingContactPhone) {
        isPhoneNumberExists = true;
        break;
      }
    }

    return isPhoneNumberExists;
  }

  void updatePartnerEmployeeSelected(PartnerOfficeModel partnerOfficeModel) {
    this.partnerOfficeModel = partnerOfficeModel;
    clearSearchBar();
  }

  Future<List<String>> getAgentExternalIdList() async {
    List<String> agentExternalIds = [];
    if (partnerOfficeModel != null) {
      agentExternalIds = partnerOfficeModel!.agentExternalIds;
    }
    if (agentExternalIds.isNullOrEmpty) {
      agentExternalIds = [await getAgentExternalId() ?? ''];
    }
    return agentExternalIds;
  }

  clearSearchBar() {
    selectedClient = null;
    activeClient = null;
    searchClients = [];
    familyMembers = [];
    searchQuery = '';
    searchController.text = '';
    update([GetxId.searchClient]);
    getRecentClients();
  }
}
