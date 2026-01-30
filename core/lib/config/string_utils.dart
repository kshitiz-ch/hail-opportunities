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
      return (this!.trim().isEmpty);
    }
  }

  bool get isNotNullOrEmpty => !isNullOrEmpty;

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

  String toStringWithoutTrailingZero([int numberOfPlaces = 0]) {
    if (this == null || this == 0) {
      return '-';
    }

    RegExp regex = RegExp(r"([.]+0+)(?!.*\d)");

    return this!.toStringAsFixed(numberOfPlaces).replaceAll(regex, '');
  }
}
