class WealthyAIScreenParameters {
  String assistantKey;
  List<String> quickActions;
  String? initialQuestion;

  WealthyAIScreenParameters({
    required this.assistantKey,
    required this.quickActions,
    this.initialQuestion,
  });

  factory WealthyAIScreenParameters.fromJson(Map<String, dynamic> json) {
    return WealthyAIScreenParameters(
      assistantKey: json['assistant_key'],
      quickActions: json['quickActions'] != null && json['quickActions'] is List
          ? (json['quickActions'] as List).map((e) => e as String).toList()
          : [],
      initialQuestion: json['initialQuestion'],
    );
  }
}

class WidgetList {
  bool? widget;
  String? widgetType;
  String? widgetSubType;
  int? priority;
  dynamic detail;

  WidgetList(
      {this.widget,
      this.widgetType,
      this.widgetSubType,
      this.priority,
      this.detail});

  factory WidgetList.fromJson(Map<String, dynamic> json) {
    return WidgetList(
      widget: json['widget'],
      widgetType: json['widgetType'],
      widgetSubType: json['widgetSubType'],
      priority: json['priority'],
      detail: json['detail'],
    );
  }
}

class ContentJson {
  List<WidgetList>? widgetList;
  String? systemContent;

  ContentJson({this.widgetList, this.systemContent});

  factory ContentJson.fromJson(Map<String, dynamic> json) {
    return ContentJson(
      widgetList: json['widget_list'] != null && json['widget_list'] is List
          ? (json['widget_list'] as List)
              .map((e) => WidgetList.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      systemContent: json['system_content'],
    );
  }
}

class MessageMetadata {
  List<dynamic>? media;
  String? resourceId;
  String? source;
  List<String>? suggestedQuestions;
  String? title;
  double? score;

  MessageMetadata(
      {this.media,
      this.resourceId,
      this.source,
      this.suggestedQuestions,
      this.title,
      this.score});

  factory MessageMetadata.fromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      media: json['media'],
      resourceId: json['resource_id'],
      source: json['source'],
      suggestedQuestions: json['suggested_questions'] != null &&
              json['suggested_questions'] is List
          ? (json['suggested_questions'] as List)
              .map((e) => e as String)
              .toList()
          : null,
      title: json['title'],
      score: json['score'],
    );
  }
}

class WealthAIApiResponse {
  String? threadId;
  String? createdAt;
  String? content;
  String? widget;
  String? messageFlag;
  String? id;
  String? tenantId;
  String? role;
  String? runId;
  List<MessageMetadata>? messageMetadata;
  ContentJson? contentJson;
  String? modifiedAt;
  dynamic documents;

  WealthAIApiResponse({
    this.threadId,
    this.createdAt,
    this.content,
    this.widget,
    this.messageFlag,
    this.id,
    this.tenantId,
    this.role,
    this.runId,
    this.messageMetadata,
    this.contentJson,
    this.modifiedAt,
    this.documents,
  });

  factory WealthAIApiResponse.fromJson(Map<String, dynamic> json) {
    return WealthAIApiResponse(
      threadId: json['thread_id'],
      createdAt: json['created_at'],
      content: json['content'],
      widget: json['widget'],
      messageFlag: json['message_flag'],
      id: json['id'],
      tenantId: json['tenant_id'],
      role: json['role'],
      runId: json['run_id'],
      messageMetadata: json['message_metadata'] != null &&
              json['message_metadata'] is List
          ? (json['message_metadata'] as List)
              .map((e) => MessageMetadata.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      contentJson: json['content_json'] != null
          ? ContentJson.fromJson(json['content_json'])
          : null,
      modifiedAt: json['modified_at'],
      documents: json['documents'],
    );
  }
}

class WealthyAiProfileModel {
  String? assistantKey;
  String? accessToken;
  String? threadId;
  int? expiresAt;
  List<String>? suggestedQuestions = [];
  bool? isTemporary = false;

  WealthyAiProfileModel(
      {this.assistantKey,
      this.accessToken,
      this.threadId,
      this.expiresAt,
      this.suggestedQuestions,
      this.isTemporary});

  // Convert a single JSON object to a model
  factory WealthyAiProfileModel.fromJson(Map<String, dynamic> json) {
    return WealthyAiProfileModel(
      assistantKey: json['assistantKey'],
      accessToken: json['accessToken'],
      threadId: json['threadId'],
      expiresAt: json['expiresAt'],
      suggestedQuestions: json['suggestedQuestions'] != null &&
              json['suggestedQuestions'] is List
          ? (json['suggestedQuestions'] as List)
              .map((e) => e as String)
              .toList()
          : [],
      isTemporary: json['isTemporary'],
    );
  }

  // Static method to convert a list of JSON objects to a list of models
  static List<WealthyAiProfileModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => WealthyAiProfileModel.fromJson(json))
        .toList();
  }
}
