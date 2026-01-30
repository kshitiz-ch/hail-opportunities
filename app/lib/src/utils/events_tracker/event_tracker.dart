import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:core/modules/transaction/models/mf_transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utility class for tracking transaction-related events for events screen integration
class EventTracker {
  /// Track transaction card clicked event
  static void trackTransactionCardClicked({
    required BuildContext context,
    required MfTransactionModel model,
  }) {
    try {
      String screen = 'Transactions';
      String screenLocation = 'Transactions';

      if (isPageAtTopStack(context, SipBookRoute.name)) {
        screen = 'SIP Book';
        screenLocation = 'Transaction Tab';
      } else if (isPageAtTopStack(context, ClientDetailRoute.name)) {
        screen = 'Client Detail';
        screenLocation = 'Transaction Tab';
      } else if (isPageAtTopStack(context, ClientGoalRoute.name)) {
        screen = 'Client Goal';
        screenLocation = 'Transaction Tab';
      }

      final eventProperties = {
        // Transaction Type: All, One-Time, SIP, Switch...
        'transaction_type': model.transactionType,
        // Status: All, Success, Failed, In-Progress
        'transaction_status': model.schemeStatus,
        // NAV, Units, AMC, Scheme Name from model
        'nav': model.nav,
        'units': model.units,
        'amc': model.amc,
        'scheme_name': model.schemeName,
      };

      // Track the event with MixPanel
      MixPanelAnalytics.trackWithAgentId(
        'transaction_card_clicked',
        screen: screen,
        screenLocation: screenLocation,
        properties: eventProperties,
      );
    } catch (error) {
      // Handle error silently to avoid disrupting user experience
      print('Error tracking event: $error');
    }
  }

  /// Track transactions viewed event
  static void trackTransactionsViewed({
    required TransactionController controller,
    required BuildContext? context,
  }) {
    try {
      // Get source from AutoRouter navigation history using isRouteParentOfCurrent
      String source = 'Quick Actions';
      String screen = 'Transactions';
      String screenLocation = 'Transactions';

      if (context != null) {
        if (isRouteParentOfCurrent(context, NotificationRoute.name)) {
          source = 'Notification';
        } else if (isPageAtTopStack(context, SipBookRoute.name)) {
          source = 'SIP Book';
          screen = 'SIP Book';
          screenLocation = 'Transaction Tab';
        } else if (isPageAtTopStack(context, ClientDetailRoute.name)) {
          source = 'Client Detail';
          screen = 'Client Detail';
          screenLocation = 'Transaction Tab';
        } else if (isPageAtTopStack(context, ClientGoalRoute.name)) {
          source = 'Client Goal';
          screen = 'Client Goal';
          screenLocation = 'Transaction Tab';
        }
      }

      // Build comprehensive event properties
      Map<String, dynamic> properties = {'source': source, 'page_name': screen};

      // Add transaction-specific properties from controller
      properties.addAll(
        {
          'tab_name': controller.selectedTab,
          'transaction_type': controller.selectedTransactionType,
          'transaction_status': controller.selectedTransactionStatus,
          'sort': controller.selectedSortOption,
          'date': controller.selectedTimeOption,
          if (controller.partnerOfficeModel != null)
            'employee_filter': controller
                    .partnerOfficeModel!.partnerEmployeeSelected?.designation ??
                'All Employees',
        },
      );

      // Add date range if applicable
      if (controller.fromDate != null && controller.toDate != null) {
        properties.addAll({
          'date_range_from': controller.fromDate!.toIso8601String(),
          'date_range_to': controller.toDate!.toIso8601String(),
        });
      }

      // Track the event with MixPanel
      MixPanelAnalytics.trackWithAgentId(
        'page_viewed',
        screen: screen,
        screenLocation: screenLocation,
        properties: properties,
      );
    } catch (error) {
      // Handle error silently to avoid disrupting user experience
      print('Error tracking event: $error');
    }
  }

