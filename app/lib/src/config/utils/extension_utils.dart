extension StringEx on String? {
  String get initials {
    if (this.isNullOrEmpty) return '';

    final words = this?.trim().split(' ');
    if (words.isNotNullOrEmpty && words!.length > 1) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    }
    return words.isNotNullOrEmpty ? '${words!.first[0]}'.toUpperCase() : '';
  }

  bool get isNullOrEmpty {
    if (this == null) {
      return true;
    } else if (this is String && this == 'null') {
      return true;
    } else {
      return (this!.isEmpty);
    }
  }

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  bool get isNullOrBlank {
    if (this == null) {
      return true;
    } else if (this is String && this == 'null') {
      return true;
    } else {
      return (this!.trim().isEmpty);
    }
  }

  bool get isNotNullOrBlank => !isNullOrBlank;

  String toCapitalized() => isNotNullOrEmpty && this!.length > 0
      ? '${this![0].toUpperCase()}${this!.substring(1).toLowerCase()}'
      : '';

  String toTitleCase() => isNotNullOrEmpty
      ? this!
          .replaceAll(RegExp(' +'), ' ')
          .split(' ')
          .map((str) => str.toCapitalized())
          .join(' ')
      : '';

  String? toSnakeCase() =>
      isNotNullOrEmpty ? this!.toLowerCase().split(" ").join("_") : null;
}

extension IterableX on Iterable? {
  bool get isNullOrEmpty {
    if (this == null) {
      return true;
    } else {
      return this!.isEmpty;
    }
  }

  bool get isNotNullOrEmpty => !isNullOrEmpty;
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

extension IntExt on int? {
  bool get isNullOrZero {
    if (this == null || this == 0) {
      return true;
    } else if (this is! int) {
      return true;
    } else {
      return false;
    }
  }

  bool get isNotNullOrZero {
    if (this != null && this != 0) {
      return true;
    } else {
      return false;
    }
  }

  String get numberPattern {
    final number = this;
    if (number == null) {
      return '';
    }
    switch (number % 10) {
      case 1:
        if ((number ~/ 10) % 10 != 1) {
          return '${number}st';
        }
        break;
      case 2:
        if ((number ~/ 10) % 10 != 1) {
          return '${number}nd';
        }
        break;
      case 3:
        if ((number ~/ 10) % 10 != 1) {
          return '${number}rd';
        } else {
          break;
        }
    }
    return '${number}th';
  }
}

extension DoubleExt on double? {
  bool get isNullOrZero {
    if (this == null || this == 0) {
      return true;
    } else if (this is! double) {
      return true;
    } else {
      return false;
    }
  }

  bool get isNotNullOrZero {
    if (this != null && this != 0) {
      return true;
    } else {
      return false;
    }
  }

  double get toPercentage {
    if (this != null && this != 0) {
      return (this! * 100);
    } else {
      return 0;
    }
  }

  String? toStringWithoutTrailingZero([int numberOfPlaces = 0]) {
    if (this == null || this == 0) {
      return null;
    }

    RegExp regex = RegExp(r"([.]+0+)(?!.*\d)");

    return this!.toStringAsFixed(numberOfPlaces).replaceAll(regex, '');
  }
}
