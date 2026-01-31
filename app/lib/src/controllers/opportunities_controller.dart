import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/mock_opportunities_data.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/opportunities/models/insurance_opportunity_model.dart';
import 'package:core/modules/opportunities/models/opportunities_overview_model.dart';
import 'package:core/modules/opportunities/models/portfolio_opportunity_model.dart';
import 'package:core/modules/opportunities/models/sip_opportunity_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OpportunitiesController extends GetxController {
  ApiResponse portfolioOpportunitiesResponse = ApiResponse();
  ApiResponse stagnantSipOpportunitiesResponse = ApiResponse();
  ApiResponse stoppedSipOpportunitiesResponse = ApiResponse();
  ApiResponse insuranceOpportunitiesResponse = ApiResponse();
  ApiResponse opportunitiesOverviewResponse = ApiResponse();

  PortfolioOpportunitiesResponse? portfolioOpportunities;
  StagnantSipResponse? stagnantSipOpportunities;
  StoppedSipResponse? stoppedSipOpportunities;
  InsuranceOpportunitiesResponse? insuranceOpportunities;
  OpportunitiesOverviewResponse? opportunitiesOverview;

  // Cache keys
  static const String _overviewCacheKey = 'opportunities_overview_cache';
  static const String _overviewTimestampKey =
      'opportunities_overview_timestamp';

  @override
  void onInit() {
    getOpportunitiesOverview();
    initializeOpportunitiesData();
    super.onInit();
  }

  Future<void> initializeOpportunitiesData() async {
    await Future.wait([
      getPortfolioOpportunities(),
      getSipOpportunities(),
      getInsuranceOpportunities(),
    ]);
  }

  Future<void> getOpportunitiesOverview({bool forceRefresh = false}) async {
    try {
      // Check cache first (unless force refresh is requested)
      if (!forceRefresh) {
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString(_overviewCacheKey);
        final cachedTimestamp = prefs.getString(_overviewTimestampKey);

        if (cachedData != null && cachedTimestamp != null) {
          // Cache exists, use it
          try {
            opportunitiesOverview = OpportunitiesOverviewResponse.fromJson(
              jsonDecode(cachedData),
            );
            opportunitiesOverviewResponse.state = NetworkState.loaded;
            update();
            return; // Exit early, using cached data
          } catch (e) {
            // If cache parsing fails, continue to API call
            print('Error parsing cached overview data: $e');
          }
        }
      }

      // No cache or cache error or force refresh, proceed with API call
      opportunitiesOverviewResponse.state = NetworkState.loading;
      update();

      final apiKey = await getApiKey();

      final data =
          await AdvisorRepository().getOpportunitiesOverview(apiKey ?? '');

      if (data['status'] == '200') {
        opportunitiesOverview = OpportunitiesOverviewResponse.fromJson(
          data['response'] ?? {},
        );
        opportunitiesOverviewResponse.state = NetworkState.loaded;

        // Cache the successful response
        await _cacheOverviewResponse(data['response'] ?? {});
      } else if (data['status'] == '404') {
        // Use mock data when API returns 404
        opportunitiesOverview = OpportunitiesOverviewResponse.fromJson(
          MockOpportunitiesData.overviewData,
        );
        opportunitiesOverviewResponse.state = NetworkState.loaded;

        // Cache the mock data
        await _cacheOverviewResponse(MockOpportunitiesData.overviewData);
      } else {
        opportunitiesOverviewResponse.message =
            getErrorMessageFromResponse(data['response']);
        opportunitiesOverviewResponse.state = NetworkState.error;
      }
    } catch (e) {
      opportunitiesOverviewResponse.message = genericErrorMessage;
      opportunitiesOverviewResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> _cacheOverviewResponse(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_overviewCacheKey, jsonEncode(data));
      await prefs.setString(
        _overviewTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error caching overview response: $e');
    }
  }

  Future<void> clearOverviewCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_overviewCacheKey);
      await prefs.remove(_overviewTimestampKey);
    } catch (e) {
      print('Error clearing overview cache: $e');
    }
  }

  Future<DateTime?> getCachedOverviewTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(_overviewTimestampKey);
      if (timestampString != null) {
        return DateTime.parse(timestampString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> getPortfolioOpportunities() async {
    try {
      portfolioOpportunitiesResponse.state = NetworkState.loading;
      update();

      final apiKey = await getApiKey();

      final data =
          await AdvisorRepository().getPortfolioOpportunities(apiKey ?? '');

      if (data['status'] == '200') {
        portfolioOpportunities = PortfolioOpportunitiesResponse.fromJson(
          data['response'] ?? {},
        );
        portfolioOpportunitiesResponse.state = NetworkState.loaded;
      } else if (data['status'] == '404') {
        // Use mock data when API returns 404
        portfolioOpportunities = PortfolioOpportunitiesResponse.fromJson(
          MockOpportunitiesData.portfolioData,
        );
        portfolioOpportunitiesResponse.state = NetworkState.loaded;
      } else {
        portfolioOpportunitiesResponse.message =
            getErrorMessageFromResponse(data['response']);
        portfolioOpportunitiesResponse.state = NetworkState.error;
      }
    } catch (e) {
      portfolioOpportunitiesResponse.message = genericErrorMessage;
      portfolioOpportunitiesResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getSipOpportunities() async {
    try {
      stagnantSipOpportunitiesResponse.state = NetworkState.loading;
      stoppedSipOpportunitiesResponse.state = NetworkState.loading;
      update();

      final apiKey = await getApiKey();

      // Call both stagnant and stopped SIP APIs separately
      final stagnantData =
          await AdvisorRepository().getStagnantSipOpportunities(apiKey ?? '');
      final stoppedData =
          await AdvisorRepository().getStoppedSipOpportunities(apiKey ?? '');

      // Handle stagnant SIP response
      if (stagnantData['status'] == '200') {
        stagnantSipOpportunities = StagnantSipResponse.fromJson(
          stagnantData['response'] ?? {},
        );
        stagnantSipOpportunitiesResponse.state = NetworkState.loaded;
      } else if (stagnantData['status'] == '404') {
        // Use mock data when API returns 404
        stagnantSipOpportunities = StagnantSipResponse.fromJson(
          MockOpportunitiesData.stagnantSipData,
        );
        stagnantSipOpportunitiesResponse.state = NetworkState.loaded;
      } else {
        stagnantSipOpportunitiesResponse.message =
            getErrorMessageFromResponse(stagnantData['response']);
        stagnantSipOpportunitiesResponse.state = NetworkState.error;
      }

      // Handle stopped SIP response
      if (stoppedData['status'] == '200') {
        stoppedSipOpportunities = StoppedSipResponse.fromJson(
          stoppedData['response'] ?? {},
        );
        stoppedSipOpportunitiesResponse.state = NetworkState.loaded;
      } else if (stoppedData['status'] == '404') {
        // Use mock data when API returns 404
        stoppedSipOpportunities = StoppedSipResponse.fromJson(
          MockOpportunitiesData.stoppedSipData,
        );
        stoppedSipOpportunitiesResponse.state = NetworkState.loaded;
      } else {
        stoppedSipOpportunitiesResponse.message =
            getErrorMessageFromResponse(stoppedData['response']);
        stoppedSipOpportunitiesResponse.state = NetworkState.error;
      }
    } catch (e) {
      stagnantSipOpportunitiesResponse.message = genericErrorMessage;
      stagnantSipOpportunitiesResponse.state = NetworkState.error;
      stoppedSipOpportunitiesResponse.message = genericErrorMessage;
      stoppedSipOpportunitiesResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getInsuranceOpportunities() async {
    try {
      insuranceOpportunitiesResponse.state = NetworkState.loading;
      update();

      final apiKey = await getApiKey();

      final data =
          await AdvisorRepository().getInsuranceOpportunities(apiKey ?? '');

      if (data['status'] == '200') {
        insuranceOpportunities = InsuranceOpportunitiesResponse.fromJson(
          data['response'] ?? {},
        );
        insuranceOpportunitiesResponse.state = NetworkState.loaded;
      } else if (data['status'] == '404') {
        // Use mock data when API returns 404
        insuranceOpportunities = InsuranceOpportunitiesResponse.fromJson(
          MockOpportunitiesData.insuranceData,
        );
        insuranceOpportunitiesResponse.state = NetworkState.loaded;
      } else {
        insuranceOpportunitiesResponse.message =
            getErrorMessageFromResponse(data['response']);
        insuranceOpportunitiesResponse.state = NetworkState.error;
      }
    } catch (e) {
      insuranceOpportunitiesResponse.message = genericErrorMessage;
      insuranceOpportunitiesResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }
}
