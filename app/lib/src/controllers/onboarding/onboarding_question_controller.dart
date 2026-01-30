import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/firebase/firebase_event_service.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/main.dart';
import 'package:core/modules/authentication/models/onboarding_question_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class OnboardingQuestionController extends GetxController {
  OnboardingQuestionMetaModel? meta;
  List<OnboardingQuestionModel>? currentOnboardingQuestions;
  List<OnboardingQuestionModel>? onboardingQuestions;
  List<String?>? cities;

  TextEditingController citySearchController = TextEditingController();
  SuggestionsController citySuggestionController = SuggestionsController();

  Map<String?, OnboardingQnaFormModel> questionAnswers = {};
  Map<String, dynamic> onboardingAnswers = {};

  ApiResponse submitQuestionResponse = ApiResponse();
  NetworkState fetchQuestionState = NetworkState.cancel;
  NetworkState skipQuestionState = NetworkState.cancel;

  bool isCityQuestionInFocus = false;

  bool get isFinalQuestion {
    return meta?.next?.isNullOrEmpty ?? true;
  }

  bool get isAllQuestionsAnswered {
    bool isQuestionsAnswered = false;
    if (onboardingQuestions == null) return false;
    for (OnboardingQuestionModel question in onboardingQuestions!) {
      OnboardingQnaFormModel? answer = questionAnswers[question.externalId];
      if (question.optional ?? false) {
        isQuestionsAnswered = true;
        continue;
      }

      if (answer == null) {
        isQuestionsAnswered = false;
        break;
      }

      if (question.isCustomQuestion) {
        isQuestionsAnswered = answer.customAnswer.isNotNullOrEmpty;
      } else {
        isQuestionsAnswered = answer.selectedOptions.isNotEmpty;
      }

      if (isQuestionsAnswered == false) {
        break;
      }
    }

    return isQuestionsAnswered;
  }

  void onInit() {
    getOnboardingQuestions();

    citySuggestionController.addListener(() {
      bool isCityFirstQuestion = (onboardingQuestions ?? []).isNotEmpty &&
          onboardingQuestions!.first.question?.qtype == "city";
      if (!isCityFirstQuestion) {
        onCityQuestionFocus(citySuggestionController.isOpen);
      }
    });

    super.onInit();
  }

  Future<void> getOnboardingQuestions({String? stageId}) async {
    fetchQuestionState = NetworkState.loading;
    questionAnswers.clear();
    onboardingQuestions?.clear();
    update();

    try {
      String apiKey = (await getApiKey())!;
      var data = await AuthenticationRepository()
          .getOnboardingQuestionsv2(apiKey, stageId: stageId);

      if (data['status'] == '200') {
        OnboardingQuestionOverviewModel onboardingQuestionsList =
            OnboardingQuestionOverviewModel.fromJson(data['response']);
        onboardingQuestions = onboardingQuestionsList.questions;
        meta = onboardingQuestionsList.meta;

        bool isCityQuestionPresent = false;

        if (onboardingQuestions.isNotNullOrEmpty) {
          onboardingQuestions!.forEach(
            (OnboardingQuestionModel questionOverview) {
              if (questionOverview.isCustomQuestion) {
                questionAnswers[questionOverview.externalId] =
                    OnboardingQnaFormModel(
                        qnaStage: questionOverview.externalId,
                        customAnswer: questionOverview.customAnswer);
                if (questionOverview.question?.qtype == "city") {
                  isCityQuestionPresent = true;
                  citySearchController.text =
                      questionOverview.customAnswer ?? '';
                }
              } else if (questionOverview.selectedOptions.isNotNullOrEmpty) {
                questionAnswers[questionOverview.externalId] =
                    OnboardingQnaFormModel(
                  selectedOptions: List<OnboardingAnswerModel>.from(
                    questionOverview.selectedOptions ?? [],
                  ),
                );
              }
            },
          );
        }

        if (isCityQuestionPresent && cities.isNullOrEmpty) {
          await getCities();
        }

        // if (isFinalQuestion) {
        //   await getOnboardingAnswers();
        // }

        fetchQuestionState = NetworkState.loaded;
      } else {
        fetchQuestionState = NetworkState.error;
      }
    } catch (error) {
      fetchQuestionState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getOnboardingAnswers() async {
    try {
      String apiKey = (await getApiKey())!;
      var data =
          await AuthenticationRepository().getOnboardingAnswersv2(apiKey);

      if (data['status'] == '200' && data['response'] != null) {
        onboardingAnswers = data['response'];
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      update();
    }
  }

  Future<void> getCities() async {
    try {
      String apiKey = (await getApiKey())!;
      var data = await AuthenticationRepository().getCities(apiKey);
      if (data['status'] == '200') {
        cities = List<String?>.from(data['response']['cities']);
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      update();
    }
  }

  Future<void> submitOnboardingAnswer() async {
    submitQuestionResponse.state = NetworkState.loading;
    update();

    try {
      String apiKey = await getApiKey() ?? '';

      List<Map<String, dynamic>> answers = [];
      questionAnswers.forEach((key, OnboardingQnaFormModel value) {
        answers.add({
          "qna_stage": key,
          if (value.customAnswer.isNotNullOrEmpty)
            "custom_answer": value.customAnswer
          else
            "selected_options":
                value.selectedOptions.map((e) => e.externalId).toList()
        });
      });

      Map<String, dynamic> payload = {"answers": answers};

      var data = await AuthenticationRepository()
          .submitOnboardingAnswerv2(apiKey, payload);
      if (data['status'] == '200' || data['status'] == '201') {
        if (isFinalQuestion) {
          await getOnboardingAnswers();
          triggerFirebaseEvent();
        }

        submitQuestionResponse.state = NetworkState.loaded;

        questionAnswers.clear();
      } else {
        submitQuestionResponse.state = NetworkState.error;
        submitQuestionResponse.message =
            getErrorMessageFromResponse(data["response"]);
      }
    } catch (error) {
      submitQuestionResponse.state = NetworkState.error;
      submitQuestionResponse.message = "Something went wrong. Please try again";
    } finally {
      update();
    }
  }

  void updateOnboardingAnswer(
      OnboardingQuestionModel onboardingQuestion, String answer) {
    if (onboardingQuestion.isCustomQuestion) {
      questionAnswers[onboardingQuestion.externalId] = OnboardingQnaFormModel(
        qnaStage: onboardingQuestion.externalId,
        customAnswer: answer,
      );
    } else {
      OnboardingAnswerModel? selectedOption;
      for (OnboardingAnswerModel option in onboardingQuestion.options!) {
        if (option.answer == answer) {
          selectedOption = option;
          break;
        }
      }

      if (selectedOption != null) {
        List<OnboardingAnswerModel> selectedOptions = [];

        bool isOptionAlreadySelected = false;

        if (onboardingQuestion.multiSelect ?? false) {
          selectedOptions =
              questionAnswers[onboardingQuestion.externalId]?.selectedOptions ??
                  [];

          for (OnboardingAnswerModel option in selectedOptions) {
            if (option.externalId == selectedOption.externalId) {
              isOptionAlreadySelected = true;
              break;
            }
          }
        }

        if (isOptionAlreadySelected) {
          selectedOptions
              .removeWhere((e) => selectedOption?.externalId == e.externalId);
        } else {
          selectedOptions.add(selectedOption);
        }

        questionAnswers[onboardingQuestion.externalId] = OnboardingQnaFormModel(
            qnaStage: onboardingQuestion.externalId,
            selectedOptions: selectedOptions);
      }
    }

    update();
  }

  void updateCustomAnswer(
      OnboardingQuestionModel onboardingQuestion, String answer) {
    questionAnswers[onboardingQuestion.externalId] = OnboardingQnaFormModel(
      qnaStage: onboardingQuestion.externalId,
      customAnswer: answer,
    );
  }

  void onCityQuestionFocus(isVisible) {
    isCityQuestionInFocus = isVisible;
    update();
  }

  List<String?> searchCity(String pattern) {
    if (cities.isNotNullOrEmpty) {
      List<String?> citiesFound = cities!.where((element) {
        if (element.isNotNullOrEmpty) {
          return element!.toLowerCase().contains(pattern.toLowerCase());
        }

        return false;
      }).toList();

      return citiesFound;
    }

    return [];
  }

  void triggerFirebaseEvent() {
    LogUtil.printLog(
        'triggerFirebaseEvent called with answers: $onboardingAnswers');
    try {
      final isAmfiRegistered =
          onboardingAnswers?['amfi-arn-holder'].toString().toLowerCase() ==
                  'yes' &&
              onboardingAnswers?['valid_arn'] == true;
      if (isAmfiRegistered) {
        FirebaseEventService.logEvent('WL_Resp_Valid_Prof_ARN');
      }

      final profession = onboardingAnswers?['profession_industry']?.toString();
      final isProfession = profession.isNotNullOrEmpty;

      if (isProfession) {
        FirebaseEventService.logEvent(
          'WL_Resp_Valid_Fin_Lead',
          parameters: {'Profession': profession!},
        );

        final professionLower = profession.toLowerCase();

        final isBanker = professionLower == 'banker';
        if (isBanker) {
          FirebaseEventService.logEvent('WL_Resp_Valid_Prof_BNK');
        }

        final isInsurance = professionLower == 'insurance';
        if (isInsurance) {
          FirebaseEventService.logEvent('WL_Resp_Valid_Prof_INS');
        }

        final isCFA = professionLower.contains('cfa');

        if (isCFA) {
          FirebaseEventService.logEvent('WL_Resp_Valid_Prof_CFA');
        }
      }
    } catch (e) {
      LogUtil.printLog('Error logging firebase event: $e');
    }
  }
}

class OnboardingQnaFormModel {
  String? qnaStage;
  String? customAnswer;
  List<OnboardingAnswerModel> selectedOptions;

  OnboardingQnaFormModel({
    this.qnaStage,
    this.customAnswer,
    this.selectedOptions = const [],
  });

  // OnboardingAnswerModel.fromJson(Map<String, dynamic> json) {
  //   qnaStage = WealthyCast.toStr(json['qna_stage']);
  //   answer = WealthyCast.toStr(json['custom_answer']);
  //   answerText = WealthyCast.toStr(json['answer_text']);
  //   customAnswer = WealthyCast.toStr(json['custom_answer']);
  // }
}
