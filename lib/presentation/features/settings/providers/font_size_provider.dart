import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'font_size_provider.g.dart';

const _kFontSizeKey = 'app_font_size';
const double kDefaultFontSize = 16.0;
const double kMinFontSize = 12.0;
const double kMaxFontSize = 24.0;

@Riverpod(keepAlive: true)
class FontSizeNotifier extends _$FontSizeNotifier {
  @override
  double build() {
    _load();
    return kDefaultFontSize;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getDouble(_kFontSizeKey);
    if (size != null) {
      state = size.clamp(kMinFontSize, kMaxFontSize);
    }
  }

  Future<void> setFontSize(double size) async {
    final clamped = size.clamp(kMinFontSize, kMaxFontSize);
    state = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontSizeKey, clamped);
  }
}
