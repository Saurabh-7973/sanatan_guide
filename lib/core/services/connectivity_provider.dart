import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// Streams the current online/offline state. true = at least one transport
/// reports a usable connection (wifi/mobile/ethernet); false = airplane mode,
/// no signal, or every transport reports `none`.
///
/// Riverpod 3 keepAlive so all screens watching it share the same upstream
/// subscription — we never want to spawn multiple PlatformChannel watchers.
@Riverpod(keepAlive: true)
Stream<bool> isOnline(Ref ref) {
  final controller = StreamController<bool>();
  // Default to "online" if the platform channel isn't available (widget
  // tests, headless flutter test) so the banner stays hidden rather than
  // throwing a MissingPluginException through the provider tree.
  final Connectivity connectivity;
  try {
    connectivity = Connectivity();
  } catch (_) {
    controller.add(true);
    ref.onDispose(controller.close);
    return controller.stream;
  }

  // Emit once with the current state so widgets don't flash an "offline"
  // banner during the first frame while waiting for the first stream event.
  // Errors (e.g. plugin missing in tests) → assume online.
  unawaited(
    connectivity
        .checkConnectivity()
        .then((results) => controller.add(_anyOnline(results)))
        .catchError((Object _) => controller.add(true)),
  );
  final sub = connectivity.onConnectivityChanged.listen(
    (results) => controller.add(_anyOnline(results)),
    onError: (Object _) => controller.add(true),
  );
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
}

bool _anyOnline(List<ConnectivityResult> results) {
  for (final r in results) {
    if (r != ConnectivityResult.none) return true;
  }
  return false;
}
