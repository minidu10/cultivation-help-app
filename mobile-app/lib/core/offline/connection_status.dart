import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the last request reached the server. Driven by the API client
/// rather than by the network type: a phone can be "on Wi-Fi" in a shop
/// whose internet is down, and only a real request shows that.
final connectionStatusProvider = NotifierProvider<ConnectionStatus, bool>(ConnectionStatus.new);

class ConnectionStatus extends Notifier<bool> {
  @override
  bool build() => true;

  bool get isOnline => state;

  void online() {
    if (!state) state = true;
  }

  void offline() {
    if (state) state = false;
  }
}
