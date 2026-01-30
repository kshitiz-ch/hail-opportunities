import 'package:core/modules/common/resources/wealthy_cast.dart';

class CountryModel {
  String? name;
  String? emoji;
  List<State>? state;

  CountryModel({this.name, this.emoji, this.state});

  CountryModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    emoji = WealthyCast.toStr(json['emoji']);
    if (json['state'] != null) {
      state = <State>[];
      json['state'].forEach((v) {
        state!.add(new State.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['emoji'] = this.emoji;
    if (this.state != null) {
      data['state'] = this.state!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class State {
  String? name;
  List<City>? city;

  State({this.name, this.city});

  State.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    if (json['city'] != null) {
      city = <City>[];
      json['city'].forEach((v) {
        city!.add(new City.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.city != null) {
      data['city'] = this.city!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class City {
  String? name;

  City({this.name});

  City.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
