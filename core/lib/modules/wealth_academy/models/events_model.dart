import 'package:api_sdk/log_util.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class EventScheduleModel {
  List<EventModel>? upcomingEvents;
  String? name;
  String? language;
  String? description;
  int? duration;
  DateTime? startsAt;
  String? posterImageUrl;
  String? speakerImageUrl;
  String? externalId;
  bool? isDisabled;

  String? _joiningUrl = '';
  String? _joiningShortUrl = '';
  DateTime? _eventScheduledAt;

  bool _isEventSubscribed = false;

  set isEventSubscribed(bool? value) {
    this._isEventSubscribed = value ?? false;
  }

  bool get isEventSubscribed => this._isEventSubscribed;

  // Joining Url
  set joiningUrl(String? url) {
    this._joiningUrl = url ?? '';
  }

  String? get joiningUrl => this._joiningUrl;

  // Joining Short Url
  set joiningShortUrl(String? url) {
    this._joiningShortUrl = url ?? '';
  }

  String? get joiningShortUrl => this._joiningShortUrl;

  // Event Scheduled At
  set eventScheduledAt(DateTime? eventScheduled) {
    this._eventScheduledAt = eventScheduled?.toLocal();
  }

  DateTime? get eventScheduledAt => this._eventScheduledAt;

  EventScheduleModel(
      {this.upcomingEvents,
      this.name,
      this.description,
      this.duration,
      this.startsAt,
      this.posterImageUrl,
      this.speakerImageUrl,
      this.externalId,
      this.isDisabled});

  EventScheduleModel.fromJson(Map<String, dynamic> json) {
    upcomingEvents = List<EventModel>.from(
      WealthyCast.toList(json["upcoming_events"]).map(
        (x) {
          EventModel upcomingEventModel = EventModel.fromJson(x);

          if (upcomingEventModel.eventSubscriber != null) {
            this._isEventSubscribed = true;
            _extractSubscribedEventDetailsFrom(upcomingEventModel);
          }

          return upcomingEventModel;
        },
      ),
    )..sort((a, b) {
        // Sort events by scheduledAt in ascending order (soonest first)
        // Events with null scheduledAt are placed at the end
        if (a.scheduledAt == null && b.scheduledAt == null) return 0;
        if (a.scheduledAt == null) return 1;
        if (b.scheduledAt == null) return -1;
        return a.scheduledAt!.compareTo(b.scheduledAt!);
      });
    name = WealthyCast.toStr(json["name"]);
    language = WealthyCast.toStr(json["language"]);
    description = WealthyCast.toStr(json["description"]);
    duration = WealthyCast.toInt(json["duration"]);
    startsAt = WealthyCast.toDate(json["starts_at"]);
    posterImageUrl = WealthyCast.toStr(json["poster_image_url"]);
    speakerImageUrl = WealthyCast.toStr(json["speaker_image_url"]);
    externalId = WealthyCast.toStr(json["external_id"]);
    isDisabled = WealthyCast.toBool(json["is_disabled"]);
  }

  _extractSubscribedEventDetailsFrom(EventModel upcomingEventModel) {
    try {
      // Prioritise first found event schedule and joining urls
      bool isJoiningUrlPresent = this._joiningUrl.isNullOrEmpty &&
          (upcomingEventModel.eventSubscriber?.joiningUrl?.isNotNullOrEmpty ??
              false);

      if (isJoiningUrlPresent) {
        this._joiningUrl = upcomingEventModel.eventSubscriber?.joiningUrl ?? '';
      }

      bool isJoiningShortUrlPresent = this._joiningShortUrl.isNullOrEmpty &&
          (upcomingEventModel
                  .eventSubscriber?.joiningShortUrl?.isNotNullOrEmpty ??
              false);

      if (isJoiningShortUrlPresent) {
        this._joiningShortUrl =
            upcomingEventModel.eventSubscriber!.joiningShortUrl;
      }

      if (this._eventScheduledAt == null) {
        this._eventScheduledAt = upcomingEventModel.scheduledAt?.toLocal();
      }
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }
}

class EventModel {
  EventSubscriberModel? eventSubscriber;
  String? externalId;
  DateTime? scheduledAt;
  String? language;
  String? speakerName;
  String? speakerEmail;

  EventModel({
    this.eventSubscriber,
    this.externalId,
    this.scheduledAt,
    this.language,
    this.speakerName,
    this.speakerEmail,
  });

  EventModel.fromJson(Map<String, dynamic> json) {
    eventSubscriber = json["event_subscriber"] != null
        ? EventSubscriberModel.fromJson(json["event_subscriber"])
        : null;
    externalId = WealthyCast.toStr(json["external_id"]);
    scheduledAt = WealthyCast.toDate(json["scheduled_at"]);
    language = WealthyCast.toStr(json["language"]);
    speakerName = WealthyCast.toStr(json["speaker_name"]);
    speakerEmail = WealthyCast.toStr(json["speaker_email"]);
  }
}

class EventSubscriberModel {
  String? joiningUrl;
  String? joiningShortUrl;
  EventModel? event;

  EventSubscriberModel.fromJson(Map<String, dynamic> json) {
    if (json['event'] != null) {
      json['event']['event_subscriber'] = null;
    }

    joiningUrl = WealthyCast.toStr(json['joining_url']);
    joiningShortUrl = WealthyCast.toStr(json['joining_short_url']);
    event = json['event'] != null ? EventModel.fromJson(json['event']) : null;
  }
}
