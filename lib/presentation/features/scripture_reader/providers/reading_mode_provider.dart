import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reading_mode_provider.g.dart';

enum ReadingMode {
  all,
  sanskrit,
  translationOnly,
}

extension ReadingModeLabel on ReadingMode {
  String get label => switch (this) {
        ReadingMode.all => 'Full',
        ReadingMode.sanskrit => 'Sanskrit',
        ReadingMode.translationOnly => 'English',
      };

  String get key => name;
}

const _kReadingModeKey = 'reading_mode';

@Riverpod(keepAlive: true)
class ReadingModeNotifier extends _$ReadingModeNotifier {
  @override
  ReadingMode build() {
    _load();
    return ReadingMode.all;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kReadingModeKey);
    if (raw != null) {
      final mode = ReadingMode.values.where((m) => m.key == raw).firstOrNull;
      if (mode != null) state = mode;
    }
  }

  Future<void> setMode(ReadingMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kReadingModeKey, mode.key);
  }
}
