import 'dart:math';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/advisor/models/newsletter_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewsLetterController extends GetxController {
  String selectedTab = "Money Order";

  ApiResponse newsLetterReponse = ApiResponse();
  List<NewsLetterModel> newsLetterList = [];

  ApiResponse newsLetterYearsReponse = ApiResponse();

  ScrollController scrollController = ScrollController();
  MetaDataModel newsLetterMetaData = MetaDataModel();
  bool isPaginating = false;

  NewsLetterModel? selectedNewsLetter;
  ApiResponse newsLetterDetailReponse = ApiResponse();

  Map<String, List<int>> newsletterYears = {};

  ApiResponse newsLetterSubscribeReponse = ApiResponse();

  TabController? tabController;
  TextEditingController emailInputController = TextEditingController();
  ScrollController articleScrollControler = ScrollController();
  double articleScrollPercent = 0;
  int selectedYear = DateTime.now().year;

  CancelToken? cancelToken;

  NewsLetterController({int initialTabIndex = 0}) {
    selectedTab = newsLetterTabs[initialTabIndex]['title']!;
  }

  @override
  void onInit() async {
    super.onInit();
    scrollController.addListener(handlePagination);
    articleScrollControler.addListener(handleArticleScroll);
    getNewsletters();
    getNewsletterYears();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  Future<void> getNewsletters() async {
    try {
      if (cancelToken != null) {
        cancelToken!.cancel();
      }
      cancelToken = CancelToken();

      if (!isPaginating) {
        newsLetterList.clear();
        newsLetterMetaData = MetaDataModel();
      }
      newsLetterReponse.state = NetworkState.loading;
      update();

      final apiKey = await getApiKey();

      final data = await AdvisorRepository().getNewsletters(
        apiKey ?? '',
        getQueryParam(),
        cancelToken: cancelToken,
      );

      final bool isRequestCancelled = data?['isRequestCancelled'] ?? false;
      if (isRequestCancelled) return;

      if (data['status'] == '200') {
        newsLetterMetaData.totalCount =
            WealthyCast.toInt(data['response']['meta']['total_count']) ?? 0;
        WealthyCast.toList(data['response']['results'])
            .forEach((newsLetterJson) {
          newsLetterList.add(NewsLetterModel.fromJson(newsLetterJson));
        });

        newsLetterReponse.state = NetworkState.loaded;
      } else {
        newsLetterReponse.message =
            getErrorMessageFromResponse(data['response']);
        newsLetterReponse.state = NetworkState.error;
      }
    } catch (e) {
      newsLetterReponse.message = genericErrorMessage;
      newsLetterReponse.state = NetworkState.error;
    } finally {
      isPaginating = false;
      update();
    }
  }

  Future<void> getNewsletterDetail(String selectedNewsLetterId) async {
    try {
      newsLetterDetailReponse.state = NetworkState.loading;
      update();

      final apiKey = await getApiKey();

      final data = await AdvisorRepository()
          .getNewsletterDetail(apiKey ?? '', selectedNewsLetterId);

      if (data['status'] == '200') {
        selectedNewsLetter = NewsLetterModel.fromJson(data['response']);
        newsLetterDetailReponse.state = NetworkState.loaded;
      } else {
        newsLetterDetailReponse.message =
            getErrorMessageFromResponse(data['response']);
        newsLetterDetailReponse.state = NetworkState.error;
      }
    } catch (e) {
      newsLetterDetailReponse.message = genericErrorMessage;
      newsLetterDetailReponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getNewsletterYears() async {
    try {
      newsLetterYearsReponse.state = NetworkState.loading;
      update();

      final apiKey = await getApiKey();

      final responses = await Future.wait(
        [
          AdvisorRepository()
              .getNewsletterYears(apiKey ?? '', '?content_type=money-order'),
          AdvisorRepository()
              .getNewsletterYears(apiKey ?? '', '?content_type=bulls-eye'),
        ],
      );

      if (responses.any((response) => response['status'] != '200')) {
        newsLetterYearsReponse.message = getErrorMessageFromResponse(responses
            .firstWhere((response) => response['status'] != '200')['response']);
        newsLetterYearsReponse.state = NetworkState.error;
      } else {
        newsletterYears = {
          'Money Order': WealthyCast.toList(responses[0]['response'])
              .map((year) => WealthyCast.toInt(year)!)
              .toList(),
          "Bull’s Eye": WealthyCast.toList(responses[1]['response'])
              .map((year) => WealthyCast.toInt(year)!)
              .toList(),
        };

        selectedYear =
            newsletterYears[selectedTab]?.first ?? DateTime.now().year;
        newsLetterYearsReponse.state = NetworkState.loaded;
      }
    } catch (e) {
      newsLetterYearsReponse.message = genericErrorMessage;
      newsLetterYearsReponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> subscribeNewsletter() async {
    try {
      newsLetterSubscribeReponse.state = NetworkState.loading;
      update(['subscribe-newsletter']);

      final apiKey = await getApiKey();
      // final siteKey = '6LejnMwkAAAAAFIscgPalTmOwzBijusBTLw8iask';
      // final token = await Grecaptcha().verifyWithRecaptcha(siteKey);

      final payload = {
        'email': emailInputController.text,
        // 'token': token,
      };
      final data =
          await AdvisorRepository().subscribeNewsletter(apiKey ?? '', payload);

      if (data['status'] == '200') {
        newsLetterSubscribeReponse.message =
            WealthyCast.toStr(data['response']['message']) ?? '';
        newsLetterSubscribeReponse.state = NetworkState.loaded;
      } else {
        newsLetterSubscribeReponse.message =
            getErrorMessageFromResponse(data['response']);
        newsLetterSubscribeReponse.state = NetworkState.error;
      }
    } catch (e) {
      newsLetterSubscribeReponse.message = genericErrorMessage;
      newsLetterSubscribeReponse.state = NetworkState.error;
    } finally {
      update(['subscribe-newsletter']);
    }
  }

  String getQueryParam() {
    String queryParam = '?';
    if (selectedTab == "Money Order") {
      queryParam += 'content_type=money-order';
    } else {
      queryParam += 'content_type=bulls-eye';
    }
    queryParam += '&is_published=True';
    queryParam += '&chronological_date=$selectedYear';
    queryParam += '&ordering=-chronological_date';
    queryParam += '&limit=${newsLetterMetaData.limit}';
    queryParam +=
        '&offset=${newsLetterMetaData.page * newsLetterMetaData.limit}';
    return queryParam;
  }

  void handlePagination() {
    if (scrollController.hasClients) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;
      final isPagesRemaining = ((newsLetterMetaData.totalCount ?? 0) /
              (newsLetterMetaData.limit * (newsLetterMetaData.page + 1))) >
          1;

      if (isScrolledToBottom && isPagesRemaining && !isPaginating) {
        newsLetterMetaData.page = newsLetterMetaData.page + 1;
        isPaginating = true;
        update();
        getNewsletters();
      }
    }
  }

  void handleArticleScroll() {
    if (articleScrollControler.hasClients) {
      articleScrollPercent = max(
          articleScrollControler.position.pixels /
              articleScrollControler.position.maxScrollExtent,
          0);
      update(['article-read']);
    }
  }

  void onTabUpdate(String tab) {
    selectedTab = tab;
    selectedYear = newsletterYears[selectedTab]?.first ?? DateTime.now().year;
    getNewsletters();
  }
}
