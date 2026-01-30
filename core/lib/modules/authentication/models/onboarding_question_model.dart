import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class OnboardingQuestionOverviewModel {
  OnboardingQuestionMetaModel? meta;
  List<OnboardingQuestionModel>? questions;

  OnboardingQuestionOverviewModel({this.meta, this.questions});

  OnboardingQuestionOverviewModel.fromJson(Map<String, dynamic> json) {
    meta = OnboardingQuestionMetaModel.fromJson(json['meta']);
    questions = List<OnboardingQuestionModel>.from(
      WealthyCast.toList(json["questions"])
          .map((x) => OnboardingQuestionModel.fromJson(x)),
    );
  }
}

class OnboardingQuestionMetaModel {
  String? externalId;
  int? level;
  String? qnaType;
  List<String>? next;
  String? prev;
  String? title;
  String? subtitle;

  OnboardingQuestionMetaModel({
    this.externalId,
    this.level,
    this.qnaType,
    this.next,
    this.title,
    this.subtitle,
  });

  OnboardingQuestionMetaModel.fromJson(Map<String, dynamic> json) {
    externalId = WealthyCast.toStr(json['external_id']);
    level = WealthyCast.toInt(json['level']);
    title = WealthyCast.toStr(json['title']);
    subtitle = WealthyCast.toStr(json['sub_title']);
    prev = WealthyCast.toStr(json['prev']);
    qnaType = WealthyCast.toStr(json['qna_type']);
    next = List<String>.from(WealthyCast.toList(json["next"]));
  }
}

class OnboardingQuestionModel {
  String? externalId;
  OnboardingQuestionDetailModel? question;
  List<OnboardingAnswerModel>? options;
  bool? multiSelect;
  List<OnboardingAnswerModel>? selectedOptions;
  String? customAnswer;
  bool? optional;

  OnboardingQuestionModel({
    this.externalId,
    this.question,
    this.options,
    this.selectedOptions,
    this.customAnswer,
    this.multiSelect,
    this.optional,
  });

  bool get isCustomQuestion => options.isNullOrEmpty;

  OnboardingQuestionModel.fromJson(Map<String, dynamic> json) {
    externalId = WealthyCast.toStr(json['external_id']);
    question = OnboardingQuestionDetailModel.fromJson(json['question']);
    selectedOptions = List<OnboardingAnswerModel>.from(
      WealthyCast.toList(json["selected_options"])
          .map((x) => OnboardingAnswerModel.fromJson(x)),
    );
    options = List<OnboardingAnswerModel>.from(
        WealthyCast.toList(json["options"])
            .map((x) => OnboardingAnswerModel.fromJson(x)));
    customAnswer = WealthyCast.toStr(json["custom_answer"]);
    multiSelect = WealthyCast.toBool(json["multi_select"]);
    optional = WealthyCast.toBool(json["optional"]);
  }
}

// class OnboardingQuestionOptionModel {
//   String? externalId;
//   String? answer;

//   OnboardingQuestionOptionModel({this.externalId, this.answer});

//   OnboardingQuestionOptionModel.fromJson(Map<String, dynamic> json) {
//     externalId = WealthyCast.toStr(json['external_id']);
//     answer = WealthyCast.toStr(json['answer']);
//   }
// }

class OnboardingQuestionDetailModel {
  String? externalId;
  String? title;
  String? placeholder;
  String? qtype;

  OnboardingQuestionDetailModel({this.title, this.placeholder, this.qtype});

  OnboardingQuestionDetailModel.fromJson(Map<String, dynamic> json) {
    externalId = WealthyCast.toStr(json['external_id']);
    title = WealthyCast.toStr(json['title']);
    placeholder = WealthyCast.toStr(json['placeholder']);
    qtype = WealthyCast.toStr(json['qtype']);
  }
}

class OnboardingAnswerModel {
  String? externalId;
  String? answer;
  String? answerText;
  String? customAnswer;

  OnboardingAnswerModel(
      {this.externalId, this.answer, this.answerText, this.customAnswer});

  OnboardingAnswerModel.fromJson(Map<String, dynamic> json) {
    externalId = WealthyCast.toStr(json['external_id']);
    answer = WealthyCast.toStr(json['answer']);
    answerText = WealthyCast.toStr(json['answer_text']);
    customAnswer = WealthyCast.toStr(json['custom_answer']);
  }
}