  /// Track calculator report downloaded event
  static void trackReportDownloaded({
    required BuildContext? context,
    required String reportName,
    required String clientCRN,
    String format = 'pdf',
    required String pageName,
  }) {
    try {
      // Build comprehensive event properties
      Map<String, dynamic> properties = {
        'source': 'Calculators',
        'report_name': reportName,
        'client_crn': clientCRN,
        'format': format,
      };

      // Track the event with MixPanel
      MixPanelAnalytics.trackWithAgentId(
        'report_downloaded',
        screen: pageName,
        screenLocation: pageName,
        properties: properties,
      );
    } catch (error) {
      // Handle error silently to avoid disrupting user experience
      print('Error tracking event: $error');
    }
  }

  /// Track Resources CTA clicked event
  static void trackResourcesCTAClicked({
    required String ctaName,
    required CreativeNewModel? resource,
    bool? brandingAdded,
    bool? onboardingLink,
    String? pageName,
  }) {
    try {
      final details = _getResourceDetails(resource);

      final resourcesProperties = resource != null
          ? {
              'Title': resource.title ?? resource.name ?? '',
              'Description': resource.description ?? '',
              'Language': details['language'],
              'Tags': details['tags'],
              'Created_At': resource.createdAt?.toIso8601String() ?? '',
              'Updated_At': resource.updatedAt?.toIso8601String() ?? '',
            }
          : {};

      // Build comprehensive event properties
      Map<String, dynamic> properties = {
        'CTA_Name': ctaName,
        'Source': 'Resources',
        if (pageName.isNotNullOrEmpty) 'Page_Name': pageName,
        if (onboardingLink != null)
          'Onboarding_Link': onboardingLink == true ? 'Yes' : 'No',
        if (brandingAdded != null)
          'Branding_Added': brandingAdded == true ? 'Yes' : 'No',
        ...resourcesProperties,
      };

      // Track the event with MixPanel
      MixPanelAnalytics.trackWithAgentId(
        'CTA_Clicked',
        screenLocation: 'Resources',
        properties: properties,
      );
    } catch (error) {
      // Handle error silently to avoid disrupting user experience
      print('Error tracking event: $error');
    }
  }

  static void trackResourcesViewed({required CreativeNewModel resource}) {
    try {
      final details = _getResourceDetails(resource);

      final properties = {
        'Resource_Name': resource.isImage ? 'Posters' : 'PDF',
        'Title': resource.title ?? resource.name ?? '',
        'Description': resource.description ?? '',
        'Language': details['language'],
        'Tags': details['tags'],
        'Created_At': resource.createdAt?.toIso8601String() ?? '',
        'Updated_At': resource.updatedAt?.toIso8601String() ?? '',
      };

      MixPanelAnalytics.trackWithAgentId(
        'Resource_Viewed',
        screenLocation: 'Resources',
        properties: properties,
      );
    } catch (error) {
      // Handle error silently to avoid disrupting user experience
      print('Error tracking event: $error');
    }
  }

  /// Helper method to extract Language and Tags from resource
  static Map<String, String> _getResourceDetails(CreativeNewModel? resource) {
    if (resource == null) return {};

    String language = 'English';
    String tags = '';

    if (Get.isRegistered<AppResourcesController>()) {
      final controller = Get.find<AppResourcesController>();
      final isImage = resource.isImage;
      final languageList =
          isImage ? controller.languages : controller.salesKitLanguages;

      final languageTagIds = languageList.map((lang) => lang.tag).toSet();

      List<String> extractedTags = [];

      if (resource.allTags != null) {
        for (var tag in resource.allTags!) {
          if (languageTagIds.contains(tag.id)) {
            language = tag.name ?? language;
          } else if (tag.id != unempanelledTag.tag &&
              tag.id != salesKitAllTag.tag) {
            if (tag.name != null) extractedTags.add(tag.name!);
          }
        }
      }
      tags = extractedTags.join(', ');
    }

    return {'language': language, 'tags': tags};
  }
}
