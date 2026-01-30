import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/resources/widgets/resources_sort_list.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:core/modules/app_resources/resources/app_resources_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:core/modules/dashboard/models/branding_model.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

final unempanelledTag = TagModel(tag: "tag_DqRQ9vL5KL5", text: "Unemp");
final salesKitAllTag = TagModel(tag: "tag_HXhndXyoVm7", text: "All");

class AppResourcesController extends GetxController {
  ApiResponse searchResponse = ApiResponse();

  List<CreativeNewModel> resources = [];
  ApiResponse resourceResponse = ApiResponse();
  MetaDataModel resourceMetaData = MetaDataModel();
  bool isResourcesPaginating = false;

  ApiResponse getFiltersResponse = ApiResponse();

  TagModel allCategory = TagModel.fromJson({
    "text": "All",
    "tag": "all",
    "imagePath": AllImages().posterAllIcon,
  });

  List<TagModel> categories = [];
  List<TagModel> languages = [];
  List<TagModel> salesKitCategories = [];
  List<TagModel> salesKitLanguages = [];

  // Getters for active categories and languages based on selected tab
  List<TagModel> get activeCategories =>
      isMarketingKitSelected ? categories : salesKitCategories;

  List<TagModel> get activeLanguages =>
      isMarketingKitSelected ? languages : salesKitLanguages;

  TagModel? defaultCategory;
  TagModel? defaultLanguage;

  TagModel? languageSelected;

  ApiResponse brandingResponse = ApiResponse();
  BrandingModel? branding;

  final homeController = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put<HomeController>(HomeController());

  final bool isResourcesHomeScreen;

  ScrollController scrollController = ScrollController();
  ItemScrollController creativesHorizScrollController = ItemScrollController();
  final ItemPositionsListener creativesHorizPositionsListener =
      ItemPositionsListener.create();

  ApiResponse creativesResponse = ApiResponse(state: NetworkState.loading);
  List<CreativeNewModel> creativesList = [];
  MetaDataModel creativesMetaData = MetaDataModel();
  bool isCreativesPaginating = false;

  ApiResponse recentlyAddedResponse = ApiResponse();
  List<CreativeNewModel> recentlyAddedList = [];

  final tabs = ['Poster Gallery', 'Sales Kit'];
  String selectedTab = 'Poster Gallery';
  bool get isMarketingKitSelected => selectedTab == 'Poster Gallery';

  // White label creative properties
  ApiResponse whiteLabelResponse = ApiResponse();
  File? whiteLabelFile;
  Uint8List? whiteLabelCreativeBytes;
  int currentIndex = 0;
  bool shareWithOnboardingLink = false;
  bool isOnboardingLinkAutoCopied = false;

  AppResourcesSource currentSource = AppResourcesSource.marketing;
  List<CreativeNewModel> singleCreativeList = [];

  List<CreativeNewModel> get activeList {
    switch (currentSource) {
      case AppResourcesSource.marketing:
        return creativesList;
      case AppResourcesSource.sales:
        return resources;
      case AppResourcesSource.recentlyAdded:
        return recentlyAddedList;
      case AppResourcesSource.single:
        return singleCreativeList;
    }
  }

  void setSource(AppResourcesSource source, {CreativeNewModel? singleItem}) {
    currentSource = source;
    if (source == AppResourcesSource.single && singleItem != null) {
      singleCreativeList = [singleItem];
    }
    // update(); // update is called in updateCurrentIndex usually, or we can call it here if needed.
    // But usually setSource is called in initState of BottomSheet, so we might not need immediate update if we call updateCurrentIndex right after.
  }

  // PDF properties
  ApiResponse pdfResponse = ApiResponse();
  Uint8List? pdfBytes;
  File? pdfFile;
  int currentPdfPage = 0;
  int totalPdfPages = 0;
  PDFViewController? pdfViewController;

  // PDF Branding
  ApiResponse pdfBrandingResponse = ApiResponse();
  Uint8List? brandedPdfBytes;

  // Filter and Sort
  FilterMode currentFilterMode = FilterMode.filter;
  List<TagModel> tempCategoriesSelected = [];
  List<TagModel> selectedCategories = []; // Actual applied categories
  ResourcesSortOption? tempSortSelected;
  ResourcesSortOption? sortSelected;

