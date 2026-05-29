import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/constants/preferences_keys.dart';

part 'font_size_provider.g.dart';

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
    final size = prefs.getDouble(PrefsKeys.appFontSize);
    if (size != null) {
      state = size.clamp(kMinFontSize, kMaxFontSize);
    }
  }

  Future<void> setFontSize(double size) async {
    final clamped = size.clamp(kMinFontSize, kMaxFontSize);
    state = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(PrefsKeys.appFontSize, clamped);
  }
}
