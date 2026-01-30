import 'dart:async';
import 'dart:convert';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/client/client_list_controller.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:core/modules/ai/models/ai_profile_model.dart';
import 'package:core/modules/ai/resources/ai_repository.dart';
import 'package:core/modules/clients/models/client_filter_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

// Tag for the AI controller
const String aiControllerTag = 'ai_bottom_sheet';

// Message type enum for chat
enum ChatMessageType {
  user,
  ai,
}

// Chat message model
class ChatMessage {
  final String text;
  final ChatMessageType type;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AIController extends GetxController {
  final AIRepository aiRepository = AIRepository();
  final TextEditingController messageController = TextEditingController();
  final ClientListController clientListController;
  ApiResponse aiResponse = ApiResponse();

  String _assistantKey;
  AiScreenType _screenContext;

  // Chat message history
  final List<ChatMessage> chatHistory = [];

  // Raw AI response data
  String? rawResponse;
  Map<String, dynamic>? parsedFilters;
  String? resultSummary; // Summary of the results for display
  List<MessageMetadata>? messageMetadata;

  // Time unit patterns
  final _timePatterns = {
    'minutes': Duration.minutesPerHour,
    'hours': Duration.hoursPerDay,
    'days': Duration.hoursPerDay * 24,
    'weeks': Duration.hoursPerDay * 24 * 7,
    'months': Duration.hoursPerDay * 24 * 30, // Approximate
    'years': Duration.hoursPerDay * 24 * 365, // Approximate
  };

  AIController({
    required String assistantKey,
    required AiScreenType screenContext,
    PartnerOfficeModel? partnerOfficeModel,
  })  : _assistantKey = assistantKey,
        _screenContext = screenContext,
        clientListController = Get.put(
            ClientListController(partnerOfficeModel: partnerOfficeModel),
            tag: 'ai_client_list_controller');

  // Getters
  String get assistantKey => _assistantKey;
  AiScreenType get screenContext => _screenContext;

  // Setters
  set assistantKey(String value) {
    _assistantKey = value;
    update();
  }

  set screenContext(AiScreenType value) {
    _screenContext = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    clientListController.onInit();
  }

  @override
  void onClose() {
    messageController.dispose();
    clientListController.onClose();
    super.onClose();
  }

  @override
  void dispose() {
    messageController.dispose();
    clientListController.dispose();
    super.dispose();
  }

  // Convert relative time to timestamp
  String _convertRelativeTimeToTimestamp(String value) {
    value = value.toLowerCase().trim();

    // Return as is if it's already a number
    if (RegExp(r'^\d+$').hasMatch(value)) {
      return value;
    }

    // Match patterns like "7days", "2months", "1year", etc.
    final regex =
        RegExp(r'^(\d+)(minutes?|hours?|days?|weeks?|months?|years?)$');
    final match = regex.firstMatch(value);

    if (match != null) {
      final number = int.parse(match.group(1)!);
      var unit = match.group(2)!;

      // Normalize unit (remove trailing 's' if present)
      if (unit.endsWith('s')) {
        unit = unit.substring(0, unit.length - 1);
      }

      // Find the matching time unit
      for (var entry in _timePatterns.entries) {
        if (entry.key.startsWith(unit)) {
          // Calculate seconds from now
          final now = DateTime.now();
          final seconds = number * entry.value * 60; // Convert to seconds
          final timestamp = (now.millisecondsSinceEpoch ~/ 1000) - seconds;
          return timestamp.toString();
        }
      }
    }

    // Return original value if no conversion possible
    return value;
  }

  Future<WealthyAiProfileModel?> _getValidAssistant() async {
    final commonController = Get.find<CommonController>();
    WealthyAiProfileModel? assistant =
        commonController.getAssistantByAssistantKey(assistantKey);

    // Check if assistant exists and has required fields
    if (assistant == null ||
        assistant.threadId == null ||
        assistant.accessToken == null) {
      aiResponse.state = NetworkState.error;
      aiResponse.message = 'Failed to get AI assistant configuration';
      update();
      return null;
    }
    // Check if token is expired and refresh if needed
    if (assistant.expiresAt != null &&
        assistant.expiresAt! * 1000 < DateTime.now().millisecondsSinceEpoch) {
      await commonController.getWealthyAiAccessToken();
      assistant = commonController.getAssistantByAssistantKey(assistantKey);

      if (assistant == null ||
          assistant.threadId == null ||
          assistant.accessToken == null) {
        aiResponse.state = NetworkState.error;
        aiResponse.message = 'Failed to get AI assistant configuration';
        update();
        return null;
      }
    }
    return assistant;
  }

  Future<void> processAIQuery(String question) async {
    if (question.isEmpty) return;

    // Clear the input field immediately
    messageController.clear();
    update();

    // Get valid assistant with token
    final assistant = await _getValidAssistant();
    if (assistant == null) return;

    // Prepare request body
    final body = {
      "query": question,
      "assistant_key": assistantKey,
      "is_temporary": assistant.isTemporary,
    };

    // Set repository configuration
    aiRepository.setThreadIdAndAccessToken(
        assistant.threadId!, assistant.accessToken!);

    // Add to chat history if in FAQ mode
    if (screenContext == AiScreenType.faq) {
      chatHistory.add(ChatMessage(
        text: question,
        type: ChatMessageType.user,
      ));
    }

    // Reset states
    rawResponse = null;
    parsedFilters = null;
    messageMetadata = null;
    resultSummary = null;
    aiResponse.state = NetworkState.loading;
    update();

    try {
      final response = await aiRepository.getAiResponse(body);

      if (response == null || response['status'] != '200') {
        aiResponse.state = NetworkState.error;
        aiResponse.message = 'Failed to process query';
        update();
        return;
      }

      final responseData = WealthAIApiResponse.fromJson(response['response']);

      aiResponse.state = NetworkState.loaded;

      if (screenContext == AiScreenType.clients) {
        var query = responseData
            .contentJson?.widgetList?.first.detail!['data']!['query'];
        var summary = responseData
            .contentJson?.widgetList?.first.detail!['data']!['summary'];
        if (summary != null) {
          resultSummary = summary;
        }
        if (query != null) {
          rawResponse = query;
        }
        if (rawResponse != null) {
          await _parseAndApplyFilters(rawResponse!);
        }
      } else if (screenContext == AiScreenType.faq) {
        var responseValue = responseData.content;
        rawResponse = responseValue as String;
        messageMetadata = responseData.messageMetadata;
        if (rawResponse != null) {
          chatHistory.add(ChatMessage(
            text: rawResponse!,
            type: ChatMessageType.ai,
          ));
        }
      } else {
        aiResponse.state = NetworkState.error;
        aiResponse.message = 'Failed to process query';
        update();
        return;
      }
    } catch (e) {
      aiResponse.state = NetworkState.error;
      aiResponse.message = 'An error occurred while processing your query';
      if (screenContext == AiScreenType.faq) {
        chatHistory.add(ChatMessage(
          text: 'An error occurred while processing your query',
          type: ChatMessageType.ai,
        ));
      }
    } finally {
      update();
    }
  }

  Future<void> _parseAndApplyFilters(String queryString) async {
    try {
      final queryParams = Uri.splitQueryString(queryString);

      final searchQuery = queryParams['q'] ?? '';

      List<dynamic> filters = [];
      if (queryParams.containsKey('filters')) {
        filters = jsonDecode(queryParams['filters']!);
      }

      parsedFilters = {'query': searchQuery, 'filters': filters};
      clientListController.resetPagination();
      clientListController.searchController.text = searchQuery;
      Map<String, ClientFilterModel> newSelectedFilters = {};
      Map<String, ClientFilterModel> newTempFilters = {};

      // Apply new filters
      for (var filter in filters) {
        final key = filter['key'];
        final operation = filter['operation'];
        var value = filter['value'];
        var stringValue = value?.toString() ?? '';
        if (key.contains('_at') ||
            key.contains('date') ||
            key.contains('time')) {
          if (operation.toLowerCase() == 'bt' && stringValue.contains(',')) {
            final values = stringValue.split(',');
            if (values.length == 2) {
              stringValue =
                  '${_convertRelativeTimeToTimestamp(values[0])},${_convertRelativeTimeToTimestamp(values[1])}';
            }
          } else {
            stringValue = _convertRelativeTimeToTimestamp(stringValue);
          }
        }
        if (operation == 'sort_by') {
          clientListController.sortingMap[key] = key;
          clientListController.sortSelected = key;
        } else {
          final filterModel = ClientFilterModel.fromJson({
            'name': key,
            'display_name': key,
            'operators': [operation],
            'category': ['FILTER']
          });
          filterModel.selectedOperator = operation;
          if (operation.toLowerCase() == 'bt' && stringValue.contains(',')) {
            final values = stringValue.split(',');
            if (values.length == 2) {
              filterModel.inputValue = values[0].trim();
              filterModel.inputValue2 = values[1].trim();
            }
          } else {
            filterModel.inputValue = stringValue.trim();
          }
          if (filterModel.inputValue.isNotEmpty) {
            newSelectedFilters[key] = filterModel;
            newTempFilters[key] = ClientFilterModel.clone(filterModel);
          }
        }
      }
      clientListController.selectedFilterListMap = newSelectedFilters;
      clientListController.tempFilterListMap = newTempFilters;

      update();
      clientListController.queryClientList();
    } catch (e) {
      aiResponse.state = NetworkState.error;
      aiResponse.message = 'Failed to apply filters';
      update();
    }
  }

  void resetSearch() {
    messageController.clear();
    aiResponse = ApiResponse();
    rawResponse = null;
    parsedFilters = null;
    resultSummary = null;
    messageMetadata = null;
    // Only clear chat history for non-FAQ screens
    if (screenContext != AiScreenType.faq) {
      chatHistory.clear();
    }
    update();
  }

  Future<void> endSession() async {
    messageController.clear();
    unawaited(aiRepository.endSession());
    update();
  }
}