  TextEditingController? searchController;
  Timer? _debounce;
  String searchText = '';
  late FocusNode searchBarFocusNode;

  int initialTabIndex = 0;

  AppResourcesController({
    this.initialTabIndex = 0,
    this.defaultCategory,
    this.defaultLanguage,
    this.isResourcesHomeScreen = false,
  }) {
    selectedTab = tabs[initialTabIndex];
  }

  @override
  void onInit() async {
    searchController = TextEditingController();
    searchBarFocusNode = FocusNode();

    scrollController.addListener(handlePagination);

    creativesHorizPositionsListener.itemPositions.addListener(() {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }

      _debounce = Timer(
        const Duration(milliseconds: 50),
        () {
          handleHorizScrollPagination();
        },
      );
    });

    super.onInit();
  }

  @override
  void onReady() async {
    await getCategoriesAndLanguages();
    getBrandingDetail();

    if (!isResourcesHomeScreen) {
      getRecentlyAdded();
      onTabChange(initialTabIndex, useDefault: true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController!.dispose();
    searchBarFocusNode.dispose();
    super.dispose();
  }

  void clearSearchBar() {
    searchText = "";
    searchController!.clear();
    searchResponse.state = NetworkState.cancel;

    update();
  }

  Future<void> onTabChange(int index, {bool useDefault = false}) async {
    // Wait for filters to be loaded before allowing tab change
    while (getFiltersResponse.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    selectedTab = tabs[index];

    // Clear selected filters when switching tabs
    selectedCategories.clear();

    if (useDefault && defaultCategory != null) {
      selectedCategories.add(defaultCategory!);
    }

    if (isMarketingKitSelected) {
      // Use marketing kit filters
      if (useDefault && defaultLanguage != null) {
        languageSelected = defaultLanguage;
      } else {
        languageSelected = languages.isNotEmpty ? languages.first : null;
      }
    } else {
      // Use sales kit filters - insert "All" tag for sales kit
      if (salesKitLanguages.isNotEmpty &&
          !salesKitLanguages.contains(salesKitAllTag)) {
        salesKitLanguages.insert(0, salesKitAllTag);
      }

      if (useDefault && defaultLanguage != null) {
        languageSelected = defaultLanguage;
      } else {
        languageSelected = salesKitLanguages.isNotEmpty
            ? salesKitLanguages.firstWhereOrNull(
                    (language) => language.text?.toLowerCase() == "english") ??
                salesKitLanguages.first
            : null;
      }
    }

    getData();

    // Track page view
    MixPanelAnalytics.trackWithAgentId(
      "page_viewed",
      properties: {
        "page_name": selectedTab,
        "source": "Resources Tab",
        "module_name": "Resources",
      },
    );
  }

  void getData() {
    if (isMarketingKitSelected) {
      getCreatives();
    } else {
      getResources();
    }
  }

  ApiResponse get apiResponse {
    return isMarketingKitSelected ? creativesResponse : resourceResponse;
  }

  Future<void> getCategoriesAndLanguages() async {
    getFiltersResponse.state = NetworkState.loading;
    update();

    try {
      var data = await AppResourcesRepository().getCreativeFilters();
      if (data["status"] == "200") {
        updateCreativeFilters(data["response"]);
      } else {
        updateCreativeFilters(defaultTagsData);
      }
    } catch (error) {
      updateCreativeFilters(defaultTagsData);
    } finally {
      getFiltersResponse.state = NetworkState.loaded;
      update();
    }
  }

  void updateCreativeFilters(filters) {
    List categoriesJson = filters["categories"] ?? [];
    List languagesJson = filters["languages"] ?? [];
    List salesKitCategoriesJson = filters["sales_kit_categories"] ?? [];
    List salesKitLanguagesJson = filters["sales_kit_languages"] ?? [];

    // Clear existing lists
    categories.clear();
    languages.clear();
    salesKitCategories.clear();
    salesKitLanguages.clear();

    // Add "All" category first so it shows at the top
    categories.add(allCategory);

    // Process marketing kit categories
    categoriesJson.forEach((categoryJson) {
      TagModel category = TagModel.fromJson(categoryJson);
      if (defaultCategory != null && category.tag == defaultCategory?.tag) {
        defaultCategory = category;
      }
      categories.add(category);
    });

    // Process marketing kit languages
    languagesJson.forEach((languageJson) {
      TagModel language = TagModel.fromJson(languageJson);
      if (defaultLanguage != null && language.tag == defaultLanguage?.tag) {
        defaultLanguage = language;
      }
      languages.add(language);
    });

    // Process sales kit categories
    salesKitCategoriesJson.forEach((categoryJson) {
      TagModel category = TagModel.fromJson(categoryJson);
      salesKitCategories.add(category);
    });

    // Process sales kit languages
    salesKitLanguagesJson.forEach((languageJson) {
      TagModel language = TagModel.fromJson(languageJson);
      salesKitLanguages.add(language);
    });

    if (defaultCategory != null && defaultCategory?.text != null) {
      selectedCategories.add(defaultCategory!);
    }

    if (defaultLanguage != null && defaultLanguage?.text != null) {
      languageSelected = defaultLanguage;
    } else if (languages.isNotEmpty) {
      languageSelected = languages.first;
    }
  }

  String? getSelectedLanguageTag({bool isSalesKit = false}) {
    final selectedLanguageText = languageSelected?.text?.toLowerCase();
    String? selectedLanguageTag;

    if (isSalesKit) {
      selectedLanguageTag = salesKitLanguages
              .firstWhereOrNull((language) =>
                  language.text?.toLowerCase() == selectedLanguageText)
              ?.tag ??
          salesKitLanguages.first.tag;
    } else {
      selectedLanguageTag = languages
              .firstWhereOrNull(
                (language) =>
                    language.text?.toLowerCase() == selectedLanguageText,
              )
              ?.tag ??
          languages.first.tag;
    }
    return selectedLanguageTag;
  }

  Future<void> getBrandingDetail() async {
    branding = null;
    brandingResponse.state = NetworkState.loading;
    update();

    try {
      final apiKey = await getApiKey() ?? '';

      final response = await AdvisorRepository().getBrandingDetail(
        apiKey,
        preview: false,
      );

      if (response != null && response['status'] == '200') {
        brandingResponse.state = NetworkState.loaded;
        branding = BrandingModel.fromJson(response['response']);
      } else {
        brandingResponse.state = NetworkState.error;
        brandingResponse.message = 'No branding data received';
      }
    } catch (error) {
      brandingResponse.state = NetworkState.error;
      brandingResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> getResources() async {
    if (!isResourcesPaginating) {
      resourceMetaData.page = 0;
      resources.clear();
    }

    resourceResponse.state = NetworkState.loading;
    update();

    try {
      final apiKey = await getApiKey();

      int offset = ((resourceMetaData.page + 1) * resourceMetaData.limit) -
          resourceMetaData.limit;

      List<String> tags = [];

      // Add multiple categories if selected
      if (selectedCategories.isNotEmpty) {
        for (var category in selectedCategories) {
          if (category.tag != allCategory.tag) {
            tags.add(category.tag ?? '');
          }
        }
      }

      tags.add(getSelectedLanguageTag(isSalesKit: true) ?? '');

      final payload = {"tenant": "partner_downloads", "tags": tags};

      // Apply sorting based on sortSelected
      String orderBy;
      if (sortSelected == ResourcesSortOption.oldestFirst) {
        orderBy = 'updated_at'; // Ascending order (oldest first)
      } else {
        // Default to newest first (covers both newestFirst and null cases)
        orderBy = '-updated_at'; // Descending order (newest first)
      }

      final queryParams =
          '?limit=${resourceMetaData.limit}&offset=$offset&order_by=$orderBy';

      final response = await AppResourcesRepository().getResources(
        apiKey: apiKey ?? '',
        queryParams: queryParams,
        payload: payload,
      );

      if (response != null && response['status'] == '200') {
        resourceMetaData.totalCount =
            WealthyCast.toInt(response["response"]["total"]) ?? 0;

        final resourcesListJson =
            WealthyCast.toList(response['response']?['data']);

        List.generate(
          resourcesListJson.length,
          (index) {
            final resourceModel =
                CreativeNewModel.fromJson(resourcesListJson[index]);
            if (resourceModel.url.isNotNullOrEmpty) {
              resources.add(resourceModel);
            }
          },
        );

        resourceResponse.state = NetworkState.loaded;
      } else {
        resourceResponse.message = genericErrorMessage;
        resourceResponse.state = NetworkState.error;
      }
    } catch (error) {
      resourceResponse.message = genericErrorMessage;
      resourceResponse.state = NetworkState.error;
    } finally {
      isResourcesPaginating = false;
      update();
    }
  }

  Future<void> getCreatives() async {
    if (!isCreativesPaginating) {
      creativesMetaData.page = 0;
      creativesList.clear();
    }

    creativesResponse.state = NetworkState.loading;
    update();

    try {
      bool isEmpanelmentDone = true;

      // Wait until advisorOverviewState is loaded or error for deeplink / push notification case
      while (homeController.advisorOverviewState != NetworkState.loaded &&
          homeController.advisorOverviewState != NetworkState.error) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (homeController.advisorOverviewState == NetworkState.loaded) {
        isEmpanelmentDone =
            homeController.isKycDone && homeController.isEmpanelmentCompleted;
      }

      String apiKey = await getApiKey() ?? '';
      List<String> tags = [];

      // Add multiple categories if selected
      if (selectedCategories.isNotEmpty) {
        for (var category in selectedCategories) {
          if (category.tag != allCategory.tag) {
            tags.add(category.tag ?? '');
          }
        }
      }

      tags.add(getSelectedLanguageTag() ?? '');

      if (!isEmpanelmentDone) {
        tags.add(unempanelledTag.tag ?? '');
      }

      int offset = ((creativesMetaData.page + 1) * creativesMetaData.limit) -
          creativesMetaData.limit;

      final payload = {"tenant": "pgallery", "tags": tags};

      // Apply sorting based on sortSelected
      String orderBy;
      if (sortSelected == ResourcesSortOption.oldestFirst) {
        orderBy = 'created_at'; // Ascending order (oldest first)
      } else {
        // Default to newest first (covers both newestFirst and null cases)
        orderBy = '-created_at'; // Descending order (newest first)
      }

      final queryParams =
          '?limit=${creativesMetaData.limit}&offset=$offset&order_by=$orderBy&filetype=img';

      final data = await AppResourcesRepository().getResources(
        apiKey: apiKey,
        queryParams: queryParams,
        payload: payload,
      );

      if (data['status'] == '200') {
        creativesMetaData.totalCount =
            WealthyCast.toInt(data["response"]["total"]) ?? 0;

        final creativesListJson = WealthyCast.toList(data["response"]["data"]);

        List.generate(
          creativesListJson.length,
          (index) {
            final creativeModel =
                CreativeNewModel.fromJson(creativesListJson[index]);
            if (creativeModel.url.isNotNullOrEmpty) {
              creativesList.add(creativeModel);
            }
          },
        );

        if (!isEmpanelmentDone) {
          // Add remaining hardcoded creatives with blur=true to reach total of 400 for unemp users
          int currentCount = creativesList.length;
          int remainingCount = 400 - currentCount;

          if (remainingCount > 0) {
            creativesList.addAll(List.generate(
              remainingCount,
              (index) => CreativeNewModel(
                url: "Blur.Creative${index + 1}",
                title: 'Exclusive Poster',
                description:
                    'Empanel with us to access 300+ posters in 9 languages.',
                blur: true,
                type: "img",
              ),
            ));
          }

          creativesMetaData.totalCount = 400;
        }

        creativesResponse.state = NetworkState.loaded;
      } else {
        creativesResponse.state = NetworkState.error;
      }
    } catch (error) {
      creativesResponse.state = NetworkState.error;
    } finally {
      isCreativesPaginating = false;
      update();
    }
  }

  bool hasMorePages() {
    if (isMarketingKitSelected) {
      return (creativesMetaData.totalCount ?? 0) >
          (creativesMetaData.limit) * ((creativesMetaData.page) + 1);
    } else {
      return (resourceMetaData.totalCount ?? 0) >
          (resourceMetaData.limit) * ((resourceMetaData.page) + 1);
    }
  }

  void handlePagination() {
    if (scrollController.hasClients) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;

      if (isScrolledToBottom) {
        loadNextPage();
      }
    }
  }

  // Triggers pagination if there are more pages available.
  // Called by NotificationListener in ResourcesList when scrolled to bottom.
  void loadNextPage() {
    final isPagesRemaining = hasMorePages();

    if (isPagesRemaining && apiResponse.state != NetworkState.loading) {
      if (isMarketingKitSelected) {
        isCreativesPaginating = true;
        creativesMetaData.page += 1;
        getCreatives();
      } else {
        isResourcesPaginating = true;
        resourceMetaData.page += 1;
        getResources();
      }
    }
  }

  void handleHorizScrollPagination() {
    ItemPosition lastItem =
        creativesHorizPositionsListener.itemPositions.value.last;
    bool isScrolledToEnd = lastItem.index == (creativesList.length - 1);
    if (isScrolledToEnd) {
      final isPagesRemaining = hasMorePages();

      if (isScrolledToEnd &&
              isPagesRemaining &&
              apiResponse.state != NetworkState.loading
          // && whiteLabelResponse.state != NetworkState.loading
          ) {
        if (isMarketingKitSelected) {
          isCreativesPaginating = true;
          creativesMetaData.page += 1;
          getCreatives();
        } else {
          isResourcesPaginating = true;
          resourceMetaData.page += 1;
          getResources();
        }
      }
    }
  }

  Future<void> getRecentlyAdded() async {
    recentlyAddedList.clear();
    recentlyAddedResponse.state = NetworkState.loading;
    update();

    try {
      bool isEmpanelmentDone = true;

      // Wait until advisorOverviewState is loaded or error for deeplink / push notification case
      while (homeController.advisorOverviewState != NetworkState.loaded &&
          homeController.advisorOverviewState != NetworkState.error) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (homeController.advisorOverviewState == NetworkState.loaded) {
        isEmpanelmentDone =
            homeController.isKycDone && homeController.isEmpanelmentCompleted;
      }

      final apiKey = await getApiKey() ?? '';
      List<String> creativeTags = [getSelectedLanguageTag() ?? ''];

      if (!isEmpanelmentDone) {
        creativeTags.add(unempanelledTag.tag ?? '');
      }

      // Prepare payloads for parallel API calls
      final creativesPayload = {"tenant": "pgallery", "tags": creativeTags};
      final creativesQueryParams =
          '?limit=7&offset=0&order_by=-created_at&filetype=img';

      final resourcesPayload = {
        "tenant": "partner_downloads",
        "tags": [getSelectedLanguageTag(isSalesKit: true) ?? '']
      };
      final resourcesQueryParams = '?limit=7&offset=0&order_by=-updated_at';

      // Execute both API calls in parallel
      final results = await Future.wait([
        AppResourcesRepository().getResources(
          apiKey: apiKey,
          queryParams: creativesQueryParams,
          payload: creativesPayload,
        ),
        AppResourcesRepository().getResources(
          apiKey: apiKey,
          queryParams: resourcesQueryParams,
          payload: resourcesPayload,
        ),
      ]);

      final creativesData = results[0];
      final resourcesData = results[1];

      // Process and map creatives with createdAt dates
      final creativesWithDates = creativesData['status'] == '200'
          ? WealthyCast.toList(creativesData["response"]["data"])
              .map((json) => CreativeNewModel.fromJson(json))
              .where((model) => model.url.isNotNullOrEmpty)
              .map((model) => MapEntry(model, model.createdAt))
              .toList()
          : <MapEntry<CreativeNewModel, DateTime?>>[];

      // Process and map resources with updatedAt dates
      final resourcesWithDates = resourcesData['status'] == '200'
          ? WealthyCast.toList(resourcesData['response']?['data'])
              .map((json) => CreativeNewModel.fromJson(json))
              .where((model) => model.url.isNotNullOrEmpty)
              .map((model) => MapEntry(model, model.updatedAt))
              .toList()
          : <MapEntry<CreativeNewModel, DateTime?>>[];

      // Combine, sort by date (most recent first), and take top 7
      final combinedWithDates = [...creativesWithDates, ...resourcesWithDates];
      combinedWithDates.sort((a, b) {
        if (a.value == null && b.value == null) return 0;
        if (a.value == null) return 1;
        if (b.value == null) return -1;
        return b.value!.compareTo(a.value!);
      });

      recentlyAddedList
          .addAll(combinedWithDates.take(7).map((entry) => entry.key));
      recentlyAddedResponse.state = NetworkState.loaded;
    } catch (error) {
      recentlyAddedResponse.state = NetworkState.error;
      recentlyAddedResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  // Filter and Sort methods
  void changeFilterMode(FilterMode mode) {
    currentFilterMode = mode;
    update();
  }

  void toggleTempCategory(TagModel category) {
    if (tempCategoriesSelected.contains(category)) {
      tempCategoriesSelected.remove(category);
    } else {
      tempCategoriesSelected.add(category);
    }
    update();
  }

  void updateTempSorting(dynamic sortOption) {
    tempSortSelected = sortOption;
    update();
  }

  void clearFilterAndSort() {
    tempCategoriesSelected.clear();
    selectedCategories.clear();
    tempSortSelected = null;
    sortSelected = null;
    getData();
  }

  void applyFilterAndSort() {
    // Apply categories filter - now supporting multiple categories
    selectedCategories.clear();
    if (tempCategoriesSelected.isNotEmpty) {
      selectedCategories.addAll(tempCategoriesSelected);
    }

    sortSelected = tempSortSelected;
    getData();
  }

  // White label creative methods
  void updateCurrentIndex(int newIndex) {
    currentIndex = newIndex;
    update();

    // Check if the list is empty or the index is out of bounds to prevent RangeError.
    // This can happen if the bottom sheet is opened before the data is fully loaded.
    if (activeList.isEmpty || currentIndex >= activeList.length) {
      return;
    }

    if (activeList[currentIndex].isImage) {
      getWhiteLabelCreative();
    } else if (activeList[currentIndex].isPdf) {
      getPdfResources();
    }

    EventTracker.trackResourcesViewed(resource: activeList[currentIndex]);
  }

  void setOnboardingLinkAutoCopied() {
    isOnboardingLinkAutoCopied = true;
    update();
  }

  void toggleShareWithOnboardingLink() {
    shareWithOnboardingLink = !shareWithOnboardingLink;
    update();
  }

  Future<void> getWhiteLabelCreative({String? url}) async {
    final targetList = activeList;

    if (targetList.isEmpty || currentIndex >= targetList.length) {
      return;
    }

    if (targetList[currentIndex].blur == true) {
      return;
    }

    whiteLabelFile = null;
    whiteLabelCreativeBytes = null;
    isOnboardingLinkAutoCopied = false;
    whiteLabelResponse.state = NetworkState.loading;
    update();

    CreativeNewModel creative = targetList[currentIndex];

    String creativeUrl;

    if (url.isNotNullOrEmpty) {
      creativeUrl = url!;
    } else {
      creativeUrl = creative.url!;
    }

    if (!creativeUrl.startsWith("http")) {
      creativeUrl = "https://$creativeUrl";
    }

    try {
      Map<String, dynamic> partnerDetails =
          await getPartnerWhiteLabelDetails(creativeUrl);

      String label = jsonToBase64(partnerDetails);

      String whiteLabelUrl = '$creativeUrl?label=$label';

      var data =
          await AppResourcesRepository().getWhiteLabelCreative(whiteLabelUrl);
      if (data['status'] == '200') {
        whiteLabelCreativeBytes = data["response"];

        final String originalFileName = creativeUrl.split("/").last;
        final String fileName = '${languageSelected?.tag}_$originalFileName';
        final Directory temp = await getTemporaryDirectory();

        final File imageFile = File('${temp.path}/$fileName');

        // Clear existing file
        if (imageFile.existsSync()) {
          imageFile.deleteSync();
        }

        imageFile.writeAsBytesSync(whiteLabelCreativeBytes!);

        whiteLabelFile = imageFile;
        isOnboardingLinkAutoCopied = true;
        // MixPanelAnalytics.trackWithAgentId(
        //   "poster_viewed",
        //   screen: 'resources',
        //   screenLocation: 'resources',
        //   properties: {"name": '${creative.name}_${languageSelected?.text}'},
        // );
        whiteLabelResponse.state = NetworkState.loaded;
      } else {
        whiteLabelResponse.state = NetworkState.error;
      }
    } catch (error) {
      whiteLabelResponse.state = NetworkState.error;
      LogUtil.printLog(
          'Error getting white label creative: ${error.toString()}');
    } finally {
      update();
    }
  }

  Future<void> getPdfResources({String? url}) async {
    final targetList = activeList;

    if (targetList.isEmpty || currentIndex >= targetList.length) {
      return;
    }

    pdfBytes = null;
    currentPdfPage = 0;
    totalPdfPages = 0;
    isOnboardingLinkAutoCopied = false;
    pdfViewController = null;
    pdfResponse.state = NetworkState.loading;
    brandedPdfBytes = null;
    update();

    CreativeNewModel creative = targetList[currentIndex];

    String creativeUrl;

    if (url.isNotNullOrEmpty) {
      creativeUrl = url!;
    } else {
      creativeUrl = creative.url!;
    }

    if (!creativeUrl.startsWith("http")) {
      creativeUrl = "https://$creativeUrl";
    }

    try {
      final response = await http.get(Uri.parse(creativeUrl));
      if (response.statusCode == 200) {
        pdfBytes = response.bodyBytes;

        final String originalFileName = creativeUrl.split("/").last;
        final Directory temp = await getTemporaryDirectory();
        final File file = File('${temp.path}/$originalFileName');

        if (file.existsSync()) {
          file.deleteSync();
        }

        file.writeAsBytesSync(pdfBytes!);
        pdfFile = file;

        pdfResponse.state = NetworkState.loaded;
      } else {
        pdfResponse.state = NetworkState.error;
      }
    } catch (error) {
      pdfResponse.state = NetworkState.error;
      LogUtil.printLog('Error getting PDF: ${error.toString()}');
    } finally {
      update();
    }
  }

  Future<Map<String, dynamic>> getPartnerWhiteLabelDetails(
      String creativeUrl) async {
    AdvisorOverviewModel? advisorOverviewModel =
        homeController.advisorOverviewModel;

    if (advisorOverviewModel?.agent == null) {
      await homeController.getAdvisorOverview();
      advisorOverviewModel = homeController.advisorOverviewModel;
    }

    if (advisorOverviewModel?.agent == null) {
      return {};
    }

    return {
      "Name": advisorOverviewModel?.agent?.displayName ?? '',
      "PhoneNumber": advisorOverviewModel?.agent?.phoneNumber ?? '',
      "Description": "",
      "templateName": "agent_white_label",
      "ImageUrl": creativeUrl,
      "ARN": advisorOverviewModel?.partnerArn?.arn ?? '',
      "Email": advisorOverviewModel?.agent?.email ?? '',
      'PartnerImageUrl': branding?.profilePictureUrl ?? '',
      'LogoUrl': branding?.brandingLogoUrl ?? '',
      'BrandName': branding?.brandName ?? '',
      'Tagline': branding?.tagLine ?? '',
    };
  }

  void updateCurrentPdfPage(int newPage) {
    if (newPage >= 0 && newPage < totalPdfPages) {
      currentPdfPage = newPage;
      pdfViewController?.setPage(newPage);
      update();
    }
  }

  void onPdfViewCreated(PDFViewController controller) async {
    pdfViewController = controller;
    totalPdfPages = await controller.getPageCount() ?? 0;
    update();
  }

  void onPdfPageChanged(int page, int total) {
    currentPdfPage = page;
    totalPdfPages = total;
    update();
  }

  void moveToNextCreative() {
    final targetList = isMarketingKitSelected ? creativesList : resources;

    if (whiteLabelResponse.state == NetworkState.loading ||
        targetList.length <= 1) {
      return;
    }

    int newIndex;
    if ((currentIndex + 1) >= targetList.length) {
      newIndex = 0;
    } else {
      newIndex = currentIndex + 1;
    }

    updateCurrentIndex(newIndex);
  }

  void moveToPrevCreative() {
    final targetList = isMarketingKitSelected ? creativesList : resources;

    if (whiteLabelResponse.state == NetworkState.loading ||
        targetList.length <= 1) {
      return;
    }

    int newIndex;
    if ((currentIndex - 1) < 0) {
      newIndex = targetList.length - 1;
    } else {
      newIndex = currentIndex - 1;
    }

    updateCurrentIndex(newIndex);
  }

  /// Adds branding to the current PDF using the branding logo
  /// [pdfUrl] - PDF URL to brand
  Future<void> addBrandingToPdf({required String pdfUrl}) async {
    pdfBrandingResponse.state = NetworkState.loading;
    update();

    try {
      // Check if branding data is available
      if (branding == null || branding!.brandingLogoUrl.isNullOrEmpty) {
        LogUtil.printLog('Branding logo URL is not available');
        pdfBrandingResponse.state = NetworkState.error;
        pdfBrandingResponse.message = 'Branding logo URL is not available';
        update();
        return;
      }

      // Validate PDF URL
      if (pdfUrl.isEmpty) {
        LogUtil.printLog('PDF URL is empty');
        pdfBrandingResponse.state = NetworkState.error;
        pdfBrandingResponse.message = 'PDF URL is empty';
        update();
        return;
      }

      String targetPdfUrl = pdfUrl;
      if (!targetPdfUrl.startsWith("http")) {
        targetPdfUrl = "https://$targetPdfUrl";
      }

      // Fetch the logo image from URL and convert to base64
      String logoUrl = branding!.brandingLogoUrl!;
      if (!logoUrl.startsWith("http")) {
        logoUrl = "https://$logoUrl";
      }

      final logoResponse = await http.get(Uri.parse(logoUrl));
      if (logoResponse.statusCode != 200) {
        LogUtil.printLog(
            'Failed to fetch logo image: ${logoResponse.statusCode}');
        pdfBrandingResponse.state = NetworkState.error;
        pdfBrandingResponse.message = 'Failed to fetch logo image';
        update();
        return;
      }

      // Convert logo bytes to base64
      final logoBytes = logoResponse.bodyBytes;
      final logoBase64 = base64Encode(logoBytes);

      // Call the API to add branding
      final response = await AppResourcesRepository().addPdfBranding(
        pdfUrl: targetPdfUrl,
        logoBase64: logoBase64,
      );

      if (response != null && response['status'] == '200') {
        // Save branded PDF bytes to file
        pdfBrandingResponse.message = 'Branding added successfully';
        pdfBrandingResponse.state = NetworkState.loaded;
        brandedPdfBytes = response['response'];
      } else {
        pdfBrandingResponse.state = NetworkState.error;
        pdfBrandingResponse.message =
            response?['message'] ?? genericErrorMessage;
      }
    } catch (error) {
      LogUtil.printLog('Error adding branding to PDF: ${error.toString()}');
      pdfBrandingResponse.state = NetworkState.error;
      pdfBrandingResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }
}

class TagModel {
  String? text;
  String? tag;
  String? imagePath;

  TagModel({
    this.text,
    this.tag,
    this.imagePath,
  });

  TagModel.fromJson(Map<String, dynamic> json) {
    text = WealthyCast.toStr(json["text"]);
    tag = WealthyCast.toStr(json["tag"]);

    // Set imagePath based on category tag
    switch (tag) {
      case "tag_4RuzqcLCq2v": // Insurance
        imagePath = AllImages().posterInsuranceIcon;
        break;
      case "tag_3RHd3qnMwNE": // AIF & PMS
        imagePath = AllImages().posterAifPmsIcon;
        break;
      case "tag_WN4PpwH9iiC": // Festivals
        imagePath = AllImages().posterFestivalIcon;
        break;
      case "tag_37uwhfwaUxn": // FD
        imagePath = AllImages().posterFdIcon;
        break;
      case "tag_i9PhiyHSn9w": // Tax Saving
        imagePath = AllImages().posterTaxSavingIcon;
        break;
      case "tag_wWgbjfMmaNU": // Bonds & Debentures
        imagePath = AllImages().posterBondDebentureIcon;
        break;
      case "tag_VVvkKFo422J": // Retirement
        imagePath = AllImages().posterRetirementIcon;
        break;
      case "tag_3RqFQPvqEvM": // Mutual Funds
        imagePath = AllImages().posterMfIcon;
        break;
      case "tag_3RKFbBtxUPk": // SIP
        imagePath = AllImages().posterSipIcon;
        break;
      case "tag_kwiuP3mZZ4j": // NRI
        imagePath = AllImages().posterNriIcon;
        break;
      case "tag_3NRhwtsSn9K": // Wishes
        imagePath = AllImages().posterWishesIcon;
        break;
      case "tag_WAS4k4RtWQ5": // NFOs
        imagePath = AllImages().posterNfoIcon;
        break;
      case "tag_39M8pMj8JtF": // IPOs
        imagePath = AllImages().posterIpoIcon;
        break;
      case "all": // All
        imagePath = AllImages().posterAllIcon;
        break;
      default:
        imagePath = null;
        break;
    }
  }
}
