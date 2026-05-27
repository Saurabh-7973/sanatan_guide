import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

/// Navigator observer that drops a Crashlytics breadcrumb each time a route
/// changes. If the app then crashes the next minute, the crash report
/// includes the trail of recent screens — usually the fastest signal for
/// "where was the user when this hit?".
///
/// Breadcrumbs are clipped to the route's path/name; nothing user-generated
/// (search queries, verse content) is sent.
class CrashlyticsObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log('replace', newRoute, oldRoute);
  }

  void _log(String kind, Route<dynamic>? to, Route<dynamic>? from) {
    final dest = _nameOf(to);
    final src = _nameOf(from);
    if (dest.isEmpty && src.isEmpty) return;
    try {
      FirebaseCrashlytics.instance.log('$kind: ${src.isEmpty ? '∅' : src} → $dest');
    } catch (_) {
      // Crashlytics not ready (tests, very-early boot) — silent.
    }
  }

  String _nameOf(Route<dynamic>? r) {
    if (r == null) return '';
    final settings = r.settings;
    return settings.name ?? settings.runtimeType.toString();
  }
}
